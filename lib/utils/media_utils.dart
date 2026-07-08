import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';

class MediaUtils {
  static bool isRemotePath(String path) =>
      path.startsWith('http://') || path.startsWith('https://');

  static ImageProvider imageProvider(String path) {
    if (isRemotePath(path)) {
      return CachedNetworkImageProvider(path);
    }
    return FileImage(File(path));
  }

  static Widget buildImage({
    required String path,
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    Widget? errorWidget,
  }) {
    if (isRemotePath(path)) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: fit,
        width: width,
        height: height,
        placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
        errorWidget: (_, __, ___) =>
            errorWidget ?? const Icon(Icons.broken_image),
      );
    }
    return Image.file(
      File(path),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) =>
          errorWidget ?? const Icon(Icons.broken_image),
    );
  }

  static Future<bool> mediaExists(MediaFile media) async {
    if (media.isRemote) return true;
    return File(media.path).exists();
  }

  static String videoSource(MediaFile media) => media.path;

  static String? thumbnailSource(MediaFile media) {
    if (media.thumbnailPath != null && media.thumbnailPath!.isNotEmpty) {
      return media.thumbnailPath;
    }
    if (media.isVideo && media.isRemote && media.cloudinaryPublicId != null) {
      return media.path; // Cloudinary auto-thumbnail handled in widget
    }
    return null;
  }
}
