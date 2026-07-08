import 'package:flutter/material.dart' hide DateUtils;
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import '../../controller/utils/theme/app_theme.dart';
import '../../controller/utils/date_utils.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'memory_card_media.dart';

class MemoryCardWidget extends StatelessWidget {
  final Memory memory;
  final bool showActions;
  final Function(Memory)? onEdit;
  final Function(Memory)? onDelete;

  const MemoryCardWidget({
    Key? key,
    required this.memory,
    this.showActions = true,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MemoryController memoryController = Get.find<MemoryController>();

    return GestureDetector(
      onTap: () {
        NavigationHelper.toMemoryDetail(memory);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 3.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media section
            MemoryCardMedia(mediaFiles: memory.mediaFiles),
            
            // Content section
            Padding(
              padding: EdgeInsets.all(5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 4.w,
                        color: AppTheme.textSecondary.withOpacity(0.6),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        '${memory.date.day} ${DateUtils.getMonthName(memory.date.month)} ${memory.date.year}',
                        style: AppTheme.getCaptionStyle(
                          fontSize: AppTheme.fontSizeSmall.sp,
                          color: AppTheme.textSecondary.withOpacity(0.6),
                        ),
                      ),
                      const Spacer(),
                      if (showActions)
                        PopupMenuButton<String>(
                          icon: Icon(
                            Icons.more_vert,
                            color: AppTheme.textSecondary.withOpacity(0.6),
                            size: 5.w,
                          ),
                          onSelected: (value) {
                            if (value == 'edit' && onEdit != null) {
                              onEdit!(memory);
                            } else if (value == 'delete' && onDelete != null) {
                              onDelete!(memory);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 5.w, color: AppTheme.textSecondary),
                                  SizedBox(width: 2.w),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 5.w, color: Colors.red),
                                  SizedBox(width: 2.w),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 1.5.h),
                  Text(
                    memory.title,
                    style: AppTheme.getHeadingStyle(
                      fontSize: AppTheme.fontSizeXXL.sp,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    memory.description,
                    style: AppTheme.getBodyStyle(
                      fontSize: AppTheme.fontSizeBody.sp,
                      color: AppTheme.textPrimary.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 1.5.h),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 4.w,
                        color: AppTheme.textSecondary.withOpacity(0.6),
                      ),
                      SizedBox(width: 1.w),
                      Expanded(
                        child: Text(
                          memory.location,
                          style: AppTheme.getScriptStyle(
                            fontSize: AppTheme.fontSizeMedium.sp,
                            color: AppTheme.textSecondary.withOpacity(0.8),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => memoryController.toggleFavorite(memory.id),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: memory.isFavorite
                                ? AppTheme.secondaryColor.withOpacity(0.1)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            memory.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: memory.isFavorite
                                ? AppTheme.secondaryColor
                                : AppTheme.textSecondary.withOpacity(0.4),
                            size: 5.w,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}
