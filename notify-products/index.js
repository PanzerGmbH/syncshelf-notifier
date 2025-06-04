const express = require("express");
const admin = require("firebase-admin");
const bodyParser = require("body-parser");

const app = express(); // ⬅️ DAS darf nicht fehlen!

app.use(bodyParser.json());

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
    console.log("[RAILWAY] ➕ Gefundene Produkte:");
snapshot.docs.forEach((doc, i) => {
  try {
    const data = doc.data();
    const name = data.name ?? "Unbekannt";
    const expiresAt = data.expiresAt instanceof admin.firestore.Timestamp
      ? data.expiresAt.toDate().toISOString()
      : "⚠️ Kein gültiger Timestamp";

    console.log(`  ${i + 1}. ${name} – Ablauf: ${expiresAt}`);
  } catch (err) {
    console.error(`❌ Fehler beim Lesen von Dokument ${i + 1}:`, err);
  }
});



    for (const doc of snapshot.docs) {
      const data = doc.data();
      const token = data.deviceToken;
      const name = data.name ?? "Ein Produkt";

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

    res.send("✅ Benachrichtigungen verarbeitet.");
  } catch (error) {
    console.error("❌ Fehler bei Verarbeitung:", error);
    res.status(500).send("❌ Interner Fehler beim Verarbeiten.");
  }
});
