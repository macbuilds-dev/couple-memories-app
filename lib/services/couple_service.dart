import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CoupleProfile {
  final String uid;
  final String? email;
  final String? displayName;
  final String? coupleId;
  final String? coupleCode;

  CoupleProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.coupleId,
    this.coupleCode,
  });

  bool get hasCouple =>
      coupleId != null &&
      coupleId!.isNotEmpty &&
      CoupleService._coupleCodePattern.hasMatch(coupleId!);
}

class CoupleService {
  static final CoupleService instance = CoupleService._();
  CoupleService._();

  static final RegExp _coupleCodePattern = RegExp(r'^[A-Z0-9]{6}$');

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _couples =>
      _firestore.collection('couples');

  Future<CoupleProfile> ensureUserDocument(User user) async {
    final ref = _users.doc(user.uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@').first,
        'coupleId': null,
        'coupleCode': null,
        'profileCompleted': false,
        'profileSkipped': false,
        'firstName': null,
        'lastName': null,
        'nickname': null,
        'nicknameSetBy': null,
        'photoPath': null,
        'birthday': null,
        'gender': null,
        'hobbies': <String>[],
        'languages': <String>[],
        'dreamTravel': <String>[],
        'skills': <String>[],
        'wantsToLearn': <String>[],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return getProfile(user.uid);
  }

  Future<CoupleProfile> getProfile(String uid) async {
    final snap = await _users.doc(uid).get();
    final data = snap.data() ?? {};
    return _sanitizeProfile(uid, CoupleProfile(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      coupleId: data['coupleId'] as String?,
      coupleCode: data['coupleCode'] as String?,
    ));
  }

  Future<CoupleProfile> _sanitizeProfile(
    String uid,
    CoupleProfile profile,
  ) async {
    final id = profile.coupleId;
    if (id == null || id.isEmpty) return profile;

    if (!_coupleCodePattern.hasMatch(id)) {
      await _users.doc(uid).update({
        'coupleId': null,
        'coupleCode': null,
      });
      return CoupleProfile(
        uid: profile.uid,
        email: profile.email,
        displayName: profile.displayName,
      );
    }

    return profile;
  }

  Stream<CoupleProfile> watchProfile(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      final data = snap.data() ?? {};
      return CoupleProfile(
        uid: uid,
        email: data['email'] as String?,
        displayName: data['displayName'] as String?,
        coupleId: data['coupleId'] as String?,
        coupleCode: data['coupleCode'] as String?,
      );
    });
  }

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<String> _uniqueCode() async {
    for (var attempt = 0; attempt < 10; attempt++) {
      final code = _generateCode();
      final existing = await _couples.doc(code).get();
      if (!existing.exists) return code;
    }
    throw Exception('Could not generate a unique couple code. Try again.');
  }

  Future<String> createCouple() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');

    final existing = await getProfile(uid);
    if (existing.hasCouple) {
      return existing.coupleCode ?? existing.coupleId!;
    }

    final code = await _uniqueCode();
    final coupleRef = _couples.doc(code);

    try {
      await coupleRef.set({
        'code': code,
        'memberIds': [uid],
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': uid,
      });
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception(
          'Could not create couple. Stop the app, run flutter run again, then retry.',
        );
      }
      rethrow;
    }

    await _users.doc(uid).update({
      'coupleId': code,
      'coupleCode': code,
    });

    return code;
  }

  Future<void> joinCouple(String code) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');

    final normalized = code.trim().toUpperCase();

    DocumentSnapshot<Map<String, dynamic>> doc;
    try {
      doc = await _couples.doc(normalized).get();
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw Exception('This couple already has two members.');
      }
      rethrow;
    }

    if (!doc.exists) {
      throw Exception('Invalid couple code. Check with your partner.');
    }

    final memberIds = List<String>.from(doc.data()?['memberIds'] ?? []);

    if (memberIds.contains(uid)) {
      await _users.doc(uid).update({
        'coupleId': doc.id,
        'coupleCode': normalized,
      });
      return;
    }

    if (memberIds.length >= 2) {
      throw Exception('This couple already has two members.');
    }

    await doc.reference.update({
      'memberIds': FieldValue.arrayUnion([uid]),
    });

    await _users.doc(uid).update({
      'coupleId': doc.id,
      'coupleCode': normalized,
    });
  }
}
