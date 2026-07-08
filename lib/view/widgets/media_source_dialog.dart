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
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 1.h),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Add Media',
                    style: AppTheme.getHeadingStyle(
                      fontSize: AppTheme.fontSizeXL.sp,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppTheme.textSecondary),
                title: Text(
                  'Take Photo',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                  ),
                ),
                onTap: () {
                  Get.back();
                  onTakePhoto();
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, color: AppTheme.textSecondary),
                title: Text(
                  'Record Video',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                  ),
                ),
                onTap: () {
                  Get.back();
                  onRecordVideo();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppTheme.textSecondary),
                title: Text(
                  'Choose Photos',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                  ),
                ),
                onTap: () {
                  Get.back();
                  onChoosePhotos();
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library, color: AppTheme.textSecondary),
                title: Text(
                  'Choose Video',
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                  ),
                ),
                onTap: () {
                  Get.back();
                  onChooseVideo();
                },
              ),
              SizedBox(height: 1.h),
            ],
          ),
        ),
      ),
    );
  }
}
