import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../Widgegt/PostCard/post_card.dart';
import 'Controller/home_controller.dart';

class FeedScreen extends GetView<HomeController> {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0.5,
        leadingWidth: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16, top: 10, bottom: 10),
          child: SvgPicture.asset(
            'assets/icons/App-Logo.svg',
            fit: BoxFit.contain,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search_rounded,
              color: AppColors.textLight,
              size: 28,
            ),
            onPressed: () {
              // Tapping search on feed screen redirects to search tab
              controller.changeIndex(2);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refreshFeed,
          color: AppColors.primary,
          child: ListView.builder(
            itemCount: controller.posts.length,
            padding: const EdgeInsets.only(top: 8),
            itemBuilder: (context, index) {
              return PostCard(postIndex: index);
            },
          ),
        );
      }),
    );
  }
}
