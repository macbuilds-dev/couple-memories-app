import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:yaaram/controller/memory_controller.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:intl/intl.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import '../widgets/delete_memory_dialog.dart';
import '../../controller/utils/theme/app_theme.dart';
import '../widgets/memory_card_media.dart';
import '../widgets/action_button_widget.dart';

class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;

  const MemoryDetailScreen({Key? key, required this.memory}) : super(key: key);

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  final MemoryController _memoryController = Get.find<MemoryController>();
  late Memory _currentMemory;

  @override
  void initState() {
    super.initState();
    _currentMemory = widget.memory;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Obx(() {
          final memory = _memoryController.memories
              .firstWhereOrNull((m) => m.id == _currentMemory.id) ??
              _currentMemory;
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(memory),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (memory.mediaFiles.isNotEmpty)
                      _buildMediaCarousel(memory),
                    _buildContentSection(memory),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSliverAppBar(Memory memory) {
    return SliverAppBar(
      expandedHeight: memory.mediaFiles.isEmpty ? 20.h : 0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.surfaceColor,
      leading: null,
      automaticallyImplyLeading: false,
      flexibleSpace: memory.mediaFiles.isEmpty
          ? LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool isExpanded = constraints.maxHeight > 15.h;
                
                return FlexibleSpaceBar(
                  titlePadding: EdgeInsets.zero,
                  centerTitle: false,
                  title: isExpanded
                      ? const SizedBox.shrink()
                      : Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.arrow_back,
                                    color: AppTheme.textSecondary,
                                    size: 4.w,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    memory.title,
                                    style: AppTheme.getHeadingStyle(
                                      fontSize: AppTheme.fontSizeXL.sp,
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  ActionButtonWidget(
                                    icon: Icons.share,
                                    onTap: () => _shareMemory(memory),
                                  ),
                                  SizedBox(width: 2.w),
                                  Obx(() {
                                    final mem = _memoryController.memories
                                        .firstWhereOrNull((m) => m.id == _currentMemory.id) ??
                                        memory;
                                    return ActionButtonWidget(
                                      icon: mem.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      onTap: () => _toggleFavorite(mem),
                                      isFavorite: mem.isFavorite,
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.backgroundGradient,
                    ),
                    child: isExpanded
                        ? SafeArea(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () => Get.back(),
                                        child: Container(
                                          padding: EdgeInsets.all(3.w),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.1),
                                                blurRadius: 10,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.arrow_back,
                                            color: AppTheme.textSecondary,
                                            size: 5.w,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          ActionButtonWidget(
                                            icon: Icons.share,
                                            onTap: () => _shareMemory(memory),
                                          ),
                                          SizedBox(width: 3.w),
                                          Obx(() {
                                            final mem = _memoryController.memories
                                                .firstWhereOrNull((m) => m.id == _currentMemory.id) ??
                                                memory;
                                            return ActionButtonWidget(
                                              icon: mem.isFavorite ? Icons.favorite : Icons.favorite_border,
                                              onTap: () => _toggleFavorite(mem),
                                              isFavorite: mem.isFavorite,
                                            );
                                          }),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2.h),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          memory.title,
                                          style: AppTheme.getTitleStyle(
                                            fontSize: AppTheme.fontSizeTitle.sp,
                                          ),
                                        ),
                                        SizedBox(height: 1.h),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 4.w,
                                              color: AppTheme.textSecondary.withOpacity(0.7),
                                            ),
                                            SizedBox(width: 1.w),
                                            Expanded(
                                              child: FittedBox(
                                                fit: BoxFit.scaleDown,
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  memory.location,
                                                  style: AppTheme.getScriptStyle(
                                                    fontSize: AppTheme.fontSizeMedium.sp,
                                                  ),
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
                          )
                        : null,
                  ),
                );
              },
            )
          : null,
    );
  }

  void _toggleFavorite(Memory memory) {
    _memoryController.toggleFavorite(memory.id);
    // Update local state
    setState(() {
      _currentMemory = memory.copyWith(isFavorite: !memory.isFavorite);
    });
    Get.snackbar(
      memory.isFavorite ? 'Removed from favorites' : 'Added to favorites',
      '',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
    );
  }

  void _shareMemory(Memory memory) {
    final shareText =
        '💕 ${memory.title}\n\n${memory.description}\n\n📍 ${memory.location}\n📅 ${DateFormat('MMM dd, yyyy').format(memory.date)}';
    Clipboard.setData(ClipboardData(text: shareText));
    Get.snackbar(
      'Copied to clipboard',
      'Memory details ready to share',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildMediaCarousel(Memory memory) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Column(
        children: [
          // Top action bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(2.5.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: AppTheme.textSecondary,
                      size: 4.5.w,
                    ),
                  ),
                ),
                Row(
                  children: [
                    ActionButtonWidget(
                      icon: Icons.share,
                      onTap: () => _shareMemory(memory),
                    ),
                    SizedBox(width: 2.w),
                    Obx(() {
                      final mem = _memoryController.memories
                          .firstWhereOrNull((m) => m.id == _currentMemory.id) ??
                          memory;
                      return ActionButtonWidget(
                        icon: mem.isFavorite ? Icons.favorite : Icons.favorite_border,
                        onTap: () => _toggleFavorite(mem),
                        isFavorite: mem.isFavorite,
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          // Media carousel with indicators (like timeline tab)
          Container(
            margin: EdgeInsets.symmetric(horizontal: 5.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              child: MemoryCardMedia(
                mediaFiles: memory.mediaFiles,
                showDeleteButton: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection(Memory memory) {
    return Obx(() {
      final mem = _memoryController.memories
          .firstWhereOrNull((m) => m.id == _currentMemory.id) ??
          memory;
      return FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                mem.title,
                style: AppTheme.getTitleStyle(
                  fontSize: AppTheme.fontSizeTitle.sp,
                ),
              ),
              SizedBox(height: 2.h),
              // Date and Location - Wrap in smaller screens
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 300;
                  if (isWide) {
                    return Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGradient,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 4.w,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: 1.5.w),
                                Flexible(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      DateFormat('MMM dd, yyyy').format(mem.date),
                                      style: AppTheme.getCaptionStyle(
                                        fontSize: AppTheme.fontSizeSmall.sp,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              gradient: AppTheme.cardGradient,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 4.w,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: 1.5.w),
                                Expanded(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      mem.location,
                                      style: AppTheme.getCaptionStyle(
                                        fontSize: AppTheme.fontSizeSmall.sp,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 4.w,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: 1.5.w),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    DateFormat('MMM dd, yyyy').format(mem.date),
                                    style: AppTheme.getCaptionStyle(
                                      fontSize: AppTheme.fontSizeSmall.sp,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            gradient: AppTheme.cardGradient,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 4.w,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: 1.5.w),
                              Expanded(
                                child: Text(
                                  mem.location,
                                  style: AppTheme.getCaptionStyle(
                                    fontSize: AppTheme.fontSizeSmall.sp,
                                    color: AppTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 3.h),
              // Description
              if (mem.description.isNotEmpty) ...[
                Text(
                  'Story',
                  style: AppTheme.getHeadingStyle(
                    fontSize: AppTheme.fontSizeXL.sp,
                  ),
                ),
                SizedBox(height: 1.5.h),
                Text(
                  mem.description,
                  style: AppTheme.getBodyStyle(
                    fontSize: AppTheme.fontSizeMedium.sp,
                    color: AppTheme.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
              SizedBox(height: 3.h),
              _buildActionButtons(mem),
              SizedBox(height: 2.h),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons(Memory memory) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => NavigationHelper.toAddMemory(memoryToEdit: memory),
            icon: Icon(Icons.edit, size: 5.w, color: AppTheme.secondaryColor),
            label: Text(
              'Edit',
              style: AppTheme.getBodyStyle(
                fontSize: AppTheme.fontSizeMedium.sp,
                color: AppTheme.secondaryColor,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              side: BorderSide(color: AppTheme.secondaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              DeleteMemoryDialog.show(
                memory: memory,
                onConfirm: () {
                  _memoryController.deleteMemory(memory.id);
                  Get.back();
                },
              );
            },
            icon: Icon(Icons.delete_outline, size: 5.w, color: Colors.white),
            label: Text(
              'Delete',
              style: AppTheme.getBodyStyle(
                fontSize: AppTheme.fontSizeMedium.sp,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              padding: EdgeInsets.symmetric(vertical: 1.5.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          ),
        ),
      ],
    );
  }

}