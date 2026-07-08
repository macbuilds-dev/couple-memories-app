import 'package:get/get.dart';

/// Controls the bottom navigation index from outside [HomeScreen].
class HomeTabController extends GetxController {
  final RxInt selectedIndex = 0.obs;

  static const profileTabIndex = 3;

  void selectTab(int index) {
    selectedIndex.value = index;
  }

  void openProfileTab() {
    selectedIndex.value = profileTabIndex;
  }
}
