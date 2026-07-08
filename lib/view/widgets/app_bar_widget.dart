import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/memory_controller.dart';
import '../../controller/utils/theme/app_theme.dart';
import '../../controller/utils/settings/settings_controller.dart';

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final settingsController = Get.find<SettingsController>();
      final memoryController = Get.find<MemoryController>();
      final settings = settingsController.settings.value;
      final daysTogether = memoryController.daysTogether;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      settings.appTitle,
                      style: AppTheme.getHeadingStyle(fontSize: AppTheme.fontSizeHeading.sp),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      settings.appSubtitle,
                      style: AppTheme.getScriptStyle(
                        fontSize: AppTheme.fontSizeMedium.sp,
                        color: AppTheme.textSecondary.withOpacity(0.6),
                      ),
                    ),
                  ),
                  if (daysTogether > 0)
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$daysTogether days together',
                        style: AppTheme.getCaptionStyle(
                          fontSize: AppTheme.fontSizeSmall.sp,
                          color: AppTheme.secondaryColor.withOpacity(0.8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
