const express = require("express");
const admin = require("firebase-admin");
const bodyParser = require("body-parser");

const app = express();
app.use(bodyParser.json());

// DAS IST DER ENTSCHEIDENDE TRICK:
const decoded = Buffer.from(process.env.FIREBASE_KEY_B64, 'base64').toString('utf-8');
const serviceAccount = JSON.parse(decoded);

//PEM-Fix hier:
serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, '\n');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});


const firestore = admin.firestore();

app.get("/", async (req, res) => {
  const now = new Date();
  const targetDate = new Date(now);
  targetDate.setDate(now.getDate() + 3);

  const start = new Date(targetDate.setHours(0, 0, 0, 0));
  const end = new Date(targetDate.setHours(23, 59, 59, 999));

  const snapshot = await firestore.collection("products")
    .where("expiry_date", ">=", start)
    .where("expiry_date", "<=", end)
    .get();

  console.log(`[RAILWAY] Produkte mit Ablauf in 3 Tagen: ${snapshot.size}`);

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const token = data.fcm_token;
    const name = data.name ?? "Ein Produkt";

    if (!token) continue;

    await admin.messaging().send({
      token: token,
      notification: {
        title: "Achtung!",
        body: `${name} läuft in 3 Tagen ab!`,
      },
    });

    console.log(`[RAILWAY] Notification gesendet an ${token}`);
  }

  res.send(" Benachrichtigungen verarbeitet.");
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(` Server läuft auf Port ${PORT}`);
});
