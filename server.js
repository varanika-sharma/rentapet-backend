import express from "express";
import cors from "cors";
import Stripe from "stripe";

const app = express();

// MARK: - Environment

const secretKey = process.env.STRIPE_SECRET_KEY;
const publishableKey = process.env.STRIPE_PUBLISHABLE_KEY;

const stripeWebhookSecret =
  process.env.STRIPE_WEBHOOK_SECRET;

const supabaseURL =
  process.env.SUPABASE_URL;

const supabaseAnonKey =
  process.env.SUPABASE_ANON_KEY;

const supabaseServiceRoleKey =
  process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!secretKey) {
  console.error("Missing STRIPE_SECRET_KEY");
  process.exit(1);
}

if (!publishableKey) {
  console.error("Missing STRIPE_PUBLISHABLE_KEY");
  process.exit(1);
}

const stripe = new Stripe(secretKey);

// MARK: - Stripe Webhook
//
// IMPORTANT:
// This route must come BEFORE express.json().
// Stripe needs the raw request body to verify
// the webhook signature.

app.post(
  "/stripe-webhook",
  express.raw({
    type: "application/json"
  }),
  async (req, res) => {
    if (!stripeWebhookSecret) {
      console.error(
        "Missing STRIPE_WEBHOOK_SECRET"
      );

      return res.status(500).send(
        "Webhook configuration missing."
      );
    }

    const signature =
      req.headers["stripe-signature"];

    if (!signature) {
      return res.status(400).send(
        "Missing Stripe signature."
      );
    }

    let event;

    try {
      event =
        stripe.webhooks.constructEvent(
          req.body,
          signature,
          stripeWebhookSecret
        );
    } catch (error) {
      console.error(
        "Stripe webhook signature error:",
        error.message
      );

      return res.status(400).send(
        `Webhook Error: ${error.message}`
      );
    }

    try {
      switch (event.type) {
        case "identity.verification_session.verified": {
          const session = event.data.object;

          await handleIdentityStatusChange(
            session,
            "verified"
          );

          break;
        }

        case "identity.verification_session.processing": {
          const session = event.data.object;

          await handleIdentityStatusChange(
            session,
            "processing"
          );

          break;
        }

        case "identity.verification_session.requires_input": {
          const session = event.data.object;

          await handleIdentityStatusChange(
            session,
            "requires_input"
          );

          break;
        }

        default:
          console.log(
            `Unhandled Stripe event: ${event.type}`
          );
      }

      return res.json({
        received: true
      });
    } catch (error) {
      console.error(
        "Stripe webhook processing error:",
        error
      );

      return res.status(500).json({
        error:
          error.message ||
          "Webhook processing failed."
      });
    }
  }
);

// MARK: - Standard Middleware

app.use(cors());
app.use(express.json());

// MARK: - Health Check

app.get("/", (req, res) => {
  res.json({
    ok: true,
    message:
      "Rent a Pet backend running"
  });
});

// MARK: - Payments

app.post(
  "/create-payment-intent",
  async (req, res) => {
    try {
      const {
        amount,
        currency,
        petId,
        renterId,
        startDate,
        endDate
      } = req.body;

      if (
        typeof amount !== "number" ||
        amount < 50
      ) {
        return res.status(400).json({
          error:
            "Invalid amount. Use cents. Minimum 50."
        });
      }

      if (
        typeof currency !== "string" ||
        !currency.length
      ) {
        return res.status(400).json({
          error: "Invalid currency."
        });
      }

      const paymentIntent =
        await stripe.paymentIntents.create({
          amount,
          currency,

          automatic_payment_methods: {
            enabled: true
          },

          metadata: {
            petId: petId ?? "",
            renterId: renterId ?? "",
            startDate: startDate ?? "",
            endDate: endDate ?? ""
          }
        });

      return res.json({
        publishableKey,

        paymentIntentClientSecret:
          paymentIntent.client_secret,

        paymentIntentId:
          paymentIntent.id
      });
    } catch (error) {
      console.error(
        "create-payment-intent error:",
        error
      );

      return res.status(500).json({
        error:
          error.message ||
          "Server error"
      });
    }
  }
);

// MARK: - Identity Verification

app.post(
  "/identity/create-verification-session",
  requireSupabaseUser,
  async (req, res) => {
    try {
      requireSupabaseServerConfig();

      const user =
        req.supabaseUser;

      console.log(
        "Creating Identity verification session for:",
        user.id
      );

      const verificationSession =
        await stripe.identity
          .verificationSessions
          .create({
            type: "document",

            provided_details: {
              email:
                user.email || undefined
            },

            options: {
              document: {
                require_matching_selfie:
                  true
              }
            },

            metadata: {
              user_id: user.id
            }
          });

      //
      // Stripe requires an explicit API version
      // when creating an ephemeral key.
      //
      // This matches the Stripe API version
      // currently configured for the Rent a Pet
      // Identity integration.
      //

      const ephemeralKey =
        await stripe.ephemeralKeys.create(
          {
            verification_session:
              verificationSession.id
          },
          {
            apiVersion:
              "2025-12-15.clover"
          }
        );

      await updateIdentityStatus(
        user.id,
        "pending"
      );

      console.log(
        "Identity verification session created:",
        verificationSession.id
      );

      return res.json({
        verificationSessionId:
          verificationSession.id,

        ephemeralKeySecret:
          ephemeralKey.secret
      });
    } catch (error) {
      console.error(
        "create identity verification error:",
        error
      );

      return res.status(500).json({
        error:
          error.message ||
          "Unable to create identity verification session."
      });
    }
  }
);

