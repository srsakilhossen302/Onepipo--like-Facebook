import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feed_screen.dart';
import '../NotificationScreen/notification_screen.dart';
import '../SearchScreen/search_screen.dart';
import '../SettingsScreen/settings_screen.dart';
import '../../Widgegt/CustomBottomNavBar/custom_bottom_nav_bar.dart';
import '../../../Core/AppRoute/app_route.dart';
import 'Controller/home_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const FeedScreen(),
      const NotificationScreen(),
      const SearchScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(() => CustomBottomNavBar(
        currentIndex: controller.selectedIndex.value,
        onTap: (index) => controller.changeIndex(index),
        onAddTap: () {
          Get.toNamed(AppRoute.createPost);
        },
      )),
    );
  }
}
