# Decisions

## Log

| Date | Decision | Why |
|------|----------|-----|
| 2026-07-23 | Alerts collection + Cloud Function for FCM (not send FCM from client) | Secure token fan-out; works when app killed |
| 2026-07-23 | Pin `firebase_messaging` to 16.4.1; `firebase_core` `<4.12.0` | Avoid FlutterFire `FirebasePlugin` rename break |
| 2026-07-23 | Defer push `init()` until after first frame | Prevent stuck Flutter launch icon |
| 2026-07-23 | Theme via `Theme`/`changeTheme`, not Obx on `GetMaterialApp` | Navigator wipe / stuck splash |
| 2026-07-23 | Disable Impeller on Android | Emulators skipped painting first frame |
| 2026-07-23 | APK-only GitHub Release via Actions on `main` | First release channel |
| 2026-07-24 | Adopt `~/mac/ai/vibe-coding` memory layout | Persistent AI context across chats |
