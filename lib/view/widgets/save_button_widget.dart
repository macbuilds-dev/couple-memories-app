import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controller/utils/theme/app_theme.dart';

class SaveButtonWidget extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const SaveButtonWidget({
    Key? key,
    required this.onPressed,
    this.label = 'Save Memory',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 7.h,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.white,
                ),
                SizedBox(width: 3.w),
                Text(
                  label,
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeLarge.sp,
                    color: Colors.white,
                  ).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
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
