import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/utils/media_utils.dart';

class MomentCardWidget extends StatelessWidget {
  final Memory memory;
  final bool isLiked;
  final bool showOwnerActions;
  final VoidCallback onTap;
  final VoidCallback onLike;
  final VoidCallback onAddNote;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReminder;

  const MomentCardWidget({
    super.key,
    required this.memory,
    required this.isLiked,
    required this.showOwnerActions,
    required this.onTap,
    required this.onLike,
    required this.onAddNote,
    this.onEdit,
    this.onDelete,
    this.onReminder,
  });

  @override
  Widget build(BuildContext context) {
    final image = memory.images.isNotEmpty ? memory.images.first.path : null;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (image != null)
              MediaUtils.buildImage(path: image, fit: BoxFit.cover)
            else
              Container(
                color: AppTheme.secondaryColor.withValues(alpha: 0.25),
                child: Icon(
                  Icons.photo_outlined,
                  color: Colors.white38,
                  size: 12.w,
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 6.h,
              child: Container(
                padding: EdgeInsets.fromLTRB(3.w, 5.h, 3.w, 1.2.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.82),
                    ],
                  ),
                ),
                child: Text(
                  memory.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                    color: Colors.white,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (memory.isTogetherMoment)
              Positioned(
                top: 2.w,
                right: 2.w,
                child: Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: AppTheme.secondaryColor,
                    size: 4.w,
                  ),
                ),
              ),
            if (showOwnerActions)
              Positioned(
                top: 2.w,
                left: 2.w,
                child: _OwnerMenu(
                  onEdit: onEdit,
                  onDelete: onDelete,
                  onReminder: onReminder,
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    height: 6.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border(
                        top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: onAddNote,
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.white,
                              size: 5.w,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: double.infinity,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: onLike,
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked
                                  ? AppTheme.secondaryColor
                                  : Colors.white,
                              size: 5.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onReminder;

  const _OwnerMenu({this.onEdit, this.onDelete, this.onReminder});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: Container(
        padding: EdgeInsets.all(1.5.w),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.more_horiz, color: Colors.white, size: 4.5.w),
      ),
      color: AppTheme.surfaceColor,
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit?.call();
          case 'delete':
            onDelete?.call();
          case 'reminder':
            onReminder?.call();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Text('Edit', style: AppTheme.getBodyStyle()),
        ),
        PopupMenuItem(
          value: 'reminder',
          child: Text('Set reminder', style: AppTheme.getBodyStyle()),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Text(
            'Delete',
            style: AppTheme.getBodyStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }
}
