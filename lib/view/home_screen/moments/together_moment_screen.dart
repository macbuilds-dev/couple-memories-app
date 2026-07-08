import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/utils/settings/settings_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/utils/media_utils.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/widgets/app_screen_shell.dart';

class TogetherMomentScreen extends StatelessWidget {
  final Memory memory;

  const TogetherMomentScreen({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>().settings.value;
    final images = memory.images;
    final imageA = images.isNotEmpty ? images.first.path : null;
    final imageB = images.length > 1 ? images[1].path : imageA;

    return AppScreenShell(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 6.w),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            SizedBox(
              height: 38.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (imageB != null)
                    Positioned(
                      left: 0,
                      bottom: 2.h,
                      child: Transform.rotate(
                        angle: -0.12,
                        child: _TiltedPhoto(path: imageB, width: 44.w),
                      ),
                    ),
                  if (imageA != null)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Transform.rotate(
                        angle: 0.14,
                        child: _TiltedPhoto(path: imageA, width: 44.w),
                      ),
                    ),
                  Positioned(
                    left: 8.w,
                    top: 6.h,
                    child: _HeartBadge(),
                  ),
                  Positioned(
                    right: 10.w,
                    bottom: 4.h,
                    child: _HeartBadge(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'A moment together!',
              textAlign: TextAlign.center,
              style: AppTheme.getHeadingStyle(
                fontSize: AppTheme.fontSizeTitle.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              memory.title,
              textAlign: TextAlign.center,
              style: AppTheme.getHeadingStyle(
                fontSize: AppTheme.fontSizeXL.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Relive this ${settings.appTitle} memory you both shared.',
              textAlign: TextAlign.center,
              style: AppTheme.getBodyStyle(
                fontSize: AppTheme.fontSizeMedium.sp,
                color: AppTheme.textPrimary.withValues(alpha: 0.75),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => NavigationHelper.toDiscoverPreview(memory),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                ),
                child: Text(
                  'Start feeling that moment',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeLarge.sp,
                    color: Colors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textPrimary,
                  side: BorderSide(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.4),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 2.2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                ),
                child: Text(
                  'Keep exploring moments',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeLarge.sp,
                    color: AppTheme.textPrimary,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }
}

class _TiltedPhoto extends StatelessWidget {
  final String path;
  final double width;

  const _TiltedPhoto({required this.path, required this.width});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: SizedBox(
        width: width,
        height: width * 1.25,
        child: MediaUtils.buildImage(path: path, fit: BoxFit.cover),
      ),
    );
  }
}

class _HeartBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.12),
            blurRadius: 8,
          ),
        ],
      ),
      child: Icon(Icons.favorite, color: AppTheme.secondaryColor, size: 5.w),
    );
  }
}
