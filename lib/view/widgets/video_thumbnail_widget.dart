import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:yaaram/utils/media_utils.dart';
import '../../controller/utils/theme/app_theme.dart';

class VideoThumbnailWidget extends StatelessWidget {
  final String videoPath;
  final bool isRemote;
  final String? thumbnailUrl;
  final BoxFit fit;

  const VideoThumbnailWidget({
    super.key,
    required this.videoPath,
    this.isRemote = false,
    this.thumbnailUrl,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (isRemote && thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return Stack(
        fit: StackFit.expand,
        children: [
          MediaUtils.buildImage(path: thumbnailUrl!, fit: fit),
          Center(child: Icon(Icons.play_arrow, color: Colors.white, size: 32)),
        ],
      );
    }

    return FutureBuilder<VideoPlayerController>(
      future: _initializeVideoThumbnail(videoPath, isRemote: isRemote),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data!.value.isInitialized) {
          return VideoPlayer(snapshot.data!);
        }
        return Container(
          color: Colors.grey[300],
          child: Center(
            child: CircularProgressIndicator(color: AppTheme.primaryColor),
          ),
        );
      },
    );
  }

  Future<VideoPlayerController> _initializeVideoThumbnail(
    String path, {
    bool isRemote = false,
  }) async {
    try {
      final controller = isRemote
          ? VideoPlayerController.networkUrl(Uri.parse(path))
          : VideoPlayerController.file(File(path));
      await controller.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          controller.dispose();
          throw TimeoutException('Video thumbnail timeout');
        },
      );
      if (controller.value.isInitialized) {
        await controller.setLooping(false);
        await controller.pause();
        await controller.setVolume(0.0);
      }
      return controller;
    } catch (e) {
      return isRemote
          ? VideoPlayerController.networkUrl(Uri.parse(path))
          : VideoPlayerController.file(File(path));
    }
  }
}
