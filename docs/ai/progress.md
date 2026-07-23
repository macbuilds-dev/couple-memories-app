# Progress

## Works

- Auth, couple link, memories CRUD + Discover/Moments/Chat/Profile
- Firestore realtime for memories/messages/settings
- Partner notify hooks + live sync banners (app open)
- Android release APK via CI (APK-only GitHub Release)
- Theme palettes + light/dark sync between partners

## Left to do

- Reliable background push (deploy Functions, Blaze, APNs key)
- Soft-delete cleanup in SQLite cache when docs leave query
- Memory `reminderAt` scheduling (field exists, no notifier yet)
- Prefer PR flow for future changes (vibe-coding badges)

## Known issues

- Hot restart after native plugin adds → `MissingPluginException` (need cold run)
- FlutterFire `firebase_messaging` 16.4.2+ `FirebasePlugin` break — pinned to 16.4.1
- Emulator Impeller can stick native splash — disabled on Android; avoid Obx/`forceAppUpdate` on `GetMaterialApp`
- Chat `createdAt` stored as ISO string — parse with helpers, don’t cast to `Timestamp` only
