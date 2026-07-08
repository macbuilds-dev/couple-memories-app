import 'package:get/get.dart';

/// Tracks whether admin tools are unlocked for the current app session.
class AdminSessionController extends GetxController {
  final RxBool isUnlocked = false.obs;

  void unlock() => isUnlocked.value = true;

  void lock() => isUnlocked.value = false;
}
