import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:video_player/video_player.dart';
import 'package:photo_view/photo_view.dart';
import 'package:chewie/chewie.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';
import 'package:yaaram/utils/media_utils.dart';

import '../../controller/utils/theme/app_theme.dart';

class MediaViewerScreen extends StatefulWidget {
  final List<MediaFile> mediaFiles;
  final int initialIndex;

  const MediaViewerScreen({
    Key? key,
    required this.mediaFiles,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  State<MediaViewerScreen> createState() => _MediaViewerScreenState();
}

class _MediaViewerScreenState extends State<MediaViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeMedia(widget.mediaFiles[_currentIndex]);
  }

  Future<void> _initializeMedia(MediaFile media) async {
    await _disposeControllers();

    if (media.isVideo) {
      try {
        final file = media.isRemote ? null : File(media.path);
        if (!media.isRemote && file != null && !await file.exists()) {
          if (mounted) setState(() {});
          return;
        }

        _videoController = media.isRemote
            ? VideoPlayerController.networkUrl(Uri.parse(media.path))
            : VideoPlayerController.file(file!);

        await _videoController!.initialize().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            _videoController?.dispose();
            _videoController = null;
            throw TimeoutException('Video initialization timeout');
          },
        );

        if (!mounted) {
          await _videoController?.dispose();
          _videoController = null;
          return;
        }

        if (_videoController != null && _videoController!.value.isInitialized) {
          try {
            _chewieController = ChewieController(
              videoPlayerController: _videoController!,
              autoPlay: false,
              looping: false,
              aspectRatio: _videoController!.value.aspectRatio,
              showControls: true,
              showControlsOnInitialize: true,
              allowFullScreen: true,
              allowMuting: true,
              allowPlaybackSpeedChanging: false,
              materialProgressColors: ChewieProgressColors(
                playedColor: AppTheme.secondaryColor,
                handleColor: AppTheme.secondaryColor,
                backgroundColor: Colors.grey,
                bufferedColor: Colors.grey.shade300,
              ),
              errorBuilder: (context, errorMessage) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off, color: Colors.white70, size: 10.w),
                        SizedBox(height: 2.h),
                        Text(
                          'Unable to play this video',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppTheme.fontSizeLarge.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 1.h),
                        Text(
                          'This video format may not be supported on this device.',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppTheme.fontSizeMedium.sp,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 2.h),
                        TextButton.icon(
                          onPressed: () {
                            _disposeControllers();
                            _initializeMedia(media);
                          },
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            'Try Again',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );

            if (mounted) setState(() {});
          } catch (e) {
            print('Error creating Chewie controller: $e');
            await _videoController?.dispose();
            _videoController = null;
            if (mounted) setState(() {});
          }
        }
      } catch (e) {
        print('Error initializing video: $e');
        await _videoController?.dispose();
        _videoController = null;
        if (mounted) setState(() {});
      }
    } else if (mounted) {
      setState(() {});
    }
  }

  Future<void> _disposeControllers() async {
    try {
      _chewieController?.dispose();
      _chewieController = null;
      if (_videoController != null) {
        await _videoController!.pause();
        await _videoController!.dispose();
        _videoController = null;
      }
    } catch (e) {
      print('Error disposing controllers: $e');
      _chewieController = null;
      _videoController = null;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.mediaFiles.length}',
          style: AppTheme.getBodyStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.mediaFiles.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          _initializeMedia(widget.mediaFiles[index]);
        },
        itemBuilder: (context, index) {
          final media = widget.mediaFiles[index];
          if (media.isImage) {
            return PhotoView(
              imageProvider: MediaUtils.imageProvider(media.path),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
            );
          }

          if (_chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized) {
            return Center(child: Chewie(controller: _chewieController!));
          }

          if (_videoController == null) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(5.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.videocam_off, color: Colors.white70, size: 10.w),
                    SizedBox(height: 2.h),
                    Text(
                      'Unable to play this video',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: AppTheme.fontSizeLarge.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        },
      ),
    );
  }
}
