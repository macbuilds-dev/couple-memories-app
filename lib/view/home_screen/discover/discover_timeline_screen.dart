import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/home_screen/discover/discover_widgets.dart';

enum _DismissDirection { left, right, down }

class DiscoverTimelineScreen extends StatefulWidget {
  const DiscoverTimelineScreen({super.key});

  @override
  State<DiscoverTimelineScreen> createState() => _DiscoverTimelineScreenState();
}

class _DiscoverTimelineScreenState extends State<DiscoverTimelineScreen>
    with SingleTickerProviderStateMixin {
  final MemoryController _memoryController = Get.find<MemoryController>();
  final AuthController _auth = Get.find<AuthController>();

  int _topIndex = 0;
  late AnimationController _swapController;
  late Animation<double> _swapAnimation;
  bool _isAnimating = false;
  _DismissDirection _dismissDirection = _DismissDirection.down;

  String? _partnerUid;

  @override
  void initState() {
    super.initState();
    _loadPartner();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _swapAnimation = CurvedAnimation(
      parent: _swapController,
      curve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _swapController.dispose();
    super.dispose();
  }

  Future<void> _loadPartner() async {
    final uid = await _memoryController.partnerUid();
    if (mounted) setState(() => _partnerUid = uid);
  }

  List<Memory> get _discover {
    final uid = _auth.uid ?? '';
    return _memoryController.discoverMemoriesFor(uid, partnerUid: _partnerUid);
  }

  Memory? get _topMemory {
    final list = _discover;
    if (list.isEmpty) return null;
    return list[_topIndex % list.length];
  }

  Offset _dismissOffsetFor(double progress) {
    final size = MediaQuery.sizeOf(context);
    switch (_dismissDirection) {
      case _DismissDirection.left:
        return Offset(-size.width * 1.15 * progress, -20 * progress);
      case _DismissDirection.right:
        return Offset(size.width * 1.15 * progress, -20 * progress);
      case _DismissDirection.down:
        return Offset(0, size.height * 0.75 * progress);
    }
  }

  Future<void> _dismissWithAction(
    _DismissDirection direction,
    Future<void> Function() action,
  ) async {
    if (_isAnimating || _topMemory == null) return;
    setState(() {
      _isAnimating = true;
      _dismissDirection = direction;
    });
    await _swapController.forward();
    await action();
    if (!mounted) return;
    setState(() {
      _topIndex = 0;
      _isAnimating = false;
    });
    _swapController.reset();
  }

  void _openPreview() {
    final memory = _topMemory;
    if (memory == null || _isAnimating) return;
    NavigationHelper.toDiscoverPreview(memory);
  }

  Future<void> _onAddNote() async {
    final memory = _topMemory;
    if (memory == null) return;
    final text = await showQuickNoteDialog(context);
    if (text == null) return;
    await _dismissWithAction(
      _DismissDirection.left,
      () => _memoryController.addDiscoverComment(memory.id, text),
    );
  }

  Future<void> _onLike() async {
    final memory = _topMemory;
    if (memory == null) return;
    await _dismissWithAction(
      _DismissDirection.down,
      () => _memoryController.likeDiscoverMemory(memory.id),
    );
  }

  Future<void> _onStar() async {
    final memory = _topMemory;
    if (memory == null) return;
    await _dismissWithAction(
      _DismissDirection.right,
      () => _memoryController.starDiscoverMemory(memory.id),
    );
  }

  Future<void> _onReplay() async {
    final count = await _memoryController.replayDiscoverMemories();
    if (!mounted) return;
    setState(() => _topIndex = 0);
    Get.snackbar(
      count == 0 ? 'Nothing to replay' : 'Replay started',
      count == 0
          ? 'No dismissed memory cards yet.'
          : 'Showing $count memory card${count == 1 ? '' : 's'} again.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final discover = _discover;
      final loading = _memoryController.isLoading.value;

      if (loading && discover.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          DiscoverHeader(onReplay: _onReplay),
          Expanded(
            child: discover.isEmpty
                ? _EmptyDiscover(onReplay: _onReplay)
                : AnimatedBuilder(
                    animation: _swapAnimation,
                    builder: (context, child) {
                      final progress = _swapAnimation.value;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DiscoverCardStack(
                            memories: discover,
                            topIndex: _topIndex,
                            dismissOffset: _dismissOffsetFor(progress),
                            dismissProgress: progress,
                            onTopCardTap: _openPreview,
                          ),
                          DiscoverActionButtons(
                            onAddNote: _onAddNote,
                            onLike: _onLike,
                            onStar: _onStar,
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}

class _EmptyDiscover extends StatelessWidget {
  final VoidCallback onReplay;

  const _EmptyDiscover({required this.onReplay});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 16.w,
              color: AppTheme.secondaryColor.withValues(alpha: 0.6),
            ),
            SizedBox(height: 2.h),
            Text(
              'You\'re all caught up',
              textAlign: TextAlign.center,
              style: AppTheme.getHeadingStyle(
                fontSize: AppTheme.fontSizeXL.sp,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'New memories from your partner will appear here.',
              textAlign: TextAlign.center,
              style: AppTheme.getBodyStyle(
                fontSize: AppTheme.fontSizeMedium.sp,
                color: AppTheme.textPrimary.withValues(alpha: 0.7),
              ),
            ),
            SizedBox(height: 3.h),
            OutlinedButton.icon(
              onPressed: onReplay,
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Replay memories'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.secondaryColor,
                side: BorderSide(color: AppTheme.secondaryColor),
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.4.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
