import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yaaram/controller/home_tab_controller.dart';
import 'package:yaaram/controller/utils/theme/app_theme.dart';
import 'package:yaaram/utils/navigation_helper.dart';
import 'package:yaaram/view/chat/couple_chat_screen.dart';
import 'package:yaaram/view/widgets/bottom_nav_widget.dart';
import 'discover/discover_timeline_screen.dart';
import 'moments/moments_screen.dart';
import 'profile_tab_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _fabController;
  final HomeTabController _tabController = Get.find<HomeTabController>();

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Obx(
            () => IndexedStack(
              index: _tabController.selectedIndex.value,
              children: const [
                DiscoverTimelineScreen(),
                MomentsScreen(),
                CoupleChatScreen(),
                ProfileTabScreen(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        if (_tabController.selectedIndex.value != 1) {
          return const SizedBox.shrink();
        }
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: _fabController,
              curve: Curves.easeInOut,
            ),
          ),
          child: FloatingActionButton(
            heroTag: 'newMemoryFAB',
            onPressed: NavigationHelper.toAddMemory,
            backgroundColor: AppTheme.secondaryColor,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
            elevation: 8,
          ),
        );
      }),
      bottomNavigationBar: ColoredBox(
        color: AppTheme.surfaceColor,
        child: Obx(
          () => BottomNavWidget(
            currentIndex: _tabController.selectedIndex.value,
            onTap: (index) => _tabController.selectedIndex.value = index,
          ),
        ),
      ),
    );
  }
}
