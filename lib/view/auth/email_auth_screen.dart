import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/widgets/app_screen_shell.dart';

class EmailAuthScreen extends StatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  State<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends State<EmailAuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = Get.find<AuthController>();
  bool _obscure = true;
  bool _isSignUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _routeAfterAuth() {
    return NavigationHelper.routeAfterAuth(_auth);
  }

  Future<void> _submit() async {
    try {
      if (_isSignUp) {
        if (_nameController.text.trim().isEmpty) {
          Get.snackbar('Error', 'Please enter your name');
          return;
        }
        await _auth.signUp(
          _emailController.text,
          _passwordController.text,
          _nameController.text,
        );
      } else {
        await _auth.signIn(_emailController.text, _passwordController.text);
      }
      await _routeAfterAuth();
    } catch (e) {
      Get.snackbar(
        _isSignUp ? 'Signup failed' : 'Login failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScreenShell(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textSecondary),
          onPressed: () => Get.back(),
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(6.w, 2.h, 6.w, 4.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isSignUp ? 'Create account' : 'Welcome back',
              style: AppTheme.getTitleStyle(
                fontSize: AppTheme.fontSizeTitle.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            if (_isSignUp) ...[
              AppTextField(
                controller: _nameController,
                label: 'Your name',
              ),
              SizedBox(height: 2.5.h),
            ],
            AppTextField(
              controller: _emailController,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 2.5.h),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: _obscure,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.secondaryColor,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            SizedBox(height: 5.h),
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _auth.isLoading.value ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      elevation: 0,
                    ),
                    child: _auth.isLoading.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isSignUp ? 'Sign Up' : 'Sign In',
                            style: AppTheme.getBodyStyle(
                              color: Colors.white,
                              fontSize: AppTheme.fontSizeLarge.sp,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                  ),
                )),
            SizedBox(height: 2.h),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp
                      ? 'Already have an account? Sign in'
                      : 'New here? Create an account',
                  style: AppTheme.getBodyStyle(color: AppTheme.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
