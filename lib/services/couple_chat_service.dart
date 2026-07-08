import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yaaram/model/chat_message_model.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/services/user_profile_service.dart';

class CoupleChatService {
  static final CoupleChatService instance = CoupleChatService._();
  CoupleChatService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileService _profiles = UserProfileService.instance;

  CollectionReference<Map<String, dynamic>> _messagesRef(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('messages');

  Future<void> sendMemoryShare({
    required String coupleId,
    required Memory memory,
    String? note,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');

    final imageUrl = memory.images.isNotEmpty ? memory.images.first.path : null;
    final id = DateTime.now().millisecondsSinceEpoch.toString();

    await _messagesRef(coupleId).doc(id).set(
      ChatMessage(
        id: id,
        senderId: uid,
        type: ChatMessage.typeMemoryShare,
        text: note,
        memoryId: memory.id,
        memoryTitle: memory.title,
        memoryImageUrl: imageUrl,
        createdAt: DateTime.now(),
      ).toFirestore(),
    );
  }

  Future<void> sendTextMessage({
    required String coupleId,
    required String text,
    String? messageId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final id = messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    final now = DateTime.now();
    await _messagesRef(coupleId).doc(id).set(
      ChatMessage(
        id: id,
        senderId: uid,
        type: ChatMessage.typeText,
        text: trimmed,
        createdAt: now,
      ).toFirestore(),
    );
  }

  Stream<List<ChatMessage>> watchMessages(String coupleId) {
    return _messagesRef(coupleId)
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ChatMessage.fromFirestore(d.id, d.data()))
              .toList(),
        );
  }

  Future<String?> partnerDisplayName(String myUid) async {
    final partnerUid = await _profiles.getPartnerUid(myUid);
    if (partnerUid == null) return null;
    final profile = await _profiles.getPartnerProfile(partnerUid);
    if (profile.firstName?.trim().isNotEmpty == true) {
      return profile.firstName!.trim();
    }
    return 'your partner';
  }
}
