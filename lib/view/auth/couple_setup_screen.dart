import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/routes/app_routes.dart';
import 'package:yaaram/view/widgets/app_screen_shell.dart';

class CoupleSetupScreen extends StatefulWidget {
  const CoupleSetupScreen({super.key});

  @override
  State<CoupleSetupScreen> createState() => _CoupleSetupScreenState();
}

class _CoupleSetupScreenState extends State<CoupleSetupScreen> {
  final _codeController = TextEditingController();
  final _auth = Get.find<AuthController>();
  String? _createdCode;
  bool _busy = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createCouple() async {
    setState(() => _busy = true);
    try {
      final code = await _auth.createCouple();
      setState(() => _createdCode = code);
      Get.snackbar('Couple created', 'Share code $code with your partner',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4));
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _joinCouple() async {
    if (_codeController.text.trim().length < 6) {
      Get.snackbar('Error', 'Enter the 6-character couple code');
      return;
    }
    setState(() => _busy = true);
    try {
      await _auth.joinCouple(_codeController.text);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  void _continueAlone() {
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenShell(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(6.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 3.h),
            Text(
              'Link your hearts',
              style: AppTheme.getTitleStyle(
                fontSize: AppTheme.fontSizeTitle.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Create a couple code for your partner, or join theirs. '
              'Memories sync when linked.',
              style: AppTheme.getBodyStyle(
                fontSize: AppTheme.fontSizeMedium.sp,
                color: AppTheme.textPrimary.withValues(alpha: 0.75),
              ),
            ),
                SizedBox(height: 4.h),
                _sectionCard(
                  title: 'Create couple',
                  subtitle: 'Get a code to share',
                  child: Column(
                    children: [
                      if (_createdCode != null) ...[
                        SelectableText(
                          _createdCode!,
                          style: AppTheme.getHeadingStyle(
                            fontSize: AppTheme.fontSizeDisplay.sp,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        TextButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: _createdCode!));
                            Get.snackbar('Copied', 'Code copied to clipboard');
                          },
                          icon: const Icon(Icons.copy),
                          label: const Text('Copy code'),
                        ),
                        SizedBox(height: 2.h),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => Get.offAllNamed(AppRoutes.home),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                            ),
                            child: const Text('Continue to app',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ] else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _busy ? null : _createCouple,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.secondaryColor,
                            ),
                            child: _busy
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Text('Generate couple code',
                                    style: TextStyle(color: Colors.white)),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 3.h),
                _sectionCard(
                  title: 'Join partner',
                  subtitle: 'Enter their 6-character code',
                  child: Column(
                    children: [
                      AppTextField(
                        controller: _codeController,
                        label: 'Couple code',
                        textCapitalization: TextCapitalization.characters,
                        maxLength: 6,
                      ),
                      SizedBox(height: 2.h),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _busy ? null : _joinCouple,
                          child: const Text('Join couple'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Center(
                  child: TextButton(
                    onPressed: _continueAlone,
                    child: Text(
                      'Skip for now (offline mode)',
                      style: AppTheme.getCaptionStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.75),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                TextButton(
                  onPressed: () async {
                    await _auth.signOut();
                    Get.offAllNamed(AppRoutes.welcome);
                  },
                  child: Text(
                    'Sign out',
                    style: AppTheme.getBodyStyle(
                      color: AppTheme.textPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: AppTheme.getHeadingStyle(
                  fontSize: AppTheme.fontSizeXL.sp)),
          Text(subtitle,
              style: AppTheme.getCaptionStyle(
                  color: AppTheme.textSecondary.withOpacity(0.7))),
          SizedBox(height: 2.h),
          child,
        ],
      ),
    );
  }
}
