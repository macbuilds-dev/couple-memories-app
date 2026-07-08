import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';

/// Light app shell — matches home / profile tab (`backgroundGradient`).
class AppScreenShell extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool safeArea;

  const AppScreenShell({
    super.key,
    required this.child,
    this.appBar,
    this.safeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      extendBodyBehindAppBar: appBar != null,
      appBar: appBar,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: safeArea ? SafeArea(child: child) : child,
        ),
      ),
    );
  }
}

/// Outlined inputs for light surfaces (profile, auth, dialogs).
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
    this.maxLength,
    this.onChanged,
  });

  static InputDecoration decoration(String label, {Widget? suffixIcon}) {
    final borderRadius = BorderRadius.circular(AppTheme.radiusMedium);

    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      labelStyle: AppTheme.getBodyStyle(
        fontSize: AppTheme.fontSizeMedium.sp,
        color: AppTheme.textSecondary.withValues(alpha: 0.7),
      ),
      floatingLabelStyle: AppTheme.getBodyStyle(
        fontSize: AppTheme.fontSizeMedium.sp,
        color: AppTheme.secondaryColor,
      ),
      filled: true,
      fillColor: AppTheme.surfaceColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppTheme.secondaryColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: AppTheme.secondaryColor, width: 1.8),
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppTheme.secondaryColor.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      maxLength: maxLength,
      onChanged: onChanged,
      style: AppTheme.getBodyStyle(
        fontSize: AppTheme.fontSizeLarge.sp,
        color: AppTheme.textPrimary,
      ),
      cursorColor: AppTheme.secondaryColor,
      decoration: decoration(label, suffixIcon: suffixIcon),
    );
  }
}
