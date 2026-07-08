import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/config/app_env.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/admin_session_controller.dart';
import 'package:yaaram/controller/couple_chat_controller.dart';
import 'package:yaaram/controller/home_tab_controller.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/controller/utils/settings/settings_controller.dart';
import 'package:yaaram/firebase_options.dart';
import 'package:yaaram/routes/app_routes.dart';

import 'controller/utils/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  runApp(const OurLoveStoryApp());
}

class OurLoveStoryApp extends StatelessWidget {
  const OurLoveStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return Obx(() {
          final _ = Get.find<SettingsController>().settings.value;
          return GetMaterialApp(
            title: 'Our Love Story',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.themeData,
            initialRoute: AppRoutes.splash,
            getPages: AppRoutes.pages,
            defaultTransition: Transition.fadeIn,
          );
        });
      },
    );
  }
}
