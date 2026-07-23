# AGENTS.md

> Yaaram (couple-memories-app). Keep under ~150 lines.

## Product

- Name: **Yaaram** (display: Our Love Story)
- One-liner: Private Flutter couple journal — memories, chat, Discover, synced themes
- Related repos: https://github.com/macbuilds-dev/couple-memories-app
- Firebase project: `yaaram-80842`
- Bundle / application ID: `com.yaaram.lovestory`

## Stack

- Language / framework: Dart / Flutter (stable)
- State: GetX
- Backend: Firebase Auth, Cloud Firestore, FCM (+ optional Cloud Functions on Blaze)
- Media: Cloudinary (via `.env`)
- Local: SQLite cache when offline
- Package manager: `flutter pub`
- iOS: Swift Package Manager (min iOS 15), Android: Gradle / Kotlin DSL

## Commands

```bash
flutter pub get
flutter run                    # pick device
flutter build apk --release    # Android APK (CI also publishes on push to main)
firebase deploy --only firestore:rules
# functions (needs Blaze): cd functions && npm i && firebase deploy --only functions
```

## Layout

```
lib/
  controller/     # GetX controllers (auth, memory, chat, live_sync, settings)
  services/       # Firestore, push, couple settings, Cloudinary
  view/           # screens + widgets
  model/          # memory, chat, filters
  routes/         # GetX routes
android/ ios/     # platform
functions/        # FCM on partner alerts (optional deploy)
docs/ai/          # living AI memory (this workflow)
```

## Do not

- Commit secrets (`.env`, private keys); `.env` is gitignored — use `.env.example`
- Drive-by refactors unrelated to the task
- Wrap `GetMaterialApp` in `Obx` (breaks navigator / sticks native splash)
- Await FCM/push init before `runApp()` (blocks launch icon)
- Use `firebase_messaging` ≥ 16.4.2 until FlutterFire rename wave is stable (pin `16.4.1`)
- Force-push `main` unless user explicitly asks
- Exceed **29** commits per session when user asks to commit/push

## Memory

- Before non-trivial work: read `docs/ai/active.md` and this file
- After meaningful work: update `docs/ai/active.md` and `docs/ai/progress.md`
- Show memory file diffs before committing them (recommended)

## Commits / push

Follow `~/mac/ai/vibe-coding/COMMIT_AND_BADGES.md`: max **29** commits/session; prefer feature branch + PR when useful. Owner: **macbuilds-dev**. CI on `main` builds APK-only GitHub Release.
