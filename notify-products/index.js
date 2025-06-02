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

// 🧪 Test-Route für allgemeine Benachrichtigung
app.get("/test", async (req, res) => {
  try {
    const testToken = "chvTMYglQWGczGis-52m-g:APA91bFk3CDSPAvUJZ9-XyAoaQ29TgKLX7uPisFrfIVfhv1ptWh2i5XMq9eU1aftcDR1_WbvwwaRpuu8bkK0VC9O3ToXaD5cbE_EbBmH1tcFqwqc7bWpEWM";

    await admin.messaging().send({
      token: testToken,
      notification: {
        title: "📣 Test erfolgreich",
        body: "Der Bledsinn funkt endlich, heast!",
      },
    });

    console.log("✅ Test-Benachrichtigung gesendet");
    res.send("✅ Testnachricht wurde geschickt.");
  } catch (error) {
    console.error("❌ Fehler beim Testversand:", error);
    res.status(500).send("❌ Fehler beim Testversand.");
  }
});

// 📣 Haupt-Endpoint – verschickt Notifications für Produkte
app.get("/", async (req, res) => {
  try {
    const now = new Date();
    const targetDate = new Date(now);
    targetDate.setDate(now.getDate() + 3);

    const start = new Date(targetDate.setHours(0, 0, 0, 0));
    const end = new Date(targetDate.setHours(23, 59, 59, 999));

    const snapshot = await firestore.collection("products")
      .where("expiresAt", ">=", start)
      .where("expiresAt", "<=", end)
      .get();

    console.log(`[RAILWAY] Produkte mit Ablauf in 3 Tagen: ${snapshot.size}`);

    for (const doc of snapshot.docs) {
      const data = doc.data();
      const token = "chvTMYglQWGczGis-52m-g:APA91bFk3CDSPAvUJZ9-XyAoaQ29TgKLX7uPisFrfIVfhv1ptWh2i5XMq9eU1aftcDR1_WbvwwaRpuu8bkK0VC9O3ToXaD5cbE_EbBmH1tcFqwqc7bWpEWM";
      const name = data.name ?? "Ein Produkt";

      await admin.messaging().send({
        token: token,
        notification: {
          title: "Achtung!",
          body: `${name} läuft in 3 Tagen ab!`,
        },
      });

      console.log(`[RAILWAY] ✅ Notification gesendet: ${name}`);
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
