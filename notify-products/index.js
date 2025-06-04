const express = require("express");
const admin = require("firebase-admin");
const bodyParser = require("body-parser");

const app = express();
app.use(bodyParser.json());

// 🔐 Firebase Service Account laden (aus Base64)
const decodedKey = Buffer.from(process.env.FIREBASE_KEY_B64, 'base64').toString('utf-8');
const serviceAccount = JSON.parse(decodedKey);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const firestore = admin.firestore();

// 🧠 Notification-Logik ausgelagert
async function handleNotificationJob() {
  const now = new Date();
  const targetDate = new Date(now);
  targetDate.setDate(now.getDate() + 3);

  const start = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(), 0, 0, 0);
  const end = new Date(targetDate.getFullYear(), targetDate.getMonth(), targetDate.getDate(), 23, 59, 59, 999);

  const snapshot = await firestore.collection("products")
    .where("expiresAt", ">=", start)
    .where("expiresAt", "<=", end)
    .get();

  console.log(`[RAILWAY] Produkte mit Ablauf in 3 Tagen: ${snapshot.size}`);
  console.log("[RAILWAY] ➕ Gefundene Produkte:");
  snapshot.docs.forEach((doc, i) => {
    try {
      const data = doc.data();
      const name = data.name ?? "Unbekannt";
      let expiresAt = "⚠️ Kein gültiger Timestamp";
      if (data.expiresAt && typeof data.expiresAt.toDate === "function") {
        expiresAt = data.expiresAt.toDate().toISOString();
      }
      console.log(`  ${i + 1}. ${name} – Ablauf: ${expiresAt}`);
    } catch (err) {
      console.error(`❌ Fehler beim Lesen von Dokument ${i + 1}:`, err);
    }
  });

  for (const doc of snapshot.docs) {
    const data = doc.data();
    const name = data.name ?? "Ein Produkt";
    const token = data.deviceToken;

    if (!token || typeof token !== "string" || token.trim() === "") {
      console.warn(`[RAILWAY] ⚠️ Kein gültiger deviceToken für ${name}, überspringe`);
      continue;
    }

    try {
      await admin.messaging().send({
        token: token,
        notification: {
          title: "Achtung!",
          body: `${name} läuft in 3 Tagen ab!`,
        },
      });
      console.log(`[RAILWAY] ✅ Notification gesendet: ${name}`);
    } catch (sendError) {
      console.error(`[RAILWAY] ❌ Fehler beim Senden an ${name}:`, sendError);
    }
  }
}

// 🖐️ Manuelle Triggerroute
app.get("/", async (req, res) => {
  await handleNotificationJob();
  res.send("✅ Manuell ausgelöst");
});

// ⏰ CRON-kompatible Triggerroute
app.get("/cron", async (req, res) => {
  console.log("⏰ Cron-Trigger erhalten");
  await handleNotificationJob();
  res.send("✅ Cron ausgeführt");
});

// 🚀 Server starten
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Server läuft auf Port ${PORT}`);
});
