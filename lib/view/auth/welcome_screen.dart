import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/utils/settings/settings_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/routes/app_routes.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/widgets/app_logo_widget.dart';
import 'package:yaaram/view/widgets/app_screen_shell.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _routeAfterAuth(AuthController auth) {
    return NavigationHelper.routeAfterAuth(auth);
  }

  Future<void> _continueWithGoogle(AuthController auth) async {
    try {
      await auth.signInWithGoogle();
      await _routeAfterAuth(auth);
    } catch (e) {
      Get.snackbar('Sign in failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();

    return Obx(() {
      final settings = Get.find<SettingsController>().settings.value;
      final isLoading = auth.isLoading.value;

      return AppScreenShell(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const AppLogoWidget(size: 28.0, showShadow: true),
              SizedBox(height: 3.h),
              Text(
                settings.appTitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTheme.getHeadingStyle(
                  fontSize: AppTheme.fontSizeTitle.sp,
                  color: AppTheme.textSecondary,
                ).copyWith(letterSpacing: 2),
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : () => Get.toNamed(AppRoutes.emailAuth),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.secondaryColor,
                    foregroundColor: AppTheme.surfaceColor,
                    padding: EdgeInsets.symmetric(vertical: 2.2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Continue with email',
                    style: AppTheme.getBodyStyle(
                      fontSize: AppTheme.fontSizeLarge.sp,
                      color: AppTheme.surfaceColor,
                    ).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed:
                      isLoading ? null : () => _continueWithGoogle(auth),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.surfaceColor,
                    foregroundColor: AppTheme.textPrimary,
                    padding: EdgeInsets.symmetric(vertical: 2.2.h),
                    side: BorderSide(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.25),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 2.4.h,
                          width: 2.4.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppTheme.secondaryColor,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              SimpleIcons.google,
                              size: 5.w,
                              color: SimpleIconColors.google,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              'Continue with Google',
                              style: AppTheme.getBodyStyle(
                                fontSize: AppTheme.fontSizeLarge.sp,
                                color: AppTheme.textPrimary,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 6.h),
            ],
          ),
        ),
      );
    });
  }
}
