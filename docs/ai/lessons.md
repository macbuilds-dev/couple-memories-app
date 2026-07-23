# Lessons

## Do not repeat

- Do not `await` FCM/local-notification setup before `runApp()` — native splash sticks
- Do not wrap `GetMaterialApp` in `Obx` or call `Get.forceAppUpdate()` for theme — resets routes / blank UI
- Do not cast chat `createdAt` as `Timestamp?` — app stores ISO strings
- Do not hot-restart to load new native plugins — full stop + run
- Do not use Messaging “campaign” UI for partner alerts — wrong product surface
- Do not bump `firebase_messaging` past 16.4.1 without verifying FlutterFire core exports
- Commit/push sessions: many small commits, max **29**; don’t invent empty commits for badges
