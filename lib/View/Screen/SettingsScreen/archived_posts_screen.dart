import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../View/Widgegt/PostCard/post_card.dart';
import '../../../View/Widgegt/ShimmerLoading/shimmer_loading.dart';
import '../../../Core/AppRoute/app_route.dart';
import '../../Screen/HomeScreen/Controller/home_controller.dart';

class ArchivedPostsScreen extends StatefulWidget {
  const ArchivedPostsScreen({super.key});

  @override
  State<ArchivedPostsScreen> createState() => _ArchivedPostsScreenState();
}

class _ArchivedPostsScreenState extends State<ArchivedPostsScreen> {
  late final HomeController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<HomeController>();
    controller.fetchArchivedPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textLight,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          StaticString.archive.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingArchivedPosts.value) {
          return ListView.builder(
            itemCount: 3,
            padding: const EdgeInsets.only(top: 8),
            itemBuilder: (context, index) => const PostCardShimmer(),
          );
        }

        if (controller.archivedPosts.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchArchivedPosts,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.archive_outlined,
                        size: 72,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No archived posts yet!",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchArchivedPosts,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: controller.archivedPosts.length,
            itemBuilder: (context, index) {
              // Find the index in the main posts list
              final archivedPost = controller.archivedPosts[index];
              final mainPostIndex = controller.posts.indexWhere(
                (p) => p.id == archivedPost.id,
              );

              if (mainPostIndex == -1) {
                return const SizedBox.shrink();
              }

              return PostCard(
                postIndex: mainPostIndex,
                postList: null,
              );
            },
          ),
        );
      }),
    );
  }
}
