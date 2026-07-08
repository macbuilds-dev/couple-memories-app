import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:yaaram/config/app_env.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';

/// Uploads media to Cloudinary using an **unsigned upload preset** (Spark-safe, no server).
class CloudinaryService {
  static final CloudinaryService instance = CloudinaryService._();
  CloudinaryService._();

  String get _cloudName => AppEnv.cloudinaryCloudName;
  String get _uploadPreset => AppEnv.cloudinaryUploadPreset;

  Future<MediaFile> uploadFile(File file, MediaType type) async {
    if (!AppEnv.isCloudinaryConfigured) {
      throw Exception(
        'Cloudinary is not configured. Set CLOUDINARY_CLOUD_NAME and '
        'CLOUDINARY_UPLOAD_PRESET in .env and create an unsigned preset in Cloudinary.',
      );
    }

    final resourceType = type == MediaType.video ? 'video' : 'image';
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'yaaram/memories'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Cloudinary upload failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final secureUrl = data['secure_url'] as String;
    final publicId = data['public_id'] as String?;

    String? thumbnailPath;
    if (type == MediaType.video && publicId != null) {
      thumbnailPath =
          'https://res.cloudinary.com/$_cloudName/video/upload/so_0/$publicId.jpg';
    }

    return MediaFile(
      path: secureUrl,
      type: type,
      thumbnailPath: thumbnailPath,
      cloudinaryPublicId: publicId,
    );
  }

  /// Upload local file paths; keeps already-remote URLs unchanged.
  Future<List<MediaFile>> uploadMediaFiles(List<MediaFile> files) async {
    final results = <MediaFile>[];
    for (final media in files) {
      if (media.isRemote) {
        results.add(media);
        continue;
      }
      final file = File(media.path);
      if (!await file.exists()) {
        results.add(media);
        continue;
      }
      results.add(await uploadFile(file, media.type));
    }
    return results;
  }
}
