import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:yaaram/controller/home_tab_controller.dart';
import 'package:yaaram/routes/app_routes.dart';

/// Top-level handler for background FCM messages.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase is already initialized by the engine in background isolates
  // when using FlutterFire; keep this lightweight.
  debugPrint('Background FCM: ${message.messageId} ${message.notification?.title}');
}

class PushNotificationService extends GetxService {
  static PushNotificationService get instance => Get.find<PushNotificationService>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const _androidChannel = AndroidNotificationChannel(
    'yaaram_updates',
    'Yaaram updates',
    description: 'Chat and memory updates from your partner',
    importance: Importance.high,
  );

  StreamSubscription<String>? _tokenRefreshSub;
  bool _initialized = false;
  bool _loggedApnsUnavailable = false;

  Future<PushNotificationService> init() async {
    if (_initialized) return this;
    _initialized = true;

    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _local.initialize(
        settings:
            const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: _onLocalTap,
      );

      if (Platform.isAndroid) {
        await _local
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_androidChannel);
      }

      await _requestPermissions();
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        _handleMessageNavigation(initial);
      }

      await refreshAndSaveToken();
      _tokenRefreshSub = _messaging.onTokenRefresh.listen(_saveToken);
    } on MissingPluginException catch (e) {
      // Hot restart after adding native plugins — full stop + flutter run needed.
      _initialized = false;
      debugPrint('Push plugins not linked yet (do a full app restart): $e');
    } catch (e) {
      debugPrint('PushNotificationService.init failed: $e');
    }

    return this;
  }

  Future<void> _requestPermissions() async {
    try {
      await _messaging
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          )
          .timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Notification permission request: $e');
    }

    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await _local
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> refreshAndSaveToken() async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      if (Platform.isIOS) {
        final apnsReady = await _waitForApnsToken();
        if (!apnsReady) {
          // Simulator / missing Push capability — in-app sync still works.
          if (!_loggedApnsUnavailable) {
            _loggedApnsUnavailable = true;
            debugPrint(
              'APNS token not available yet (normal on Simulator). '
              'Background push needs a physical iPhone + Push capability + APNs key.',
            );
          }
          return;
        }
      }
      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 8),
        onTimeout: () => null,
      );
      if (token != null) await _saveToken(token);
    } catch (e) {
      debugPrint('FCM token error: $e');
    }
  }

  /// iOS requires an APNS device token before FCM `getToken()` succeeds.
  Future<bool> _waitForApnsToken({
    int attempts = 3,
    Duration delay = const Duration(milliseconds: 400),
  }) async {
    for (var i = 0; i < attempts; i++) {
      try {
        final apns = await _messaging.getAPNSToken();
        if (apns != null && apns.isNotEmpty) return true;
      } catch (_) {}
      await Future<void>.delayed(delay);
    }
    return false;
  }

  Future<void> _saveToken(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).set(
      {
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        'fcmPlatform': Platform.isIOS ? 'ios' : 'android',
      },
      SetOptions(merge: true),
    );
  }

  Future<void> clearToken() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _messaging.deleteToken();
    } catch (_) {}
    await _firestore.collection('users').doc(uid).set(
      {
        'fcmToken': FieldValue.delete(),
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  void _onForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ??
        message.data['title'] ??
        'Yaaram';
    final body = message.notification?.body ??
        message.data['body'] ??
        'New update from your partner';
    showLocal(
      title: title,
      body: body,
      payload: jsonEncode(message.data),
    );
  }

  Future<void> showLocal({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _local.show(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: payload,
      );
    } on MissingPluginException {
      // Native plugin not linked (hot restart) — ignore.
    } catch (e) {
      debugPrint('showLocal failed: $e');
    }
  }

  void _onLocalTap(NotificationResponse response) {
    if (response.payload == null || response.payload!.isEmpty) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateFromData(data);
    } catch (_) {}
  }

  void _handleMessageNavigation(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    try {
      final tabs = Get.find<HomeTabController>();
      if (type == 'chat' || type == 'message') {
        tabs.selectedIndex.value = 2;
      } else if (type == 'memory') {
        tabs.selectedIndex.value = 1;
      }
      if (Get.currentRoute != AppRoutes.home) {
        Get.offAllNamed(AppRoutes.home);
      }
    } catch (_) {}
  }

  /// Ask Cloud Function / queue to push the partner (also used as audit trail).
  Future<void> notifyPartner({
    required String partnerUid,
    required String title,
    required String body,
    required String type,
    Map<String, String>? data,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || partnerUid.isEmpty) return;

    await _firestore.collection('users').doc(partnerUid).collection('alerts').add({
      'title': title,
      'body': body,
      'type': type,
      'data': data ?? <String, String>{},
      'fromUid': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  @override
  void onClose() {
    _tokenRefreshSub?.cancel();
    super.onClose();
  }
}
