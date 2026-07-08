enum MediaType { image, video }

class MediaFile {
  final String path;
  final MediaType type;
  final String? thumbnailPath;
  final String? cloudinaryPublicId;

  MediaFile({
    required this.path,
    required this.type,
    this.thumbnailPath,
    this.cloudinaryPublicId,
  });

  bool get isRemote =>
      path.startsWith('http://') || path.startsWith('https://');

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'type': type.toString().split('.').last,
      'thumbnailPath': thumbnailPath,
      'cloudinaryPublicId': cloudinaryPublicId,
    };
  }

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      path: json['path'] as String,
      type: MediaType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => MediaType.image,
      ),
      thumbnailPath: json['thumbnailPath'] as String?,
      cloudinaryPublicId: json['cloudinaryPublicId'] as String?,
    );
  }

  MediaFile copyWith({
    String? path,
    MediaType? type,
    String? thumbnailPath,
    String? cloudinaryPublicId,
  }) {
    return MediaFile(
      path: path ?? this.path,
      type: type ?? this.type,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      cloudinaryPublicId: cloudinaryPublicId ?? this.cloudinaryPublicId,
    );
  }

  bool get isImage => type == MediaType.image;
  bool get isVideo => type == MediaType.video;
}
