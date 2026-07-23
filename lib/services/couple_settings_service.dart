import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yaaram/controller/utils/settings/app_settings.dart';

/// Couple-shared theme + text labels live on `couples/{coupleId}.appSettings`.
class CoupleSettingsService {
  static final CoupleSettingsService instance = CoupleSettingsService._();
  CoupleSettingsService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> _coupleRef(String coupleId) =>
      _firestore.collection('couples').doc(coupleId);

  Stream<AppSettings?> watchAppSettings(String coupleId) {
    return _coupleRef(coupleId).snapshots().map((snap) {
      final data = snap.data();
      if (data == null) return null;
      final raw = data['appSettings'];
      if (raw is! Map) return null;
      return AppSettings.fromSyncMap(Map<String, dynamic>.from(raw));
    });
  }

  Future<void> saveAppSettings({
    required String coupleId,
    required AppSettings settings,
    required String updatedBy,
  }) async {
    await _coupleRef(coupleId).set(
      {
        'appSettings': settings.toSyncMap(),
        'appSettingsUpdatedAt': FieldValue.serverTimestamp(),
        'appSettingsUpdatedBy': updatedBy,
      },
      SetOptions(merge: true),
    );
  }
}
