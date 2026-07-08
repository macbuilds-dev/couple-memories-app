import 'dart:async';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/model/chat_message_model.dart';
import 'package:yaaram/model/user_profile_model.dart';
import 'package:yaaram/services/chat_preferences_service.dart';
import 'package:yaaram/services/couple_chat_service.dart';
import 'package:yaaram/services/user_profile_service.dart';

class CoupleChatController extends GetxController {
  final CoupleChatService _chat = CoupleChatService.instance;
  final UserProfileService _profiles = UserProfileService.instance;
  final ChatPreferencesService _prefs = ChatPreferencesService.instance;

  final Rxn<UserProfile> partnerProfile = Rxn<UserProfile>();
  final RxnString partnerUid = RxnString();
  final RxnString backgroundPath = RxnString();
  final RxBool isSending = false.obs;
  final RxBool isLoadingPartner = true.obs;

  /// Shown instantly while Firestore confirms the send.
  final RxList<ChatMessage> pendingMessages = <ChatMessage>[].obs;

  bool get isPartnerLinked => partnerUid.value != null;

  Stream<List<ChatMessage>>? _messagesStream;
  String? _streamCoupleId;

  AuthController get _auth => Get.find<AuthController>();

  String? get myUid => _auth.uid;
  String? get coupleId => _auth.coupleId;
  bool get hasCouple => _auth.hasCouple;

  String get partnerDisplayName {
    final p = partnerProfile.value;
    if (p == null) return 'Partner';
    if (p.nickname?.trim().isNotEmpty == true) return p.nickname!.trim();
    if (p.firstName?.trim().isNotEmpty == true) return p.firstName!.trim();
    return 'Partner';
  }

  Stream<List<ChatMessage>>? get messagesStream {
    final cid = coupleId;
    if (cid == null || !isPartnerLinked) {
      _resetStream();
      return null;
    }
    if (_streamCoupleId != cid || _messagesStream == null) {
      _streamCoupleId = cid;
      _messagesStream = _chat.watchMessages(cid).map(
            (list) => list.reversed.toList(),
          );
    }
    return _messagesStream;
  }

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
    ever(_auth.profile, (_) => _bootstrap());
  }

  void _resetStream() {
    _messagesStream = null;
    _streamCoupleId = null;
  }

  Future<void> _bootstrap() async {
    final uid = myUid;
    if (uid == null) {
      isLoadingPartner.value = false;
      partnerProfile.value = null;
      partnerUid.value = null;
      pendingMessages.clear();
      _resetStream();
      return;
    }

    isLoadingPartner.value = true;
    try {
      final pUid = hasCouple ? await _profiles.getPartnerUid(uid) : null;
      partnerUid.value = pUid;
      partnerProfile.value = null;
      pendingMessages.clear();
      _resetStream();

      if (pUid != null) {
        try {
          partnerProfile.value = await _profiles.getPartnerProfile(pUid);
        } catch (e) {
          partnerProfile.value = null;
          print('Could not load partner profile: $e');
        }
        backgroundPath.value = await _prefs.getBackgroundPath(uid);
        // Prime stream cache for StreamBuilder.
        messagesStream;
      }
    } finally {
      isLoadingPartner.value = false;
    }
  }

  Future<void> reload() => _bootstrap();

  List<ChatMessage> mergeMessages(List<ChatMessage> fromStream) {
    final ids = fromStream.map((m) => m.id).toSet();
    final extras = pendingMessages
        .where((m) => !ids.contains(m.id))
        .toList(growable: false);
    if (extras.isEmpty) return fromStream;

    final merged = [...fromStream, ...extras]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return merged;
  }

  Future<void> sendText(String text) async {
    final cid = coupleId;
    final uid = myUid;
    if (cid == null || uid == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final optimistic = ChatMessage(
      id: id,
      senderId: uid,
      type: ChatMessage.typeText,
      text: trimmed,
      createdAt: DateTime.now(),
    );
    pendingMessages.add(optimistic);

    isSending.value = true;
    try {
      await _chat.sendTextMessage(
        coupleId: cid,
        text: trimmed,
        messageId: id,
      );
    } catch (e) {
      pendingMessages.removeWhere((m) => m.id == id);
      rethrow;
    } finally {
      isSending.value = false;
    }
  }

  void prunePendingAgainst(List<ChatMessage> fromStream) {
    final ids = fromStream.map((m) => m.id).toSet();
    pendingMessages.removeWhere((m) => ids.contains(m.id));
  }

  Future<void> setPartnerNickname(String nickname) async {
    final pUid = partnerUid.value;
    if (pUid == null) return;

    await _profiles.setPartnerNickname(
      partnerUid: pUid,
      nickname: nickname,
    );
    partnerProfile.value = await _profiles.getPartnerProfile(pUid);
  }

  Future<void> pickChatBackground() async {
    final uid = myUid;
    if (uid == null) return;

    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) return;

    await _prefs.setBackgroundPath(uid, file.path);
    backgroundPath.value = file.path;
  }

  Future<void> clearChatBackground() async {
    final uid = myUid;
    if (uid == null) return;

    await _prefs.clearBackgroundPath(uid);
    backgroundPath.value = null;
  }

  Future<void> refreshPartner() async {
    final pUid = partnerUid.value;
    if (pUid == null) return;
    partnerProfile.value = await _profiles.getPartnerProfile(pUid);
  }
}
