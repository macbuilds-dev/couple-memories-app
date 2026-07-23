import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/utils/settings/settings_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/utils/media_utils.dart';

class DiscoverHeader extends StatelessWidget {
  final VoidCallback? onReplay;

  const DiscoverHeader({
    super.key,
    this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    final settings = Get.find<SettingsController>().settings.value;

    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 1.h, 4.w, 1.5.h),
      child: Row(
        children: [
          _SquareHeaderButton(
            icon: Icons.replay_rounded,
            onTap: onReplay,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  settings.appTitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.getHeadingStyle(
                    fontSize: AppTheme.fontSizeXL.sp,
                    color: AppTheme.textSecondary,
                  ),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  settings.appSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeSmall.sp,
                    color: AppTheme.textPrimary.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          // Keeps the title visually centered opposite the replay button.
          SizedBox(width: 11.w, height: 11.w),
        ],
      ),
    );
  }
}

class _SquareHeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _SquareHeaderButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: SizedBox(
          width: 11.w,
          height: 11.w,
          child: Icon(icon, color: AppTheme.secondaryColor, size: 5.5.w),
        ),
      ),
    );
  }
}

class DiscoverCardStack extends StatelessWidget {
  final List<Memory> memories;
  final int topIndex;
  final Offset dismissOffset;
  final double dismissProgress;
  final VoidCallback? onTopCardTap;