// MARK: - Identity Status

app.get(
  "/identity/status",
  requireSupabaseUser,
  async (req, res) => {
    try {
      requireSupabaseServerConfig();

      const userId =
        req.supabaseUser.id;

      const url =
        new URL(
          `${supabaseURL}/rest/v1/profiles`
        );

      url.searchParams.set(
        "id",
        `eq.${userId}`
      );

      url.searchParams.set(
        "select",
        "identity_verification_status"
      );

      const response =
        await fetch(url, {
          method: "GET",

          headers: {
            apikey:
              supabaseServiceRoleKey,

            Authorization:
              `Bearer ${supabaseServiceRoleKey}`,

            Accept:
              "application/json"
          }
        });

      const text =
        await response.text();

      if (!response.ok) {
        throw new Error(
          `Supabase status lookup failed (${response.status}): ${text}`
        );
      }

      const profiles =
        text
          ? JSON.parse(text)
          : [];

      const status =
        profiles[0]
          ?.identity_verification_status ??
        "not_started";

      return res.json({
        status
      });
    } catch (error) {
      console.error(
        "identity status error:",
        error
      );

      return res.status(500).json({
        error:
          error.message ||
          "Unable to retrieve identity verification status."
      });
    }
  }
);

// MARK: - Supabase Authentication

async function requireSupabaseUser(
  req,
  res,
  next
) {
  try {
    if (
      !supabaseURL ||
      !supabaseAnonKey
    ) {
      console.error(
        "Missing Supabase authentication configuration."
      );

      return res.status(500).json({
        error:
          "Server authentication configuration is missing."
      });
    }

    const authorization =
      req.headers.authorization;

    if (
      !authorization ||
      !authorization.startsWith(
        "Bearer "
      )
    ) {
      return res.status(401).json({
        error:
          "Missing authorization token."
      });
    }

    const accessToken =
      authorization.substring(
        "Bearer ".length
      );

    const response =
      await fetch(
        `${supabaseURL}/auth/v1/user`,
        {
          method: "GET",

          headers: {
            apikey:
              supabaseAnonKey,

            Authorization:
              `Bearer ${accessToken}`
          }
        }
      );

    const text =
      await response.text();

    if (!response.ok) {
      console.error(
        "Supabase user validation failed:",
        response.status,
        text
      );

      return res.status(401).json({
        error:
          "Your session is invalid or expired. Please log in again."
      });
    }

    const user =
      text
        ? JSON.parse(text)
        : null;

    if (!user?.id) {
      return res.status(401).json({
        error:
          "Unable to identify the authenticated user."
      });
    }

    req.supabaseUser =
      user;

    next();
  } catch (error) {
    console.error(
      "Supabase authentication error:",
      error
    );

    return res.status(500).json({
      error:
        "Unable to validate the current user."
    });
  }
}

// MARK: - Stripe Identity Webhook Handling

async function handleIdentityStatusChange(
  verificationSession,
  status
) {
  const userId =
    verificationSession
      ?.metadata
      ?.user_id;

  if (!userId) {
    console.error(
      "Identity verification session missing user_id metadata:",
      verificationSession?.id
    );

    return;
  }

  await updateIdentityStatus(
    userId,
    status
  );

  console.log(
    `Identity status updated: ${userId} -> ${status}`
  );
}

// MARK: - Supabase Identity Status Update

async function updateIdentityStatus(
  userId,
  status
) {
  requireSupabaseServerConfig();

  const url =
    new URL(
      `${supabaseURL}/rest/v1/profiles`
    );

  url.searchParams.set(
    "id",
    `eq.${userId}`
  );

  const response =
    await fetch(url, {
      method: "PATCH",

      headers: {
        apikey:
          supabaseServiceRoleKey,

        Authorization:
          `Bearer ${supabaseServiceRoleKey}`,

        "Content-Type":
          "application/json",

        Prefer:
          "return=minimal"
      },

      body: JSON.stringify({
        identity_verification_status:
          status
      })
    });

  const text =
    await response.text();

  if (!response.ok) {
    throw new Error(
      `Supabase identity status update failed (${response.status}): ${text}`
    );
  }
}

// MARK: - Configuration Validation

function requireSupabaseServerConfig() {
  if (!supabaseURL) {
    throw new Error(
      "Missing SUPABASE_URL"
    );
  }

  if (!supabaseAnonKey) {
    throw new Error(
      "Missing SUPABASE_ANON_KEY"
    );
  }

  if (!supabaseServiceRoleKey) {
    throw new Error(
      "Missing SUPABASE_SERVICE_ROLE_KEY"
    );
  }
}

// MARK: - Start Server

const PORT =
  process.env.PORT || 4242;

app.listen(PORT, () => {
  console.log(
    `Server running on port ${PORT}`
  );
});
