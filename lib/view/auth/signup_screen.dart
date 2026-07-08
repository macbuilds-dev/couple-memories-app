import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = Get.find<AuthController>();
  bool _obscure = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your name');
      return;
    }
    try {
      await _auth.signUp(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
      );
      Get.offAllNamed(AppRoutes.coupleSetup);
    } catch (e) {
      Get.snackbar('Signup failed', e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.textSecondary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(6.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Create account',
                    style: AppTheme.getTitleStyle(
                        fontSize: AppTheme.fontSizeTitle.sp)),
                SizedBox(height: 1.h),
                Text('Start your shared love story',
                    style: AppTheme.getScriptStyle(
                        fontSize: AppTheme.fontSizeLarge.sp,
                        color: AppTheme.textSecondary.withOpacity(0.7))),
                SizedBox(height: 4.h),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                SizedBox(height: 2.h),
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
                    labelText: 'Password (min 6 chars)',
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
                        onPressed: _auth.isLoading.value ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                          padding: EdgeInsets.symmetric(vertical: 2.h),
                        ),
                        child: _auth.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text('Sign Up',
                                style: AppTheme.getBodyStyle(
                                    color: Colors.white,
                                    fontSize: AppTheme.fontSizeLarge.sp)),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
