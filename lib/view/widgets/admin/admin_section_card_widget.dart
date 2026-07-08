import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../../controller/utils/theme/app_theme.dart';

class AdminSectionCardWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final Color? borderColor;
  final IconData? titleIcon;

  const AdminSectionCardWidget({
    Key? key,
    required this.title,
    required this.child,
    this.borderColor,
    this.titleIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: (borderColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleIcon != null
                ? Row(
                    children: [
                      Icon(titleIcon,
                          color: borderColor ?? AppTheme.secondaryColor,
                          size: 6.w),
                      SizedBox(width: 2.w),
                      Text(
                        title,
                        style: AppTheme.getHeadingStyle(
                                fontSize: AppTheme.fontSizeXL.sp)
                            .copyWith(color: borderColor),
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: AppTheme.getHeadingStyle(
                            fontSize: AppTheme.fontSizeXL.sp)
                        .copyWith(color: borderColor),
                  ),
            SizedBox(height: 2.h),
            child,
          ],
        ),
      ),
    );
  }
}
