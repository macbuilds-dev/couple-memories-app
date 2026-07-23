# Architecture

## Components

- **UI:** Flutter views + GetX controllers (`MemoryController`, `CoupleChatController`, `AuthController`, `SettingsController`, `LiveSyncController`, `PushNotificationService`)
- **Realtime UI:** Firestore `.snapshots()` on memories, messages, couple `appSettings`, memberIds, partner profile
- **Push:** Client writes `users/{partnerUid}/alerts/*` → optional Cloud Function sends FCM; local notifications for foreground/away-tab
- **Offline:** SQLite via `DatabaseService`; cloud preferred when couple linked + online

## Data stores

| Store | Use |
|-------|-----|
| Firestore `users/{uid}` | auth profile, `coupleId`, `fcmToken`, nicknames |
| Firestore `users/{uid}/alerts` | partner-created push/in-app alerts |
| Firestore `couples/{code}` | `memberIds`, `appSettings` |
| Firestore `couples/{id}/memories` | memories (+ likes/notes/favorites/viewedBy) |
| Firestore `couples/{id}/messages` | chat (`createdAt` often ISO **string**) |
| SQLite | local cache |
| SharedPreferences | local settings mirror |

## Integrations

- Firebase Auth / Firestore / Messaging
- Cloudinary (`.env`)
- Google Sign-In (server client id in `main.dart`)
- GitHub Actions: release APK on push to `main`
