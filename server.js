import express from "express";
import cors from "cors";
import Stripe from "stripe";

const app = express();
app.use(cors());
app.use(express.json());

const secretKey = process.env.STRIPE_SECRET_KEY;
const publishableKey = process.env.STRIPE_PUBLISHABLE_KEY;

if (!secretKey) {
  console.error("Missing STRIPE_SECRET_KEY");
  process.exit(1);
}

if (!publishableKey) {
  console.error("Missing STRIPE_PUBLISHABLE_KEY");
  process.exit(1);
}

const stripe = new Stripe(secretKey);

app.get("/", (req, res) => {
  res.json({ ok: true, message: "Rent a Pet backend running" });
});

app.post("/create-payment-intent", async (req, res) => {
  try {
    const {
      amount,
      currency = "usd",
      petId,
      renterId,
      startDate,
      endDate
    } = req.body;

    if (typeof amount !== "number" || amount < 50) {
      return res.status(400).json({
        error: "Invalid amount. Use the smallest currency unit, like cents. Minimum is 50."
      });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      payment_method_types: ["card"],
      metadata: {
        pet_id: petId ?? "",
        renter_id: renterId ?? "",
        start_date: startDate ?? "",
        end_date: endDate ?? ""
      }
    });

    res.json({
      publishableKey,
      paymentIntentClientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: err.message || "Server error"
    });
  }
});

app.post("/refund-payment", async (req, res) => {
  try {
    const { paymentIntentId, reason = "requested_by_customer" } = req.body;

    if (!paymentIntentId || typeof paymentIntentId !== "string") {
      return res.status(400).json({
        error: "paymentIntentId is required."
      });
    }

    const refund = await stripe.refunds.create({
      payment_intent: paymentIntentId,
      reason
    });

    res.json({
      ok: true,
      refundId: refund.id,
      status: refund.status
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      error: err.message || "Refund failed"
    });
  }
});

const PORT = process.env.PORT || 4242;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));