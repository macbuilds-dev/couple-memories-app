import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cloudinary config loaded from `.env` (unsigned upload preset only).
class AppEnv {
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    await dotenv.load(fileName: '.env');
    _loaded = true;
  }

  static String get cloudinaryCloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'dp5ekocn1';
  static String get cloudinaryUploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'yaaram_unsigned';

  static bool get isCloudinaryConfigured =>
      cloudinaryCloudName.isNotEmpty && cloudinaryUploadPreset.isNotEmpty;
}
