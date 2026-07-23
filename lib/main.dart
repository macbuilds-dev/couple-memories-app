import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/config/app_env.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/admin_session_controller.dart';
import 'package:yaaram/controller/couple_chat_controller.dart';
import 'package:yaaram/controller/home_tab_controller.dart';
import 'package:yaaram/controller/live_sync_controller.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/controller/utils/settings/settings_controller.dart';
import 'package:yaaram/firebase_options.dart';
import 'package:yaaram/routes/app_routes.dart';
import 'package:yaaram/services/push_notification_service.dart';

import 'controller/utils/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Must be registered before runApp (background isolate entry point).
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await GoogleSignIn.instance.initialize(
    serverClientId:
        '83467342479-6mj8jnkep30luf77f6dcnjs2fr7nrqc0.apps.googleusercontent.com',
  );

  await AppEnv.load();

  Get.put(AuthController());
  Get.put(MemoryController());
  Get.put(HomeTabController());
  Get.put(CoupleChatController());
  Get.put(AdminSessionController());
  final settingsController = Get.put(SettingsController());
  await settingsController.loadSettings();

  // Register now; init after first frame so launch isn't blocked on FCM.
  Get.put(PushNotificationService());
  Get.put(LiveSyncController());

  runApp(const OurLoveStoryApp());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    unawaited(Get.find<PushNotificationService>().init());
  });
}

class OurLoveStoryApp extends StatelessWidget {
  const OurLoveStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Do NOT wrap GetMaterialApp in Obx — rebuilding it resets the navigator
    // and can leave the native Flutter launch screen stuck on screen.
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return GetMaterialApp(
          title: 'Our Love Story',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,
          themeMode: AppTheme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          getPages: AppRoutes.pages,
          defaultTransition: Transition.fadeIn,
          builder: (context, child) {
            return Obx(() {
              // Rebuild theme only; keep navigator alive.
              final _ = Get.find<SettingsController>().settings.value;
              return Theme(
                data: AppTheme.themeData,
                child: child ?? const SizedBox.shrink(),
              );
            });
          },
        );
      },
    );
  }
}
