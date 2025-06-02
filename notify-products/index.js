const express = require("express");
const admin = require("firebase-admin");
const bodyParser = require("body-parser");

const app = express();
app.use(bodyParser.json());

// 🔐 Firebase Service Account laden (aus Base64)
const decodedKey = Buffer.from(process.env.FIREBASE_KEY_B64, 'base64').toString('utf-8');
const serviceAccount = JSON.parse(decodedKey);

// 🔥 Firebase initialisieren
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const firestore = admin.firestore();

// ✅ Healthcheck-Route
app.get("/ping", (req, res) => {
  res.send("✅ SyncShelf läuft");
});

// 📣 Haupt-Endpoint – verschickt Notifications
app.get("/", async (req, res) => {
  try {
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

    res.send("✅ Benachrichtigungen verarbeitet.");
  } catch (error) {
    console.error("❌ Fehler bei Verarbeitung:", error);
    res.status(500).send("❌ Interner Fehler beim Verarbeiten.");
  }
});

// 🔊 Server starten
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server läuft auf Port ${PORT}`);
});
