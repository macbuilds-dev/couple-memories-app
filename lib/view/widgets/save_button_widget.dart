import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controller/utils/theme/app_theme.dart';

class SaveButtonWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const SaveButtonWidget({
    Key? key,
    required this.onPressed,
    this.label = 'Save Memory',
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              AppTheme.secondaryColor.withValues(alpha: 0.45),
          padding: EdgeInsets.symmetric(vertical: 2.2.h),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                label,
                style: AppTheme.getBodyStyle(
                  fontSize: AppTheme.fontSizeLarge.sp,
                  color: Colors.white,
                ).copyWith(fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
