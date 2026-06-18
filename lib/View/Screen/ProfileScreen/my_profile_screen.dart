import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/ToastMessage/toast_message.dart';
import '../../../helper/network_img/network_img.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../Widgegt/PostCard/post_card.dart';
import '../../Widgegt/ShimmerLoading/shimmer_loading.dart';
import 'Controller/my_profile_controller.dart';
import 'edit_profile_screen.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final MyProfileController controller = Get.put(MyProfileController());
  String get userName => controller.userName;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // Find posts authored by the current user
        final userPosts = controller.myPosts;

        return SingleChildScrollView(
          controller: controller.scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Stack: Cover photo + Avatar + Back arrow
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Bounding Box to ensure the entire avatar and plus button are clickable
                  const SizedBox(
                    height: 224,
                    width: double.infinity,
                  ),
                  // Cover Image
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 180,
                    child: controller.coverPhotoPath.value.isNotEmpty
                        ? Image.file(
                            File(controller.coverPhotoPath.value),
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          )
                        : NetworkImg(
                            imageUrl: controller.coverPhotoUrl.value.isNotEmpty
                                ? controller.coverPhotoUrl.value
                                : "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800",
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                  ),
                  
                  // Black Overlay
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 180,
                    child: Container(
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),

                  // Cover Photo Camera Button
                  Positioned(
                    bottom: 56, // 12px from the bottom of the 180px cover photo (224 - 180 + 12 = 56)
                    right: 12,
                    child: GestureDetector(
                      onTap: () {
                        controller.openGallery("cover photo");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.grey[800],
                          size: 18,
                        ),
                      ),
                    ),
                  ),

                  // Header Controls (Back and centered Title)
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => Get.back(),
                        ),
                        Text(
                          StaticString.profile.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 48), // balances the back button
                      ],
                    ),
                  ),

                  // Placeholder avatar with blue + sign overlay
                  Positioned(
                    bottom: 0,
                    left: 16,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF2F3F5),
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: controller.profilePhotoPath.value.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(44),
                                  child: Image.file(
                                    File(controller.profilePhotoPath.value),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : controller.profilePhotoUrl.value.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(44),
                                      child: NetworkImg(
                                        imageUrl: controller.profilePhotoUrl.value,
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                      size: 50,
                                    ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              controller.openGallery("profile picture");
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.blueAccent,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8), // Padding below Stack to preserve layout spacing

              // Profile Details
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Handle
                    Text(
                      controller.currentUserUsername.value.isNotEmpty
                          ? (controller.currentUserUsername.value.startsWith('@')
                              ? controller.currentUserUsername.value
                              : "@${controller.currentUserUsername.value}")
                          : "@${userName.toLowerCase().replaceAll(' ', '')}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Row: posts count, followers, following
                    Row(
                      children: [
                        Icon(Icons.rss_feed_rounded, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          "${userPosts.length} ${StaticString.posts.tr}",
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed('/follow_list', arguments: {
                              'userName': userName,
                              'initialIndex': 0,
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.group_outlined, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                "${(controller.homeController.userFollowers[userName] ?? []).length} ${StaticString.followers.tr}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed('/follow_list', arguments: {
                              'userName': userName,
                              'initialIndex': 1,
                            });
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_add_alt_1_outlined, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                "${(controller.homeController.userFollowing[userName] ?? []).length} ${StaticString.following.tr}",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Edit Profile Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          Get.to(() => const EditProfileScreen());
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD0D5DD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          StaticString.editProfile.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // My Posts Title Label
                    Text(
                      StaticString.myPosts.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
              
              // List of user posts
              if (controller.isLoadingPosts.value)
                const Column(
                  children: [
                    PostCardShimmer(),
                    PostCardShimmer(),
                  ],
                )
              else if (userPosts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          StaticString.noPostsYet.tr,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userPosts.length,
                  itemBuilder: (context, index) {
                    final post = userPosts[index];
                    final actualIndex = controller.homeController.posts.indexOf(post);
                    return PostCard(postIndex: actualIndex);
                  },
                ),
              if (controller.isLoadingMore.value)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
