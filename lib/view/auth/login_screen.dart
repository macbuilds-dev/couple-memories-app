import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/routes/app_routes.dart';
import 'package:yaaram/utils/navigation_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = Get.find<AuthController>();
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      await _auth.signIn(_emailController.text, _passwordController.text);
      _routeAfterAuth();
    } catch (e) {
      Get.snackbar('Login failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _routeAfterAuth() {
    if (_auth.hasCouple) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.coupleSetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4.h),
                Text('Welcome back',
                    style: AppTheme.getTitleStyle(
                        fontSize: AppTheme.fontSizeTitle.sp)),
                SizedBox(height: 1.h),
                Text('Sign in to your love story',
                    style: AppTheme.getScriptStyle(
                        fontSize: AppTheme.fontSizeLarge.sp,
                        color: AppTheme.textSecondary.withOpacity(0.7))),
                SizedBox(height: 5.h),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                SizedBox(height: 2.h),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _auth.isLoading.value ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                        child: _auth.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('Sign In',
                                style: AppTheme.getBodyStyle(
                                    color: Colors.white,
                                    fontSize: AppTheme.fontSizeLarge.sp)),
                      ),
                    )),
                SizedBox(height: 2.h),
                TextButton(
                  onPressed: () => NavigationHelper.toSignup(),
                  child: Text('Create an account',
                      style: AppTheme.getBodyStyle(
                          color: AppTheme.secondaryColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
