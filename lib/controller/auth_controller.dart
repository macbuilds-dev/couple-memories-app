import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yaaram/model/user_profile_model.dart';
import 'package:yaaram/services/couple_service.dart';
import 'package:yaaram/services/push_notification_service.dart';
import 'package:yaaram/services/user_profile_service.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CoupleService _coupleService = CoupleService.instance;
  final UserProfileService _userProfileService = UserProfileService.instance;
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rx<CoupleProfile?> profile = Rx<CoupleProfile?>(null);
  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;

  StreamSubscription<CoupleProfile>? _profileWatchSub;

  bool get isLoggedIn => firebaseUser.value != null;
  bool get hasCouple => profile.value?.hasCouple ?? false;
  bool get needsProfileOnboarding =>
      isLoggedIn && (userProfile.value?.needsOnboarding ?? true);
  String? get coupleId => profile.value?.coupleId;
  String? get uid => firebaseUser.value?.uid;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    await _profileWatchSub?.cancel();
    _profileWatchSub = null;

    if (user == null) {
      profile.value = null;
      userProfile.value = null;
      isInitialized.value = true;
      return;
    }
    try {
      profile.value = await _coupleService.ensureUserDocument(user);
      userProfile.value = await _userProfileService.getUserProfile(user.uid);
      _profileWatchSub =
          _coupleService.watchProfile(user.uid).listen((p) {
        profile.value = p;
      });
      try {
        await Get.find<PushNotificationService>().refreshAndSaveToken();
      } catch (_) {}
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      isInitialized.value = true;
    }
  }

  Future<void> refreshUserProfile() async {
    final user = firebaseUser.value;
    if (user == null) return;
    userProfile.value = await _userProfileService.getUserProfile(user.uid);
  }

  Future<void> refreshProfile() async {
    final user = firebaseUser.value;
    if (user == null) return;
    profile.value = await _coupleService.getProfile(user.uid);
    await refreshUserProfile();
  }

  @override
  void onClose() {
    _profileWatchSub?.cancel();
    super.onClose();
  }

  Future<void> waitUntilReady() async {
    while (!isInitialized.value) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
  }

  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await refreshProfile();
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    isLoading.value = true;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await cred.user?.updateDisplayName(displayName.trim());
      if (cred.user != null) {
        await _coupleService.ensureUserDocument(cred.user!);
        await refreshProfile();
      }
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await Get.find<PushNotificationService>().clearToken();
    } catch (_) {}
    await _googleSignIn.signOut();
    await _auth.signOut();
    profile.value = null;
    userProfile.value = null;
  }

  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final googleUser = await _googleSignIn.authenticate();
      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw Exception('Google sign-in did not return an ID token.');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final cred = await _auth.signInWithCredential(credential);
      if (cred.user != null) {
        await _coupleService.ensureUserDocument(cred.user!);
        await refreshProfile();
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      throw Exception(e.description ?? 'Google sign-in failed.');
    } on FirebaseAuthException catch (e) {
      throw _mapAuthError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> createCouple() async {
    final code = await _coupleService.createCouple();
    await refreshProfile();
    return code;
  }

  Future<void> joinCouple(String code) async {
    await _coupleService.joinCouple(code);
    await refreshProfile();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Incorrect email or password. If you are new, create an account.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return e.message ?? 'Authentication failed.';
    }
  }
}
