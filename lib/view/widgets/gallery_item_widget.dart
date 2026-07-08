import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import '../../controller/utils/theme/app_theme.dart';
import '../../model/memory_model/memory_model.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/utils/media_utils.dart';
import 'video_thumbnail_widget.dart';

class GalleryItemWidget extends StatelessWidget {
  final Memory memory;
  final int index;

  const GalleryItemWidget({
    Key? key,
    required this.memory,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firstMedia = memory.mediaFiles.isNotEmpty ? memory.mediaFiles.first : null;
    
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + (index * 100)),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => NavigationHelper.toMemoryDetail(memory),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            gradient: AppTheme.cardGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (firstMedia != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  child: firstMedia.isImage
                      ? MediaUtils.buildImage(
                          path: firstMedia.path,
                          fit: BoxFit.cover,
                        )
                      : VideoThumbnailWidget(
                          videoPath: firstMedia.path,
                          isRemote: firstMedia.isRemote,
                          thumbnailUrl: firstMedia.thumbnailPath,
                        ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (memory.mediaFiles.length > 1)
                        Row(
                          children: [
                            Icon(
                              Icons.collections,
                              size: 4.w,
                              color: Colors.white.withOpacity(0.9),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '${memory.mediaFiles.length}',
                              style: AppTheme.getCaptionStyle(
                                fontSize: AppTheme.fontSizeSmall.sp,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 0.5.h),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            memory.title,
                            style: AppTheme.getHeadingStyle(
                              fontSize: AppTheme.fontSizeMedium.sp,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (firstMedia != null && firstMedia.isVideo)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 8.w,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
