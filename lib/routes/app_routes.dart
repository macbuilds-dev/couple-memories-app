import 'package:get/get.dart';
import 'package:yaaram/model/memory_model/memory_model.dart';
import 'package:yaaram/view/home_screen/discover/memory_discover_preview_screen.dart';
import 'package:yaaram/view/home_screen/moments/together_moment_screen.dart';
import 'package:yaaram/model/media_file_model/media_file_model.dart';
import 'package:yaaram/view/auth/couple_setup_screen.dart';
import 'package:yaaram/view/auth/email_auth_screen.dart';
import 'package:yaaram/view/auth/welcome_screen.dart';
import 'package:yaaram/view/add_memory_screen/add_memory_screen.dart';
import 'package:yaaram/view/admin/database_admin_screen.dart';
import 'package:yaaram/view/admin/debug_screen.dart';
import 'package:yaaram/view/admin/memories_admin_screen.dart';
import 'package:yaaram/view/home_screen/home_screen.dart';
import 'package:yaaram/view/memory_detail_screen/memory_detail_screen.dart';
import 'package:yaaram/view/profile/profile_onboarding_screen.dart';
import 'package:yaaram/view/splash_screen/splash_screen.dart';
import 'package:yaaram/controller/profile_onboarding_controller.dart';
import 'package:yaaram/view/widgets/media_viewer_screen.dart';

/// Named routes for declarative navigation via GetX.
class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const emailAuth = '/email-auth';
  static const login = '/login';
  static const signup = '/signup';
  static const coupleSetup = '/couple-setup';
  static const profileOnboarding = '/profile-onboarding';
  static const home = '/home';
  static const addMemory = '/add-memory';
  static const memoryDetail = '/memory-detail';
  static const discoverPreview = '/discover-preview';
  static const togetherMoment = '/together-moment';
  static const mediaViewer = '/media-viewer';
  static const debug = '/debug';
  static const databaseAdmin = '/database-admin';
  static const memoriesAdmin = '/memories-admin';

  static final List<GetPage<dynamic>> pages = [
    GetPage(name: splash, page: () => const SplashScreen()),
    GetPage(name: welcome, page: () => const WelcomeScreen()),
    GetPage(name: emailAuth, page: () => const EmailAuthScreen()),
    GetPage(name: login, page: () => const WelcomeScreen()),
    GetPage(name: signup, page: () => const EmailAuthScreen()),
    GetPage(name: coupleSetup, page: () => const CoupleSetupScreen()),
    GetPage(
      name: profileOnboarding,
      page: () => const ProfileOnboardingScreen(),
      binding: BindingsBuilder(() {
        if (Get.isRegistered<ProfileOnboardingController>()) {
          Get.delete<ProfileOnboardingController>();
        }
        Get.put(ProfileOnboardingController());
      }),
    ),
    GetPage(name: home, page: () => const HomeScreen()),
    GetPage(
      name: addMemory,
      page: () {
        final args = Get.arguments;
        if (args is Memory) {
          return AddMemoryScreen(memoryToEdit: args);
        }
        if (args is Map) {
          return AddMemoryScreen(
            initialTitle: args['initialTitle'] as String?,
            initialDescription: args['initialDescription'] as String?,
          );
        }
        return const AddMemoryScreen();
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: memoryDetail,
      page: () => MemoryDetailScreen(memory: Get.arguments as Memory),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: discoverPreview,
      page: () =>
          MemoryDiscoverPreviewScreen(memory: Get.arguments as Memory),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: togetherMoment,
      page: () => TogetherMomentScreen(memory: Get.arguments as Memory),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: mediaViewer,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return MediaViewerScreen(
          mediaFiles: args['mediaFiles'] as List<MediaFile>,
          initialIndex: args['initialIndex'] as int? ?? 0,
        );
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: debug,
      page: () => const DebugScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: databaseAdmin,
      page: () => const DatabaseAdminScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: memoriesAdmin,
      page: () => const MemoriesAdminScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
