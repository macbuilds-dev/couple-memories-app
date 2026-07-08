import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controller/utils/theme/app_theme.dart';
import '../../model/memory_model/memory_model.dart';

class DeleteMemoryDialog {
  static void show({
    required Memory memory,
    required VoidCallback onConfirm,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        title: Text(
          'Delete Memory?',
          style: AppTheme.getHeadingStyle(fontSize: AppTheme.fontSizeXL.sp),
        ),
        content: Text(
          'This memory will be moved to trash. You can restore it from settings.',
          style: AppTheme.getBodyStyle(fontSize: AppTheme.fontSizeMedium.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: AppTheme.getBodyStyle(
                fontSize: AppTheme.fontSizeMedium.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
            child: Text(
              'Delete',
              style: AppTheme.getBodyStyle(
                fontSize: AppTheme.fontSizeMedium.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
