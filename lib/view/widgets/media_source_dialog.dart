import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controller/utils/theme/app_theme.dart';

class MediaSourceDialog {
  static void show({
    required VoidCallback onTakePhoto,
    required VoidCallback onRecordVideo,
    required VoidCallback onChoosePhotos,
    required VoidCallback onChooseVideo,
  }) {
    Get.dialog(
      Dialog(
        backgroundColor: AppTheme.surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(2.w, 2.h, 2.w, 1.5.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(3.w, 0.5.h, 3.w, 1.h),
                child: Text(
                  'Add media',
                  style: AppTheme.getHeadingStyle(
                    fontSize: AppTheme.fontSizeXL.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              _option(
                icon: Icons.camera_alt_outlined,
                label: 'Take photo',
                onTap: onTakePhoto,
              ),
              _option(
                icon: Icons.videocam_outlined,
                label: 'Record video',
                onTap: onRecordVideo,
              ),
              _option(
                icon: Icons.photo_library_outlined,
                label: 'Choose photos',
                onTap: onChoosePhotos,
              ),
              _option(
                icon: Icons.video_library_outlined,
                label: 'Choose video',
                onTap: onChooseVideo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _option({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.secondaryColor),
      title: Text(
        label,
        style: AppTheme.getBodyStyle(
          fontSize: AppTheme.fontSizeMedium.sp,
          color: AppTheme.textPrimary,
        ),
      ),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }
}
