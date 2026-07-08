import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/admin_session_controller.dart';
import 'package:yaaram/controller/utils/admin_auth.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';

Future<bool> showAdminUnlockDialog() async {
  final result = await Get.dialog<bool>(
    const _AdminUnlockDialog(),
    barrierDismissible: false,
  );
  return result == true;
}

class _AdminUnlockDialog extends StatefulWidget {
  const _AdminUnlockDialog();

  @override
  State<_AdminUnlockDialog> createState() => _AdminUnlockDialogState();
}

class _AdminUnlockDialogState extends State<_AdminUnlockDialog> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final valid = await AdminAuth.validateCredentials(
      _usernameController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (valid) {
      Get.find<AdminSessionController>().unlock();
      Get.back(result: true);
      return;
    }

    setState(() {
      _isLoading = false;
      _error = 'Invalid username or password';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      title: Text(
        'Admin Access',
        style: AppTheme.getHeadingStyle(fontSize: AppTheme.fontSizeXL.sp),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter admin credentials to unlock developer tools.',
              style: AppTheme.getBodyStyle(
                fontSize: AppTheme.fontSizeMedium.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
              ),
              textInputAction: TextInputAction.next,
              enabled: !_isLoading,
            ),
            SizedBox(height: 1.5.h),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              onSubmitted: (_) => _submit(),
              enabled: !_isLoading,
            ),
            if (_error != null) ...[
              SizedBox(height: 1.5.h),
              Text(
                _error!,
                style: AppTheme.getCaptionStyle(
                  fontSize: AppTheme.fontSizeSmall.sp,
                  color: Colors.red.shade400,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Get.back(result: false),
          child: Text(
            'Cancel',
            style: AppTheme.getBodyStyle(
              fontSize: AppTheme.fontSizeMedium.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 4.w,
                  height: 4.w,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  'Unlock',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                    color: Colors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }
}
