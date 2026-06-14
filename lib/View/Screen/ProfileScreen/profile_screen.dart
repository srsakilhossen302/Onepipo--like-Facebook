import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../helper/network_img/network_img.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../Widgegt/PostCard/post_card.dart';
import '../../Widgegt/ShimmerLoading/shimmer_loading.dart';
import 'Controller/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController controller;
  late final String userName;

  @override
  void initState() {
    super.initState();
    userName = Get.arguments as String;
    controller = ProfileController()..initUser(userName);
  }

  String _getUserBio(String userName) {
    if (userName.toLowerCase() == 'africa') {
      return "Motherland";
    } else if (userName.toLowerCase() == 'elena gonzalez') {
      return "Passionate traveler & storyteller 🗺️";
    } else if (userName.toLowerCase() == 'ahmed wahid') {
      return "Developer, designer & social enthusiast 🚀";
    } else if (userName.toLowerCase() == 'shahriar') {
      return "Active contributor & tech geek 💻";
    }
    return "Member of Onepipo community";
  }

  String _getUserCoverImage(String userName) {
    if (userName.toLowerCase() == 'africa') {
      return "https://images.unsplash.com/photo-1541123437800-1bb1317badc2?w=800"; // wood blocks texture
    }
    return "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800"; // ocean abstract
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        // Find posts authored by this user
        final userPosts = controller.userPosts;
        final isFollowingUser = controller.isFollowing.value;
        
        // Find the user's avatar from their posts
        String userAvatarUrl = "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150";
        if (userPosts.isNotEmpty) {
          userAvatarUrl = userPosts.first.userAvatarUrl;
        } else {
          // Check followers list for avatar
          final follower = controller.homeController.followers.firstWhereOrNull((f) => f.name == userName);
          if (follower != null) {
            userAvatarUrl = follower.avatarUrl;
          }
        }

        return SingleChildScrollView(
          controller: controller.scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Stack: Cover photo + Avatar + Back arrow + menu
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover Image
                  NetworkImg(
                    imageUrl: _getUserCoverImage(userName),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                  
                  // Black Overlay for better readability of buttons
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.15),
                    ),
                  ),

                  // Header Controls (Back and Options Overlay)
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
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          color: Colors.white,
                          surfaceTintColor: Colors.white,
                          onSelected: (value) {
                            if (value == 'block') {
                              controller.blockUser(context);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            PopupMenuItem<String>(
                              value: 'block',
                              child: Text(
                                StaticString.blockUser.tr,
                                style: const TextStyle(
                                  color: AppColors.textLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Avatar overlapping cover photo
                  Positioned(
                    bottom: -44,
                    left: 16,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: NetworkImg(
                        imageUrl: userAvatarUrl,
                        width: 88,
                        height: 88,
                        borderRadius: BorderRadius.circular(44),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 52), // Space for overlapping avatar

              // Profile Information Section
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
                      "@${userName.toLowerCase().replaceAll(' ', '')}",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Bio
                    Text(
                      _getUserBio(userName),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF04070D),
                      ),
                    ),
                    const SizedBox(height: 14),
                    
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
                    
                    // Follow Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () => controller.toggleFollow(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowingUser
                              ? const Color(0xFFE4E6EB)
                              : Colors.blueAccent,
                          foregroundColor: isFollowingUser
                              ? Colors.black87
                              : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          isFollowingUser ? StaticString.following.tr : StaticString.follow.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // User's Posts Header
                    Text(
                      "$userName's ${StaticString.posts.tr}",
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
              
              // List of Posts made by this user
              if (controller.isLoadingPosts.value)
                const Column(
                  children: [
                    PostCardShimmer(),
                    PostCardShimmer(),
                  ],
                )
              else if (userPosts.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      StaticString.noPostsYet.tr,
                      style: const TextStyle(color: Colors.grey),
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
                    // Find actual index of the post in controller's posts list
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
