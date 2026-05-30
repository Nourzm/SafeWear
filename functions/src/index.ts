import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as twilio from 'twilio';

admin.initializeApp();

const twilioClient = twilio(
  functions.config().twilio.account_sid,
  functions.config().twilio.auth_token,
);
const TWILIO_PHONE = functions.config().twilio.phone_number;

// Called by the Flutter app's SmsService
export const sendSmsAlert = functions.https.onCall(async (data, context) => {
  const { to, userName, mapsLink, mode } = data;

  const modeMessages: Record<string, string> = {
    contacts: `EMERGENCY: ${userName} needs help! Location: ${mapsLink ?? 'unavailable'}. Open SafeWear app to respond.`,
    police: `EMERGENCY + POLICE: ${userName} needs urgent help! Police have been notified. Location: ${mapsLink ?? 'unavailable'}`,
    saveMe: `MAXIMUM EMERGENCY: ${userName} needs immediate help! All services notified. Location: ${mapsLink ?? 'unavailable'}`,
  };

  const body = modeMessages[mode] ?? modeMessages['contacts'];

  await twilioClient.messages.create({ body, from: TWILIO_PHONE, to });
  return { success: true };
});

// Triggered by Firestore when a new alert_dispatch doc is created
// Sends FCM push notifications to all trusted contacts
export const dispatchAlertNotifications = functions.firestore
  .document('alert_dispatches/{dispatchId}')
  .onCreate(async (snap) => {
    const data = snap.data();
    const { userId, alertId, mode, contacts, lat, lng, mapsLink } = data;

    const user = await admin.firestore().collection('users').doc(userId).get();
    const userName = user.data()?.name ?? 'SafeWear User';

    const modeLabel: Record<string, string> = {
      contacts: 'Contacts Alert',
      police: 'Contacts + Police Alert',
      saveMe: 'Maximum Emergency Alert',
    };

    for (const contact of contacts) {
      // Look up FCM token for this contact's phone number
      const contactDocs = await admin
        .firestore()
        .collection('users')
        .where('phone', '==', contact.phone)
        .limit(1)
        .get();

      if (!contactDocs.empty) {
        const contactData = contactDocs.docs[0].data();
        const fcmToken = contactData.fcmToken;
        if (fcmToken) {
          await admin.messaging().send({
            token: fcmToken,
            notification: {
              title: `🚨 ${modeLabel[mode] ?? 'Emergency Alert'}`,
              body: `${userName} needs help! Tap to see their location.`,
            },
            data: {
              alertId,
              userId,
              lat: String(lat ?? ''),
              lng: String(lng ?? ''),
              mapsLink: mapsLink ?? '',
              type: 'emergency_alert',
            },
            android: { priority: 'high' },
            apns: { payload: { aps: { sound: 'default', badge: 1 } } },
          });
        }
      }
    }
  });

// Monitors watch Bluetooth disconnection and auto-pauses subscription
export const monitorWatchConnection = functions.firestore
  .document('users/{userId}')
  .onUpdate(async (change, context) => {
    const before = change.before.data();
    const after = change.after.data();

    if (before.watchConnected && !after.watchConnected) {
      // Watch just disconnected — record timestamp
      await change.after.ref.update({
        watchDisconnectedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    if (!before.watchConnected && !after.watchConnected) {
      const disconnectedAt = after.watchDisconnectedAt?.toDate();
      if (!disconnectedAt) return;
      const hoursDisconnected =
        (Date.now() - disconnectedAt.getTime()) / (1000 * 60 * 60);

      if (hoursDisconnected >= 48 && after.tier === 'watchApp') {
        await change.after.ref.update({ subscriptionPaused: true });
      }
    }
  });

// Aggregates risk pins into anonymized clusters for the heatmap
export const aggregateRiskPins = functions.pubsub
  .schedule('every 60 minutes')
  .onRun(async () => {
    // Anonymize: remove submittedBy, cluster nearby pins within 100m
    const pins = await admin.firestore().collection('risk_pins').get();
    const clusters: Record<string, { lat: number; lng: number; count: number }> = {};

    pins.forEach((pin) => {
      const { lat, lng } = pin.data();
      const key = `${Math.round(lat * 1000) / 1000},${Math.round(lng * 1000) / 1000}`;
      if (clusters[key]) {
        clusters[key].count++;
      } else {
        clusters[key] = { lat, lng, count: 1 };
      }
    });

    const batch = admin.firestore().batch();
    const heatmapRef = admin.firestore().collection('heatmap_clusters');

    // Clear old clusters
    const existing = await heatmapRef.get();
    existing.forEach((doc) => batch.delete(doc.ref));

    // Write new ones
    Object.values(clusters).forEach((cluster) => {
      batch.set(heatmapRef.doc(), cluster);
    });

    await batch.commit();
  });
