import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/utils/settings/settings_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';

/// Shared dark auth gradient + full-bleed layout for welcome / email / couple screens.
class AuthScreenShell extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final bool safeArea;

  const AuthScreenShell({
    super.key,
    required this.child,
    this.appBar,
    this.safeArea = true,
  });

  static List<Color> gradientColors() {
    final palette = Get.find<SettingsController>().settings.value.selectedPalette;
    return [
      Color.alphaBlend(
        palette.secondaryColor.withValues(alpha: 0.55),
        palette.textPrimary,
      ),
      Color.alphaBlend(
        palette.primaryColor.withValues(alpha: 0.35),
        palette.textPrimary,
      ),
    ];
  }

  static Color scaffoldColor() => gradientColors().last;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final colors = gradientColors();
      final content = safeArea ? SafeArea(child: child) : child;

      return Scaffold(
        backgroundColor: colors.last,
        extendBodyBehindAppBar: appBar != null,
        appBar: appBar,
        body: SizedBox.expand(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
            ),
            child: content,
          ),
        ),
      );
    });
  }
}

/// Outlined inputs matching the profile/login reference (label on border, dark bg).
class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const AuthTextField({
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
    final accent = AppTheme.secondaryColor;
    final borderRadius = BorderRadius.circular(AppTheme.radiusMedium);

    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      labelStyle: AppTheme.getBodyStyle(
        fontSize: AppTheme.fontSizeMedium.sp,
        color: AppTheme.onDarkCaption,
      ),
      floatingLabelStyle: AppTheme.getBodyStyle(
        fontSize: AppTheme.fontSizeMedium.sp,
        color: AppTheme.onDarkBody,
      ),
      filled: false,
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppTheme.onDarkBorder,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: accent, width: 1.8),
      ),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: AppTheme.onDarkBorder,
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
        color: Colors.white,
      ),
      cursorColor: AppTheme.secondaryColor,
      decoration: decoration(label, suffixIcon: suffixIcon),
    );
  }
}
