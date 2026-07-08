import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';
import 'package:yaaram/utils/media_utils.dart';

import '../../controller/utils/theme/app_theme.dart';
import '../../utils/navigation_helper.dart';

class MemoryCardMedia extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final bool showDeleteButton;
  final Function(int)? onDelete;

  const MemoryCardMedia({
    Key? key,
    required this.mediaFiles,
    this.showDeleteButton = false,
    this.onDelete,
  }) : super(key: key);

  @override
  State<MemoryCardMedia> createState() => _MemoryCardMediaState();
}

class _MemoryCardMediaState extends State<MemoryCardMedia> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreen() {
    NavigationHelper.toMediaViewer(
      mediaFiles: widget.mediaFiles,
      initialIndex: _currentPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaFiles.isEmpty) {
      return Container(
        height: 25.h,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXL),
          ),
          gradient: AppTheme.cardGradient,
        ),
        child: Center(
          child: Icon(
            Icons.photo_camera,
            size: 8.w,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      );
    }

    // Single media - full screen on tap
    if (widget.mediaFiles.length == 1) {
      return GestureDetector(
        onTap: _openFullScreen,
        child: Container(
          height: 25.h,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXL),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppTheme.radiusXL),
            ),
            child: _buildMediaWidget(widget.mediaFiles[0], 0),
          ),
        ),
      );
    }

    // Multiple media - carousel with indicators
    return Container(
      height: 25.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXL),
        ),
      ),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.mediaFiles.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: _openFullScreen,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppTheme.radiusXL),
                  ),
                  child: _buildMediaWidget(widget.mediaFiles[index], index),
                ),
              );
            },
          ),
          // Page indicator and dots
          Positioned(
            bottom: 1.5.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page number indicator (e.g., "1/5", "3/7")
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Text(
                    '${_currentPage + 1}/${widget.mediaFiles.length}',
                    style: AppTheme.getCaptionStyle(
                      fontSize: 2.5.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 1.h),
                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.mediaFiles.length,
                    (index) => GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 1.w),
                        width: _currentPage == index ? 6.w : 2.w,
                        height: 2.w,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Delete button overlay for each page
          if (widget.showDeleteButton && widget.onDelete != null)
            Positioned(
              top: 1.h,
              right: 4.w,
              child: GestureDetector(
                onTap: () => widget.onDelete!(_currentPage),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 4.w,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaWidget(MediaFile media, int index) {
    if (media.isImage) {
      return MediaUtils.buildImage(
        path: media.path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    final thumb = MediaUtils.thumbnailSource(media);
    if (thumb != null && media.isRemote) {
      return Stack(
        fit: StackFit.expand,
        children: [
          MediaUtils.buildImage(path: thumb, fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.2)),
          Center(
            child: Icon(Icons.play_arrow, color: Colors.white, size: 10.w),
          ),
        ],
      );
    }
    return _buildVideoThumbnail(media.path, isRemote: media.isRemote);
  }

  Widget _buildVideoThumbnail(String videoPath, {bool isRemote = false}) {
    return FutureBuilder<VideoPlayerController>(
      future: _initializeVideoController(videoPath, isRemote: isRemote),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.value.isInitialized) {
          final controller = snapshot.data!;
          return Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayer(controller),
              Container(
                color: Colors.black.withOpacity(0.2),
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 10.w,
                  ),
                ),
              ),
            ],
          );
        }
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
        );
      },
    );
  }

  Future<VideoPlayerController> _initializeVideoController(
    String path, {
    bool isRemote = false,
  }) async {
    try {
      final controller = isRemote
          ? VideoPlayerController.networkUrl(Uri.parse(path))
          : VideoPlayerController.file(File(path));
      await controller.initialize().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );
      if (controller.value.isInitialized) {
        await controller.setLooping(false);
        await controller.pause();
        await controller.setVolume(0.0); // Mute thumbnail
      }
      return controller;
    } catch (e) {
      print('Error initializing video thumbnail: $e');
      final dummyController = isRemote
          ? VideoPlayerController.networkUrl(Uri.parse(path))
          : VideoPlayerController.file(File(path));
      return dummyController;
    }
  }
}