  const DiscoverCardStack({
    super.key,
    required this.memories,
    required this.topIndex,
    this.dismissOffset = Offset.zero,
    this.dismissProgress = 0,
    this.onTopCardTap,
  });

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) return const SizedBox.shrink();

    final visible = <Memory>[];
    for (var i = 0; i < memories.length && i < 3; i++) {
      visible.add(memories[(topIndex + i) % memories.length]);
    }

    return SizedBox(
      height: 58.h,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          for (var i = visible.length - 1; i >= 0; i--)
            _DiscoverCard(
              memory: visible[i],
              depth: i,
              isTop: i == 0,
              dismissOffset: i == 0 ? dismissOffset : Offset.zero,
              dismissProgress: i == 0 ? dismissProgress : 0,
              onTap: i == 0 ? onTopCardTap : null,
            ),
        ],
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  final Memory memory;
  final int depth;
  final bool isTop;
  final Offset dismissOffset;
  final double dismissProgress;
  final VoidCallback? onTap;

  const _DiscoverCard({
    required this.memory,
    required this.depth,
    required this.isTop,
    this.dismissOffset = Offset.zero,
    this.dismissProgress = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scale = 1 - (depth * 0.05);
    final stackY = depth * 2.2.h;
    final xTilt = depth == 1
        ? 0.04
        : depth == 2
            ? -0.03
            : dismissOffset.dx * 0.00085;
    final dateLabel = DateFormat('MMM d · h:mm a').format(memory.date);
    final firstMedia =
        memory.mediaFiles.isNotEmpty ? memory.mediaFiles.first : null;
    final imageCount = memory.images.length;
    final opacity = (1.0 - dismissProgress).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Transform.translate(
          offset: Offset(dismissOffset.dx, stackY + dismissOffset.dy),
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: xTilt,
              child: GestureDetector(
                onTap: isTop ? onTap : null,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (firstMedia != null && firstMedia.isImage)
                          MediaUtils.buildImage(
                            path: firstMedia.path,
                            fit: BoxFit.cover,
                          )
                        else
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.secondaryColor
                                      .withValues(alpha: 0.45),
                                  AppTheme.surfaceColor.withValues(alpha: 0.9),
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.photo_library_outlined,
                              size: 18.w,
                              color: Colors.white.withValues(alpha: 0.35),
                            ),
                          ),
                        Positioned(
                          top: 2.5.h,
                          left: 4.w,
                          child: _GlassBadge(label: dateLabel),
                        ),
                        if (imageCount > 1)
                          Positioned(
                            right: 3.w,
                            top: 0,
                            bottom: 0,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(
                                  imageCount.clamp(0, 5),
                                  (i) => Container(
                                    margin:
                                        EdgeInsets.symmetric(vertical: 0.4.h),
                                    width: 1.4.w,
                                    height: 1.4.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: i == 0
                                          ? AppTheme.secondaryColor
                                          : Colors.white
                                              .withValues(alpha: 0.45),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.fromLTRB(5.w, 6.h, 5.w, 3.h),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  memory.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.getHeadingStyle(
                                    fontSize: AppTheme.fontSizeXXL.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                if (memory.subtitle.isNotEmpty) ...[
                                  SizedBox(height: 0.6.h),
                                  Text(
                                    memory.subtitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.getBodyStyle(
                                      fontSize: AppTheme.fontSizeMedium.sp,
                                      color: Colors.white
                                          .withValues(alpha: 0.88),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  final String label;

  const _GlassBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.schedule, color: Colors.white, size: 4.w),
              SizedBox(width: 1.5.w),
              Text(
                label,
                style: AppTheme.getCaptionStyle(
                  fontSize: AppTheme.fontSizeSmall.sp,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DiscoverActionButtons extends StatelessWidget {
  final VoidCallback onAddNote;
  final VoidCallback onLike;
  final VoidCallback onStar;

  /// When true, no vertical padding — for straddling a bottom sheet edge.
  final bool edgeAligned;

  /// Diameter of the center (like) button — used to align centers on sheet edge.
  static double centerButtonSize(BuildContext context) => 19.w;

  const DiscoverActionButtons({
    super.key,
    required this.onAddNote,
    required this.onLike,
    required this.onStar,
    this.edgeAligned = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: edgeAligned ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ActionCircle(
            size: 15.w,
            background: Colors.white,
            icon: Icons.chat_bubble_outline,
            iconColor: AppTheme.secondaryColor,
            onTap: onAddNote,
          ),
          SizedBox(width: 6.w),
          _ActionCircle(
            size: 19.w,
            background: AppTheme.secondaryColor,
            icon: Icons.favorite,
            iconColor: Colors.white,
            glow: true,
            onTap: onLike,
          ),
          SizedBox(width: 6.w),
          _ActionCircle(
            size: 15.w,
            background: Colors.white,
            icon: Icons.star_rounded,
            iconColor: const Color(0xFF9B59B6),
            onTap: onStar,
          ),
        ],
      ),
    );
  }
}

class _ActionCircle extends StatelessWidget {
  final double size;
  final Color background;
  final IconData icon;
  final Color iconColor;
  final bool glow;
  final VoidCallback onTap;

  const _ActionCircle({
    required this.size,
    required this.background,
    required this.icon,
    required this.iconColor,
    this.glow = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: background,
            boxShadow: glow
                ? [
                    BoxShadow(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.45),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Icon(icon, color: iconColor, size: size * 0.42),
        ),
      ),
    );
  }
}

Future<String?> showQuickNoteDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) => const _QuickNoteDialog(),
  );
}

@Deprecated('Use showQuickNoteDialog')
Future<String?> showQuickCommentDialog(BuildContext context) =>
    showQuickNoteDialog(context);

class _QuickNoteDialog extends StatefulWidget {
  const _QuickNoteDialog();

  @override
  State<_QuickNoteDialog> createState() => _QuickNoteDialogState();
}

class _QuickNoteDialogState extends State<_QuickNoteDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close([String? result]) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;

    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(5.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a note',
                style: AppTheme.getHeadingStyle(
                  fontSize: AppTheme.fontSizeXL.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _controller,
                maxLines: 3,
                style: AppTheme.getBodyStyle(color: AppTheme.textPrimary),
                cursorColor: AppTheme.secondaryColor,
                decoration: InputDecoration(
                  hintText: 'Say something sweet…',
                  hintStyle: AppTheme.getBodyStyle(
                    color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  ),
                  filled: true,
                  fillColor: AppTheme.surfaceColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.25),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.25),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    borderSide: BorderSide(color: AppTheme.secondaryColor),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _close,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textPrimary,
                        side: BorderSide(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final value = _controller.text.trim();
                        if (value.isEmpty) return;
                        _close(value);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Save note'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
