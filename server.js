import express from "express";
import cors from "cors";
import Stripe from "stripe";

const app = express();

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

app.use(cors());


// ======================================================
// STRIPE IDENTITY WEBHOOK
// IMPORTANT: Must come BEFORE express.json()
// ======================================================

app.post(
  "/stripe-webhook",
  express.raw({ type: "application/json" }),
  async (req, res) => {

    if (!stripeWebhookSecret) {
      console.error(
        "Missing STRIPE_WEBHOOK_SECRET"
      );

      return res.status(500).send(
        "Webhook not configured"
      );
    }

    const signature =
      req.headers["stripe-signature"];

    if (!signature) {
      return res.status(400).send(
        "Missing Stripe signature"
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

    } catch (err) {

      console.error(
        "Webhook signature verification failed:",
        err.message
      );

      return res.status(400).send(
        "Invalid webhook signature"
      );
    }

    try {

      switch (event.type) {

        case
          "identity.verification_session.verified": {

          const session =
            event.data.object;

          const userId =
            session.metadata?.user_id;

          if (!userId) {
            console.error(
              "Verified session missing user_id:",
              session.id
            );

            return res.status(400).json({
              error:
                "Verification session missing user ID"
            });
          }

          await updateIdentityStatus(
            userId,
            "verified"
          );

          console.log(
            "Identity verified:",
            userId,
            session.id
          );

          break;
        }


        case
          "identity.verification_session.processing": {

          const session =
            event.data.object;

          const userId =
            session.metadata?.user_id;

          if (userId) {
            await updateIdentityStatus(
              userId,
              "processing"
            );
          }

          console.log(
            "Identity processing:",
            userId ?? "unknown user"
          );

          break;
        }


        case
          "identity.verification_session.requires_input": {

          const session =
            event.data.object;

          const userId =
            session.metadata?.user_id;

          if (userId) {
            await updateIdentityStatus(
              userId,
              "requires_input"
            );
          }

          console.log(
            "Identity requires input:",
            userId ?? "unknown user",
            session.last_error?.code ??
              "unknown reason"
          );

          break;
        }


        default:
          break;
      }

      return res.json({
        received: true
      });

    } catch (err) {

      console.error(
        "Stripe webhook processing error:",
        err
      );

      return res.status(500).json({
        error:
          "Webhook processing failed"
      });
    }
  }
);


// ======================================================
// NORMAL JSON ROUTES
// ======================================================

app.use(express.json());


// ======================================================
// HEALTH CHECK
// ======================================================

app.get("/", (req, res) => {

  res.json({
    ok: true,
    message:
      "Rent a Pet backend running"
  });
});


// ======================================================
// EXISTING PAYMENT INTENT
// ======================================================

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
          error:
            "Invalid currency."
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


      res.json({

        publishableKey,

        paymentIntentClientSecret:
          paymentIntent.client_secret,

        paymentIntentId:
          paymentIntent.id
      });


    } catch (err) {

      console.error(
        "create-payment-intent error:",
        err
      );

      res.status(500).json({
        error:
          err.message ||
          "Server error"
      });
    }
  }
);


// ======================================================
// CREATE IDENTITY VERIFICATION SESSION
// ======================================================

app.post(
  "/identity/create-verification-session",
  requireSupabaseUser,
  async (req, res) => {

    try {

      const user =
        req.supabaseUser;


      const verificationSession =
        await stripe.identity
          .verificationSessions
          .create({

            type: "document",

            provided_details:
              user.email
                ? {
                    email: user.email
                  }
                : undefined,

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


      /*
       Create a short-lived key specifically
       for this Verification Session.
      */

      const ephemeralKey =
        await stripe.ephemeralKeys.create(
          {
            verification_session:
              verificationSession.id
          }
        );


      /*
       Starting verification is allowed to
       mark the account pending.

       Only the signed Stripe webhook can
       mark the account VERIFIED.
      */

      await updateIdentityStatus(
        user.id,
        "pending"
      );


      res.json({

        verificationSessionId:
          verificationSession.id,

        ephemeralKeySecret:
          ephemeralKey.secret
      });


    } catch (err) {

      console.error(
        "create identity verification error:",
        err
      );

      res.status(500).json({
        error:
          err.message ||
          "Unable to begin identity verification."
      });
    }
  }
);


// ======================================================
// IDENTITY STATUS
// ======================================================

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
              `Bearer ${supabaseServiceRoleKey}`
          }
        });


      if (!response.ok) {

        const text =
          await response.text();

        throw new Error(
          `Supabase status lookup failed: ${text}`
        );
      }


      const rows =
        await response.json();


      res.json({
        status:
          rows[0]
            ?.identity_verification_status ??
          "not_started"
      });


    } catch (err) {

      console.error(
        "identity status error:",
        err
      );

      res.status(500).json({
        error:
          err.message ||
          "Unable to retrieve identity status."
      });
    }
  }
);


// ======================================================
// SUPABASE AUTHENTICATION
// ======================================================

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
        "Missing Supabase authentication configuration"
      );

      return res.status(500).json({
        error:
          "Identity verification is not configured."
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
          "Authentication required."
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


    if (!response.ok) {

      return res.status(401).json({
        error:
          "Invalid or expired session."
      });
    }


    const user =
      await response.json();


    if (!user?.id) {

      return res.status(401).json({
        error:
          "Invalid authenticated user."
      });
    }


    req.supabaseUser =
      user;


    next();


  } catch (err) {

    console.error(
      "Supabase authentication error:",
      err
    );

    return res.status(401).json({
      error:
        "Authentication failed."
    });
  }
}


// ======================================================
// SERVER-ONLY SUPABASE IDENTITY UPDATE
// ======================================================

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

      body:
        JSON.stringify({
          identity_verification_status:
            status
        })
    });


  if (!response.ok) {

    const text =
      await response.text();


    throw new Error(
      `Supabase identity update failed: ${text}`
    );
  }
}


// ======================================================
// CONFIG CHECK
// ======================================================

function requireSupabaseServerConfig() {

  if (!supabaseURL) {
    throw new Error(
      "Missing SUPABASE_URL"
    );
  }

  if (!supabaseServiceRoleKey) {
    throw new Error(
      "Missing SUPABASE_SERVICE_ROLE_KEY"
    );
  }
}


// ======================================================
// START SERVER
// ======================================================

const PORT =
  process.env.PORT || 4242;


app.listen(
  PORT,
  () => {

    console.log(
      `Server running on port ${PORT}`
    );
  }
);
