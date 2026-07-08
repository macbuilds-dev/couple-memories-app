import 'dart:convert';
import '../media_file_model/media_file_model.dart';
import 'memory_comment_model.dart';

class Memory {
  final int id;
  final DateTime date;
  final String title;
  final String description;
  final String location;
  final bool isFavorite;
  final bool isDeleted;
  final List<MediaFile> mediaFiles;
  final String? createdBy;
  final List<String> viewedBy;
  final List<String> likedBy;
  final List<String> starredBy;
  final List<MemoryComment> comments;
  final bool isTogetherMoment;
  final DateTime? reminderAt;
  final Map<String, String> notesSeenAtBy;

  Memory({
    required this.id,
    required this.date,
    required this.title,
    required this.description,
    required this.location,
    required this.isFavorite,
    this.isDeleted = false,
    this.mediaFiles = const [],
    this.createdBy,
    this.viewedBy = const [],
    this.likedBy = const [],
    this.starredBy = const [],
    this.comments = const [],
    this.isTogetherMoment = false,
    this.reminderAt,
    this.notesSeenAtBy = const {},
  });

  bool isLikedBy(String uid) => likedBy.contains(uid);
  bool isStarredBy(String uid) => starredBy.contains(uid);
  bool isViewedBy(String uid) => viewedBy.contains(uid);

  String get subtitle =>
      description.trim().isNotEmpty ? description.trim() : location;

  bool hasUnseenNotesFrom(String viewerUid, String? partnerUid) {
    if (partnerUid == null || partnerUid.isEmpty) return false;
    final partnerNotes =
        comments.where((c) => c.uid == partnerUid).toList();
    if (partnerNotes.isEmpty) return false;
    final seenAt = DateTime.tryParse(notesSeenAtBy[viewerUid] ?? '');
    if (seenAt == null) return true;
    return partnerNotes.any((c) => c.createdAt.isAfter(seenAt));
  }

  bool isCreatedBy(String uid) => createdBy == uid;

  // Backward compatibility: get first image path
  String? get imagePath => mediaFiles.isNotEmpty && mediaFiles.first.isImage
      ? mediaFiles.first.path
      : null;

  // Get all images
  List<MediaFile> get images => mediaFiles.where((m) => m.isImage).toList();

  // Get all videos
  List<MediaFile> get videos => mediaFiles.where((m) => m.isVideo).toList();

  // Firestore document format
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'location': location,
      'isFavorite': isFavorite,
      'isDeleted': isDeleted,
      'mediaFiles': mediaFiles.map((m) => m.toJson()).toList(),
      'createdAt': date.millisecondsSinceEpoch,
      if (createdBy != null) 'createdBy': createdBy,
      'viewedBy': viewedBy,
      'likedBy': likedBy,
      'starredBy': starredBy,
      'comments': comments.map((c) => c.toFirestore()).toList(),
      'isTogetherMoment': isTogetherMoment,
      if (reminderAt != null) 'reminderAt': reminderAt!.toIso8601String(),
      'notesSeenAtBy': notesSeenAtBy,
    };
  }

  factory Memory.fromFirestore(Map<String, dynamic> data, String docId) {
    final id = int.tryParse(docId) ?? data['id'] as int? ?? 0;
    List<MediaFile> media = [];

    final rawMedia = data['mediaFiles'];
    if (rawMedia is List) {
      media = rawMedia
          .map((m) => MediaFile.fromJson(Map<String, dynamic>.from(m as Map)))
          .toList();
    } else if (rawMedia is String && rawMedia.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawMedia) as List;
        media = decoded
            .map((m) => MediaFile.fromJson(Map<String, dynamic>.from(m as Map)))
            .toList();
      } catch (_) {}
    }

    return Memory(
      id: id,
      date: DateTime.parse(data['date'] as String),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      location: data['location'] as String? ?? '',
      isFavorite: data['isFavorite'] is bool
          ? data['isFavorite'] as bool
          : (data['isFavorite'] as int? ?? 0) == 1,
      isDeleted: data['isDeleted'] is bool
          ? data['isDeleted'] as bool
          : (data['isDeleted'] as int? ?? 0) == 1,
      mediaFiles: media,
      createdBy: data['createdBy'] as String?,
      viewedBy: _stringList(data['viewedBy']),
      likedBy: _stringList(data['likedBy']),
      starredBy: _stringList(data['starredBy']),
      comments: _commentList(data['comments']),
      isTogetherMoment: data['isTogetherMoment'] as bool? ?? false,
      reminderAt: _parseDate(data['reminderAt']),
      notesSeenAtBy: _stringMap(data['notesSeenAtBy']),
    );
  }

  static Map<String, String> _stringMap(dynamic value) {
    if (value is! Map) return {};
    return value.map((k, v) => MapEntry(k.toString(), v.toString()));
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static List<String> _stringList(dynamic value) {
    if (value is! List) return [];
    return value.map((e) => e.toString()).toList();
  }

  static List<MemoryComment> _commentList(dynamic value) {
    if (value is! List) return [];
    return value
        .whereType<Map>()
        .map((e) => MemoryComment.fromFirestore(Map<String, dynamic>.from(e)))
        .toList();
  }

  // Convert Memory to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'location': location,
      'isFavorite': isFavorite ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'mediaFiles': jsonEncode(mediaFiles.map((m) => m.toJson()).toList()),
    };
  }

  // Create Memory from JSON
  factory Memory.fromJson(Map<String, dynamic> json) {
    List<MediaFile> media = [];
    if (json['mediaFiles'] != null) {
      try {
        final mediaJson = jsonDecode(json['mediaFiles'] as String) as List;
        media = mediaJson.map((m) => MediaFile.fromJson(m)).toList();
      } catch (e) {
        // Fallback for old format
        if (json['imagePath'] != null) {
          media = [
            MediaFile(
              path: json['imagePath'] as String,
              type: MediaType.image,
            )
          ];
        }
      }
    } else if (json['imagePath'] != null) {
      // Backward compatibility
      media = [
        MediaFile(
          path: json['imagePath'] as String,
          type: MediaType.image,
        )
      ];
    }

    return Memory(
      id: json['id'] as int,
      date: DateTime.parse(json['date'] as String),
      title: json['title'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      isFavorite: (json['isFavorite'] is int)
          ? (json['isFavorite'] as int) == 1
          : (json['isFavorite'] as bool),
      isDeleted: (json['isDeleted'] is int)
          ? (json['isDeleted'] as int) == 1
          : (json['isDeleted'] as bool? ?? false),
      mediaFiles: media,
    );
  }

  // Create a copy with updated fields
  Memory copyWith({
    int? id,
    DateTime? date,
    String? title,
    String? description,
    String? location,
    bool? isFavorite,
    bool? isDeleted,
    List<MediaFile>? mediaFiles,
    String? createdBy,
    List<String>? viewedBy,
    List<String>? likedBy,
    List<String>? starredBy,
    List<MemoryComment>? comments,
    bool? isTogetherMoment,
    DateTime? reminderAt,
    Map<String, String>? notesSeenAtBy,
  }) {
    return Memory(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      location: location ?? this.location,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      createdBy: createdBy ?? this.createdBy,
      viewedBy: viewedBy ?? this.viewedBy,
      likedBy: likedBy ?? this.likedBy,
      starredBy: starredBy ?? this.starredBy,
      comments: comments ?? this.comments,
      isTogetherMoment: isTogetherMoment ?? this.isTogetherMoment,
      reminderAt: reminderAt ?? this.reminderAt,
      notesSeenAtBy: notesSeenAtBy ?? this.notesSeenAtBy,
    );
  }
}