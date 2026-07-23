# Active context

## Current focus

- Partner realtime (streams + alerts) and push plumbing are in place
- First APK-only release published (`v1.0.0-build.7`)
- Vibe-coding AI memory bootstrap for this repo

## Recent changes

- FCM + local notifications; `LiveSyncController`; alerts rules + Functions stub
- Live couple membership + partner profile watches
- Couple theme/settings sync; Discover gestures; Moments saved/noted filters
- Launch-screen fixes: no Obx around `GetMaterialApp`; deferred push init; Impeller off on Android emulator
- 18 commits pushed to `main`; CI APK release

## Next steps

- Deploy Firestore rules (if not already) + Functions on Blaze when background push needed
- APNs key in Firebase Console for physical iOS push
- Test partner A (iOS sim) ↔ partner B (Android emu) live chat/memories
- Optional: feature-branch + PR workflow for Pull Shark (per vibe-coding)

## Blockers

- iOS Simulator: no APNS token (expected) — in-app streams still work
- Background FCM needs Blaze Functions + APNs (iOS) / Play services (Android)
