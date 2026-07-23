import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/home_tab_controller.dart';
import 'package:yaaram/services/push_notification_service.dart';
import 'package:yaaram/services/user_profile_service.dart';

/// Keeps both partners' UIs live and surfaces alerts when away from that tab.
class LiveSyncController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _profiles = UserProfileService.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _alertsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _messagesSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _memoriesSub;
  String? _listeningUid;
  String? _listeningCoupleId;
  DateTime _startedAt = DateTime.now();
  String? _lastNotifiedMessageId;
  String? _lastNotifiedMemoryId;

  AuthController get _authCtrl => Get.find<AuthController>();
  HomeTabController get _tabs => Get.find<HomeTabController>();

  @override
  void onInit() {
    super.onInit();
    ever(_authCtrl.profile, (_) => _rebind());
    _rebind();
  }

  DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      if (value > 9999999999) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Future<void> _rebind() async {
    final uid = _auth.currentUser?.uid;
    final coupleId = _authCtrl.coupleId;
    if (uid == null || coupleId == null || !_authCtrl.hasCouple) {
      await _cancelAll();
      return;
    }
    if (_listeningUid == uid && _listeningCoupleId == coupleId) return;

    await _cancelAll();
    _listeningUid = uid;
    _listeningCoupleId = coupleId;
    _startedAt = DateTime.now();
    _lastNotifiedMessageId = null;
    _lastNotifiedMemoryId = null;

    _bindAlerts(uid);
    _bindMessages(coupleId, uid);
    _bindMemories(coupleId, uid);

    try {
      await Get.find<PushNotificationService>().refreshAndSaveToken();
    } catch (_) {}
  }

  void _bindAlerts(String uid) {
    _alertsSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('alerts')
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen(
      (snap) async {
        for (final change in snap.docChanges) {
          if (change.type != DocumentChangeType.added) continue;
          final data = change.doc.data();
          if (data == null) continue;
          if (data['read'] == true) continue;
          final createdAt = _asDateTime(data['createdAt']);
          if (createdAt != null && createdAt.isBefore(_startedAt)) continue;

          final title = data['title'] as String? ?? 'Yaaram';
          final body = data['body'] as String? ?? '';
          final type = data['type'] as String? ?? 'update';

          await Get.find<PushNotificationService>().showLocal(
            title: title,
            body: body,
            payload: '{"type":"$type"}',
          );

          if (Get.isSnackbarOpen != true) {
            Get.snackbar(title, body, snackPosition: SnackPosition.TOP);
          }

          try {
            await change.doc.reference.update({'read': true});
          } catch (_) {}
        }
      },
      onError: (e) {
        // Rules not deployed yet, or index missing — don't crash the app.
        debugPrint('alerts stream error: $e');
      },
    );
  }

  void _bindMessages(String coupleId, String uid) {
    _messagesSub = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen(
      (snap) async {
        if (snap.docs.isEmpty) return;
        final doc = snap.docs.first;
        if (doc.id == _lastNotifiedMessageId) return;
        final data = doc.data();
        final senderId = data['senderId'] as String?;
        if (senderId == null || senderId == uid) {
          _lastNotifiedMessageId = doc.id;
          return;
        }
        final createdAt = _asDateTime(data['createdAt']);
        if (createdAt == null || createdAt.isBefore(_startedAt)) {
          _lastNotifiedMessageId = doc.id;
          return;
        }
        _lastNotifiedMessageId = doc.id;

        // Chat screen already streams; only ping when user is elsewhere.
        if (_tabs.selectedIndex.value == 2) return;

        final text = data['text'] as String? ?? 'New message';
        final preview = text.length > 80 ? '${text.substring(0, 80)}…' : text;
        await Get.find<PushNotificationService>().showLocal(
          title: 'New message',
          body: preview,
          payload: '{"type":"chat"}',
        );
      },
      onError: (e) => debugPrint('messages live-sync error: $e'),
    );
  }

  void _bindMemories(String coupleId, String uid) {
    _memoriesSub = _firestore
        .collection('couples')
        .doc(coupleId)
        .collection('memories')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen(
      (snap) async {
        if (snap.docs.isEmpty) return;
        final doc = snap.docs.first;
        if (doc.id == _lastNotifiedMemoryId) return;
        final data = doc.data();
        final createdBy = data['createdBy'] as String?;
        if (createdBy == null || createdBy == uid) {
          _lastNotifiedMemoryId = doc.id;
          return;
        }
        final when = _asDateTime(data['createdAt']);
        if (when == null || when.isBefore(_startedAt)) {
          _lastNotifiedMemoryId = doc.id;
          return;
        }
        _lastNotifiedMemoryId = doc.id;

        if (_tabs.selectedIndex.value == 1 || _tabs.selectedIndex.value == 0) {
          return;
        }

        final title = data['title'] as String? ?? 'New memory';
        await Get.find<PushNotificationService>().showLocal(
          title: 'New memory',
          body: title,
          payload: '{"type":"memory"}',
        );
      },
      onError: (e) => debugPrint('memories live-sync error: $e'),
    );
  }

  Future<void> notifyPartnerOfMessage(String text) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final partnerUid = await _profiles.getPartnerUid(uid);
    if (partnerUid == null) return;
    final preview = text.trim();
    try {
      await Get.find<PushNotificationService>().notifyPartner(
        partnerUid: partnerUid,
        title: 'New message',
        body: preview.isEmpty
            ? 'Your partner sent a message'
            : (preview.length > 100 ? '${preview.substring(0, 100)}…' : preview),
        type: 'chat',
        data: {'type': 'chat'},
      );
    } catch (e) {
      debugPrint('notifyPartnerOfMessage failed: $e');
    }
  }

  Future<void> notifyPartnerOfMemory(String memoryTitle) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    final partnerUid = await _profiles.getPartnerUid(uid);
    if (partnerUid == null) return;
    try {
      await Get.find<PushNotificationService>().notifyPartner(
        partnerUid: partnerUid,
        title: 'New memory',
        body: memoryTitle.isEmpty ? 'Your partner added a memory' : memoryTitle,
        type: 'memory',
        data: {'type': 'memory'},
      );
    } catch (e) {
      debugPrint('notifyPartnerOfMemory failed: $e');
    }
  }

  Future<void> _cancelAll() async {
    await _alertsSub?.cancel();
    await _messagesSub?.cancel();
    await _memoriesSub?.cancel();
    _alertsSub = null;
    _messagesSub = null;
    _memoriesSub = null;
    _listeningUid = null;
    _listeningCoupleId = null;
  }

  @override
  void onClose() {
    _cancelAll();
    super.onClose();
  }
}
