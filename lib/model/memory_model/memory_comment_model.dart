class MemoryComment {
  final String uid;
  final String text;
  final DateTime createdAt;

  const MemoryComment({
    required this.uid,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'text': text,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MemoryComment.fromFirestore(Map<String, dynamic> data) {
    return MemoryComment(
      uid: data['uid'] as String? ?? '',
      text: data['text'] as String? ?? '',
      createdAt: DateTime.tryParse(data['createdAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }
}
