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
      currency,
      petId,
      renterId,
      startDate,
      endDate
    } = req.body;

    if (typeof amount !== "number" || amount < 50) {
      return res.status(400).json({
        error: "Invalid amount. Use cents. Minimum 50."
      });
    }

    if (typeof currency !== "string" || !currency.length) {
      return res.status(400).json({
        error: "Invalid currency."
      });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: { enabled: true },
      metadata: {
        petId: petId ?? "",
        renterId: renterId ?? "",
        startDate: startDate ?? "",
        endDate: endDate ?? ""
      }
    });

    res.json({
      publishableKey,
      paymentIntentClientSecret: paymentIntent.client_secret,
      paymentIntentId: paymentIntent.id
    });
  } catch (err) {
    console.error("create-payment-intent error:", err);
    res.status(500).json({
      error: err.message || "Server error"
    });
  }
});

const PORT = process.env.PORT || 4242;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});