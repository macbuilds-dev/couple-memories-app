import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/home_screen/discover/discover_widgets.dart';

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

  String? _partnerUid;

  @override
  void initState() {
    super.initState();
    _loadPartner();
    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _swapAnimation = CurvedAnimation(
      parent: _swapController,
      curve: Curves.easeInOutCubic,
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

  Future<void> _cycleCard() async {
    final list = _discover;
    if (list.length <= 1 || _isAnimating) return;
    setState(() => _isAnimating = true);
    await _swapController.forward();
    if (!mounted) return;
    setState(() {
      _topIndex = (_topIndex + 1) % list.length;
      _isAnimating = false;
    });
    _swapController.reset();
  }

  Future<void> _dismissWithAction(Future<void> Function() action) async {
    if (_isAnimating || _topMemory == null) return;
    setState(() => _isAnimating = true);
    await _swapController.forward();
    await action();
    if (!mounted) return;
    setState(() {
      _topIndex = 0;
      _isAnimating = false;
    });
    _swapController.reset();
  }

  Future<void> _onAddNote() async {
    final memory = _topMemory;
    if (memory == null) return;
    final text = await showQuickNoteDialog(context);
    if (text == null) return;
    await _dismissWithAction(
      () => _memoryController.addDiscoverComment(memory.id, text),
    );
  }

  Future<void> _onLike() async {
    final memory = _topMemory;
    if (memory == null) return;
    await _dismissWithAction(
      () => _memoryController.likeDiscoverMemory(memory.id),
    );
  }

  Future<void> _onStar() async {
    final memory = _topMemory;
    if (memory == null) return;
    await _dismissWithAction(
      () => _memoryController.starDiscoverMemory(memory.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final discover = _discover;
      final loading = _memoryController.isLoading.value;
      final top = _topMemory;

      if (loading && discover.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
          children: [
            DiscoverHeader(
              currentMemory: top,
              onExpand: top == null
                  ? null
                  : () => NavigationHelper.toDiscoverPreview(top),
            ),
            Expanded(
              child: discover.isEmpty
                  ? _EmptyDiscover()
                  : AnimatedBuilder(
                      animation: _swapAnimation,
                      builder: (context, child) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DiscoverCardStack(
                              memories: discover,
                              topIndex: _topIndex,
                              dismissOffset: -28 * _swapAnimation.value,
                              onTopCardTap: _cycleCard,
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
          ],
        ),
      ),
    );
  }
}
