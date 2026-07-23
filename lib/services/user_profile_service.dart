import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yaaram/model/user_profile_model.dart';

class UserProfileService {
  static final UserProfileService instance = UserProfileService._();
  UserProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  Future<UserProfile> getUserProfile(String uid, {bool repairCompletion = true}) async {
    final snap = await _users.doc(uid).get();
    final data = snap.data() ?? {};
    final profile = UserProfile.fromFirestore(uid, data);

    final isSelf = uid == _auth.currentUser?.uid;
    if (isSelf &&
        repairCompletion &&
        !profile.profileCompleted &&
        profile.isDataComplete) {
      await markCompleted(profile);
      return profile.copyWith(
        profileCompleted: true,
        profileSkipped: false,
        onboardingStep: null,
      );
    }

    return profile;
  }

  /// Partner profile read — never auto-writes completion on someone else's doc.
  Future<UserProfile> getPartnerProfile(String partnerUid) =>
      getUserProfile(partnerUid, repairCompletion: false);

  /// Live partner profile (nickname, photo, name) without polling.
  Stream<UserProfile> watchPartnerProfile(String partnerUid) {
    return _users.doc(partnerUid).snapshots().map((snap) {
      return UserProfile.fromFirestore(partnerUid, snap.data() ?? {});
    });
  }

  Future<void> saveProfile(UserProfile profile) async {
    var toSave = profile;
    if (!profile.profileCompleted && profile.isDataComplete) {
      toSave = profile.copyWith(
        profileCompleted: true,
        profileSkipped: false,
        clearOnboardingStep: true,
      );
    }

    await _users.doc(toSave.uid).set(
          toSave.toFirestore(),
          SetOptions(merge: true),
        );

    if (toSave.profileCompleted) {
      await _users
          .doc(toSave.uid)
          .update({'onboardingStep': FieldValue.delete()});
    }
  }

  Future<void> markSkipped(String uid) async {
    await _users.doc(uid).set(
      {
        'profileSkipped': true,
        'profileCompleted': false,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> markCompleted(UserProfile profile) async {
    await _users.doc(profile.uid).set(
      profile
          .copyWith(
            profileCompleted: true,
            profileSkipped: false,
            clearOnboardingStep: true,
          )
          .toFirestore(),
      SetOptions(merge: true),
    );
    // Explicitly clear checkpoint field when merge might keep old keys.
    await _users.doc(profile.uid).update({'onboardingStep': FieldValue.delete()});
  }

  Future<void> setPartnerNickname({
    required String partnerUid,
    required String nickname,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not signed in');

    await _users.doc(partnerUid).set(
      {
        'nickname': nickname.trim(),
        'nicknameSetBy': uid,
      },
      SetOptions(merge: true),
    );
  }

  Future<String?> getPartnerUid(String myUid) async {
    final mySnap = await _users.doc(myUid).get();
    final coupleId = mySnap.data()?['coupleId'] as String?;
    if (coupleId == null || coupleId.isEmpty) return null;

    final coupleSnap = await _firestore.collection('couples').doc(coupleId).get();
    final members = List<String>.from(coupleSnap.data()?['memberIds'] ?? []);
    for (final id in members) {
      if (id != myUid) return id;
    }
    return null;
  }
}
