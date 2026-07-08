import 'package:get/get.dart';
import 'package:yaaram/controller/auth_controller.dart';
import 'package:yaaram/controller/home_tab_controller.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/routes/app_routes.dart';

/// Centralized navigation helpers using named GetX routes.
class NavigationHelper {
  static void toLogin() {
    Get.offAllNamed(AppRoutes.welcome);
  }

  static void toWelcome() {
    Get.offAllNamed(AppRoutes.welcome);
  }

  static void toEmailAuth() {
    Get.toNamed(AppRoutes.emailAuth);
  }

  static void toSignup() {
    Get.toNamed(AppRoutes.emailAuth);
  }

  static Future<void> routeAfterAuth(AuthController auth) async {
    await auth.waitUntilReady();
    if (auth.needsProfileOnboarding) {
      Get.offAllNamed(AppRoutes.profileOnboarding);
    } else if (!auth.hasCouple) {
      Get.offAllNamed(AppRoutes.coupleSetup);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  static void toProfileOnboarding() {
    Get.offAllNamed(AppRoutes.profileOnboarding);
  }

  static void toCoupleSetup() {
    Get.offAllNamed(AppRoutes.coupleSetup);
  }

  static void toHome({bool replace = false}) {
    if (replace) {
      Get.offNamed(AppRoutes.home);
    } else {
      Get.toNamed(AppRoutes.home);
    }
  }

  static void toAddMemory({Memory? memoryToEdit}) {
    Get.toNamed(AppRoutes.addMemory, arguments: memoryToEdit);
  }

  static void toMemoryDetail(Memory memory) {
    Get.toNamed(AppRoutes.memoryDetail, arguments: memory);
  }

  static void toMediaViewer({
    required List<MediaFile> mediaFiles,
    int initialIndex = 0,
  }) {
    Get.toNamed(
      AppRoutes.mediaViewer,
      arguments: {
        'mediaFiles': mediaFiles,
        'initialIndex': initialIndex,
      },
    );
  }

  static void toDatabaseAdmin() {
    Get.toNamed(AppRoutes.databaseAdmin);
  }

  static void toMemoriesAdmin() {
    Get.toNamed(AppRoutes.memoriesAdmin);
  }

  static void toDebugScreen() {
    toSettings();
  }

  static void toTogetherMoment(Memory memory) {
    Get.toNamed(AppRoutes.togetherMoment, arguments: memory);
  }

  static void toDiscoverPreview(Memory memory) {
    Get.toNamed(AppRoutes.discoverPreview, arguments: memory);
  }

  /// Opens the Profile tab (settings merged into profile hub).
  static void toSettings() {
    if (!Get.isRegistered<HomeTabController>()) {
      Get.offNamed(AppRoutes.home);
      return;
    }
    final tab = Get.find<HomeTabController>();
    if (Get.currentRoute != AppRoutes.home) {
      Get.offNamed(AppRoutes.home);
    }
    tab.openProfileTab();
  }
}
