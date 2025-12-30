import express from "express";
import cors from "cors";
import Stripe from "stripe";

const app = express();
app.use(cors());
app.use(express.json());

const secretKey = process.env.STRIPE_SECRET_KEY;
if (!secretKey) {
  console.error("Missing STRIPE_SECRET_KEY. Set it like:");
  console.error('export STRIPE_SECRET_KEY="sk_test_..."');
  process.exit(1);
}

const stripe = new Stripe(secretKey);

app.get("/", (req, res) => {
  res.json({ ok: true, message: "Rent a Pet backend running" });
});

app.post("/create-payment-intent", async (req, res) => {
  try {
    const { amount, currency } = req.body;

    if (typeof amount !== "number" || amount < 50) {
      return res.status(400).json({
        error: "Invalid amount. Use smallest currency unit (e.g. cents). Minimum 50."
      });
    }
    if (typeof currency !== "string" || !currency.length) {
      return res.status(400).json({ error: "Invalid currency. Example: 'usd'." });
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: { enabled: true }
    });

    res.json({ paymentIntentClientSecret: paymentIntent.client_secret });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message || "Server error" });
  }
});

const PORT = process.env.PORT || 4242;
app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));

