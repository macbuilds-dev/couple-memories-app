import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yaaram/controller/home_tab_controller.dart';
import 'package:yaaram/routes/app_routes.dart';

/// Legacy route — redirects to Profile tab on home.
class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<HomeTabController>()) {
        Get.find<HomeTabController>().openProfileTab();
        Get.back();
      } else {
        Get.offAllNamed(AppRoutes.home);
        Future.delayed(const Duration(milliseconds: 300), () {
          if (Get.isRegistered<HomeTabController>()) {
            Get.find<HomeTabController>().openProfileTab();
          }
        });
      }
    });
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
