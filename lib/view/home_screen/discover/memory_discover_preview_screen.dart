import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/services/couple_chat_service.dart';
import 'package:yaaram/utils/media_utils.dart';
import 'package:yaaram/view/home_screen/discover/discover_widgets.dart';

class MemoryDiscoverPreviewScreen extends StatefulWidget {
  final Memory memory;

  const MemoryDiscoverPreviewScreen({super.key, required this.memory});

  @override
  State<MemoryDiscoverPreviewScreen> createState() =>
      _MemoryDiscoverPreviewScreenState();
}

class _MemoryDiscoverPreviewScreenState
    extends State<MemoryDiscoverPreviewScreen> {
  static const _defaultSheetSize = 0.58;
  static const _minSheetSize = 0.38;
  static const _maxSheetSize = 0.92;

  final _sheetController = DraggableScrollableController();
  double _sheetSize = _defaultSheetSize;
  bool _aboutExpanded = false;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<MemoryController>().markNotesSeen(widget.memory.id);
    });
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetChanged);
    _sheetController.dispose();
    super.dispose();
  }

  void _onSheetChanged() {
    if (!_sheetController.isAttached) return;
    final size = _sheetController.size;
    if ((size - _sheetSize).abs() > 0.005) {
      setState(() => _sheetSize = size);
    }
  }

  Memory get _live {
    final controller = Get.find<MemoryController>();
    return controller.memories
            .firstWhereOrNull((m) => m.id == widget.memory.id) ??
        widget.memory;
  }

  String get _subtitleSnippet {
    final text = _live.subtitle.trim();
    if (text.isEmpty) return _live.location.trim();
    if (text.length <= 56) return text;
    return '${text.substring(0, 56).trim()}…';
  }

  String get _aboutText {
    final text = _live.description.trim();
    return text.isNotEmpty ? text : 'No extra details for this memory yet.';
  }

  Future<void> _dismissAfter(Future<void> Function() action) async {
    await action();
    if (mounted) Get.back(result: 'acted');
  }

  Future<void> _onAddNote() async {
    final text = await showQuickNoteDialog(context);
    if (text == null) return;
    await _dismissAfter(
      () => Get.find<MemoryController>().addDiscoverComment(_live.id, text),
    );
  }

  Future<void> _onLike() async {
    await _dismissAfter(
      () => Get.find<MemoryController>().likeDiscoverMemory(_live.id),
    );
  }

  Future<void> _onStar() async {
    await _dismissAfter(
      () => Get.find<MemoryController>().starDiscoverMemory(_live.id),
    );
  }

  void _openFullScreenImage(String path) {
    Get.to(
      () => _FullscreenMemoryImage(path: path),
      transition: Transition.fadeIn,
    );
  }

  Future<void> _sendToPartner() async {
    final auth = Get.find<AuthController>();
    final coupleId = auth.coupleId;
    if (coupleId == null) {
      Get.snackbar('Not linked', 'Connect with your partner first.');
      return;
    }

    setState(() => _isSending = true);
    try {
      await CoupleChatService.instance.sendMemoryShare(
        coupleId: coupleId,
        memory: _live,
      );
      final partnerName = await CoupleChatService.instance
              .partnerDisplayName(auth.uid ?? '') ??
          'your partner';
      Get.snackbar(
        'Sent',
        'Memory shared with $partnerName in chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Could not send', e.toString());
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final live = _live;
    final firstImage = live.images.isNotEmpty ? live.images.first.path : null;
    final dateBadge = DateFormat('MMM d · h:mm a').format(live.date);
    final topInset = MediaQuery.paddingOf(context).top;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final sheetColor = AppTheme.surfaceColor;
    final sheetTop = screenHeight * (1 - _sheetSize);
    final centerBtn = DiscoverActionButtons.centerButtonSize(context);
    // Center of buttons sits exactly on the sheet's top edge.
    final actionTop = sheetTop - centerBtn / 2;

    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: screenHeight * _sheetSize,
            child: GestureDetector(
              onTap: firstImage != null
                  ? () => _openFullScreenImage(firstImage)
                  : null,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (firstImage != null)
                    MediaUtils.buildImage(path: firstImage, fit: BoxFit.cover)
                  else
                    Container(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.25),
                      child: Icon(
                        Icons.photo_outlined,
                        size: 20.w,
                        color: Colors.white38,
                      ),
                    ),
                  if (firstImage != null)
                    Positioned(
                      right: 4.w,
                      bottom: 2.h,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.8.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSmall),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fullscreen, color: Colors.white, size: 4.w),
                            SizedBox(width: 1.5.w),
                            Text(
                              'Full screen',
                              style: AppTheme.getCaptionStyle(
                                fontSize: AppTheme.fontSizeSmall.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            controller: _sheetController,
            initialChildSize: _defaultSheetSize,
            minChildSize: _minSheetSize,
            maxChildSize: _maxSheetSize,
            snap: true,
            snapSizes: const [_defaultSheetSize, _maxSheetSize],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: sheetColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusXXXL),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(5.w, centerBtn / 2 + 1.h, 5.w, 4.h),
                  children: [
                    Center(
                      child: Container(
                        width: 10.w,
                        height: 0.5.h,
                        margin: EdgeInsets.only(bottom: 2.h),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                live.title,
                                style: AppTheme.getHeadingStyle(
                                  fontSize: AppTheme.fontSizeXXL.sp,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              if (_subtitleSnippet.isNotEmpty) ...[
                                SizedBox(height: 0.6.h),
                                Text(
                                  _subtitleSnippet,
                                  style: AppTheme.getBodyStyle(
                                    fontSize: AppTheme.fontSizeMedium.sp,
                                    color: AppTheme.textPrimary.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 3.w),
                        _SendButton(
                          loading: _isSending,
                          onTap: _sendToPartner,
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Location',
                      style: AppTheme.getBodyStyle(
                        fontSize: AppTheme.fontSizeLarge.sp,
                        color: AppTheme.textSecondary,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            live.location.trim().isNotEmpty
                                ? live.location.trim()
                                : 'No location added',
                            style: AppTheme.getBodyStyle(
                              fontSize: AppTheme.fontSizeMedium.sp,
                              color: AppTheme.textPrimary.withValues(alpha: 0.75),
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        _DatePill(label: dateBadge),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'About',
                      style: AppTheme.getBodyStyle(
                        fontSize: AppTheme.fontSizeLarge.sp,
                        color: AppTheme.textSecondary,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      _aboutText,
                      maxLines: _aboutExpanded ? null : 4,
                      overflow: _aboutExpanded
                          ? TextOverflow.visible
                          : TextOverflow.ellipsis,
                      style: AppTheme.getBodyStyle(
                        fontSize: AppTheme.fontSizeMedium.sp,
                        color: AppTheme.textPrimary.withValues(alpha: 0.88),
                      ),
                    ),
                    if (_aboutText.length > 140) ...[
                      SizedBox(height: 0.8.h),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _aboutExpanded = !_aboutExpanded),
                        child: Text(
                          _aboutExpanded ? 'Show less' : 'Read more',
                          style: AppTheme.getBodyStyle(
                            fontSize: AppTheme.fontSizeMedium.sp,
                            color: AppTheme.secondaryColor,
                          ).copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                    if (live.comments.isNotEmpty) ...[
                      SizedBox(height: 3.h),
                      Text(
                        'Notes',
                        style: AppTheme.getBodyStyle(
                          fontSize: AppTheme.fontSizeLarge.sp,
                          color: AppTheme.textSecondary,
                        ).copyWith(fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 1.h),
                      ...live.comments.map(
                        (c) => Padding(
                          padding: EdgeInsets.only(bottom: 1.h),
                          child: Text(
                            c.text,
                            style: AppTheme.getBodyStyle(
                              fontSize: AppTheme.fontSizeBody.sp,
                              color: AppTheme.textPrimary.withValues(alpha: 0.85),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          Positioned(
            top: topInset + 1.5.h,
            left: 4.w,
            child: _GlassIconButton(
              icon: Icons.chevron_left,
              onTap: () => Get.back(),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: actionTop,
            child: DiscoverActionButtons(
              onAddNote: _onAddNote,
              onLike: _onLike,
              onStar: _onStar,
              edgeAligned: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenMemoryImage extends StatelessWidget {
  final String path;

  const _FullscreenMemoryImage({required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PhotoView(
        imageProvider: MediaUtils.imageProvider(path),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.white.withValues(alpha: 0.22),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 11.w,
              height: 11.w,
              child: Icon(icon, color: Colors.white, size: 6.w),
            ),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _SendButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        child: SizedBox(
          width: 12.w,
          height: 12.w,
          child: loading
              ? Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.secondaryColor,
                  ),
                )
              : Icon(
                  Icons.send_rounded,
                  color: AppTheme.secondaryColor,
                  size: 5.5.w,
                ),
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String label;

  const _DatePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.9.h),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppTheme.secondaryColor.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, color: AppTheme.secondaryColor, size: 3.8.w),
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
    );
  }
}
