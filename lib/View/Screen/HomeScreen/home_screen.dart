import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feed_screen.dart';
import '../NotificationScreen/notification_screen.dart';
import '../SearchScreen/search_screen.dart';
import '../ProfileScreen/my_profile_screen.dart';
import '../../Widgegt/CustomBottomNavBar/custom_bottom_nav_bar.dart';
import '../../../Core/AppRoute/app_route.dart';
import 'Controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    final List<Widget> screens = [
      const FeedScreen(),
      const NotificationScreen(),
      const SearchScreen(),
      const MyProfileScreen(),
    ];

    return Obx(
      () => PopScope(
        canPop: controller.selectedIndex.value == 0,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (controller.selectedIndex.value != 0) {
            controller.changeIndex(0);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: screens[controller.selectedIndex.value],
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: controller.selectedIndex.value,
            onTap: (index) => controller.changeIndex(index),
            onAddTap: () {
              Get.toNamed(AppRoute.createPost);
            },
          ),
        ),
      ),
    );
  }
}
