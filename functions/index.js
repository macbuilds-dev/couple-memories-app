const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");

initializeApp();

/**
 * When a partner writes users/{uid}/alerts/{id}, send an FCM push
 * so the recipient gets notified even if the app is backgrounded/killed.
 */
exports.onPartnerAlertCreated = onDocumentCreated(
  "users/{userId}/alerts/{alertId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const userId = event.params.userId;
    const alert = snap.data() || {};
    const title = alert.title || "Yaaram";
    const body = alert.body || "New update from your partner";
    const type = alert.type || "update";
    const data = {
      type: String(type),
      ...(alert.data || {}),
    };

    // Ensure all data values are strings for FCM.
    const stringData = Object.fromEntries(
      Object.entries(data).map(([k, v]) => [k, String(v ?? "")])
    );

    const userDoc = await getFirestore().collection("users").doc(userId).get();
    const token = userDoc.get("fcmToken");
    if (!token) {
      logger.info("No fcmToken for user", { userId });
      return;
    }

    try {
      await getMessaging().send({
        token,
        notification: { title, body },
        data: stringData,
        android: {
          priority: "high",
          notification: {
            channelId: "yaaram_updates",
            sound: "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
            },
          },
        },
      });
      logger.info("FCM sent", { userId, type });
    } catch (err) {
      logger.error("FCM send failed", { userId, err: String(err) });
      // Drop invalid tokens so the next login refreshes.
      if (
        err?.code === "messaging/registration-token-not-registered" ||
        err?.code === "messaging/invalid-registration-token"
      ) {
        await userDoc.ref.set(
          { fcmToken: null, fcmTokenUpdatedAt: new Date() },
          { merge: true }
        );
      }
    }
  }
);
