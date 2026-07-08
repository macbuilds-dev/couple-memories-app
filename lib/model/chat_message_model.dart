import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String type;
  final String? text;
  final int? memoryId;
  final String? memoryTitle;
  final String? memoryImageUrl;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.type,
    this.text,
    this.memoryId,
    this.memoryTitle,
    this.memoryImageUrl,
    required this.createdAt,
  });

  static const typeText = 'text';
  static const typeMemoryShare = 'memory_share';

  Map<String, dynamic> toFirestore() => {
        'senderId': senderId,
        'type': type,
        if (text != null) 'text': text,
        if (memoryId != null) 'memoryId': memoryId,
        if (memoryTitle != null) 'memoryTitle': memoryTitle,
        if (memoryImageUrl != null) 'memoryImageUrl': memoryImageUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatMessage.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      senderId: data['senderId'] as String? ?? '',
      type: data['type'] as String? ?? typeText,
      text: data['text'] as String?,
      memoryId: data['memoryId'] as int?,
      memoryTitle: data['memoryTitle'] as String?,
      memoryImageUrl: data['memoryImageUrl'] as String?,
      createdAt: _parseCreatedAt(data['createdAt']),
    );
  }

  static DateTime _parseCreatedAt(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }
}
