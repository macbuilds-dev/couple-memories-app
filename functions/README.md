# Yaaram Cloud Functions

Sends FCM push when a partner creates `users/{uid}/alerts/{id}`.

## Deploy (requires Blaze plan)

```bash
cd functions && npm install
cd ..
firebase deploy --only functions,firestore:rules
```

Also enable **Cloud Messaging** and upload an **APNs key** in Firebase Console → Project settings → Cloud Messaging for iOS.
