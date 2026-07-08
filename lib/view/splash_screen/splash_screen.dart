import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/firebase_options.dart';
import 'package:yaaram/routes/app_routes.dart';
import 'package:yaaram/controller/utils/settings/settings_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/view/widgets/app_logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _heartController;
  late AnimationController _textController;
  late Animation<double> _heartScale;
  late Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _heartScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.elasticOut),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _heartController.forward();
    Future.delayed(const Duration(milliseconds: 500), _textController.forward);
    Future.delayed(const Duration(seconds: 3), _navigateNext);
  }

  Future<void> _navigateNext() async {
    final auth = Get.find<AuthController>();
    while (!auth.isInitialized.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;

    if (!auth.isLoggedIn) {
      Get.offNamed(AppRoutes.welcome);
      return;
    }
    if (auth.needsProfileOnboarding) {
      Get.offAllNamed(AppRoutes.profileOnboarding);
      return;
    }
    if (!auth.hasCouple) {
      Get.offNamed(AppRoutes.coupleSetup);
      return;
    }
    Get.offNamed(AppRoutes.home);
  }

  @override
  void dispose() {
    _heartController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>().settings.value;
    final daysTogether = Get.find<MemoryController>().daysTogether;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.3),
                AppTheme.accentColor.withValues(alpha: 0.3),
                AppTheme.surfaceColor,
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              ScaleTransition(
                scale: _heartScale,
                child: const AppLogoWidget(size: 25.0, showShadow: true),
              ),
              SizedBox(height: 5.h),
              FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    Text(
                      settings.appTitle,
                      style: AppTheme.getTitleStyle(
                        fontSize: AppTheme.fontSizeDisplay.sp,
                        color: AppTheme.textSecondary,
                      ).copyWith(letterSpacing: 1.5),
                    ),
                    SizedBox(height: 1.5.h),
                    Text(
                      settings.appSubtitle,
                      style: AppTheme.getScriptStyle(
                        fontSize: AppTheme.fontSizeXL.sp,
                        color: AppTheme.textSecondary.withOpacity(0.7),
                      ),
                    ),
                    if (daysTogether > 0) ...[
                      SizedBox(height: 2.h),
                      Text(
                        '$daysTogether days of love',
                        style: AppTheme.getCaptionStyle(
                          fontSize: AppTheme.fontSizeMedium.sp,
                          color: AppTheme.textSecondary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    );
  }
}
