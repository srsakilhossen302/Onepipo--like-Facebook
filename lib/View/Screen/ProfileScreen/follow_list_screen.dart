import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../helper/network_img/network_img.dart';
import '../../../Utils/StaticString/static_string.dart';
import 'Controller/follow_list_controller.dart';
import 'profile_screen.dart';
import '../HomeScreen/Controller/home_controller.dart';

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({super.key});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> with SingleTickerProviderStateMixin {
  late final FollowListController controller;
  late TabController _tabController;
  late final String userName;
  late final int initialIndex;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    userName = args['userName'] ?? 'Shahriar';
    initialIndex = args['initialIndex'] ?? 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
    controller = FollowListController()..initUser(userName);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onUserTap(String clickedUserName) {
    if (clickedUserName.toLowerCase() == 'shahriar') {
      Get.toNamed('/my_profile');
    } else {
      Get.to(() => const ProfileScreen(), arguments: clickedUserName, preventDuplicates: false);
    }
  }

  Widget _buildUserList(List<FollowerModel> list, bool isFollowersTab) {
    final isOwnProfile = userName.toLowerCase() == 'shahriar';

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_outlined,
              size: 72,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isFollowersTab ? StaticString.noFollowersYet.tr : StaticString.notFollowingYet.tr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: list.length,
      separatorBuilder: (context, index) => const Divider(height: 24, thickness: 0.5, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final user = list[index];
        final isMe = user.name.toLowerCase() == 'shahriar';

        return Obx(() {
          // Dynamic status checks for lists
          final amIFollowingThisUser = controller.isFollowing(user.name);

          return Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => _onUserTap(user.name),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey[200]!, width: 1),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: NetworkImg(
                      imageUrl: user.avatarUrl,
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name
              Expanded(
                child: GestureDetector(
                  onTap: () => _onUserTap(user.name),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "@${user.name.toLowerCase().replaceAll(' ', '')}",
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action button
              if (!isMe) ...[
                if (isOwnProfile) ...[
                  // My own profile: "Remove" on Followers, "Unfollow" on Following
                  if (isFollowersTab)
                    ElevatedButton(
                      onPressed: () => controller.removeFollower(user.name),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0F2F5),
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        StaticString.remove.tr,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    ElevatedButton(
                      onPressed: () => controller.unfollowUser(user.name),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4E6EB),
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        StaticString.unfollow.tr,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                ] else ...[
                  // Someone else's profile: Show "Follow" or "Following" based on our relation
                  ElevatedButton(
                    onPressed: () => controller.unfollowUser(user.name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: amIFollowingThisUser ? const Color(0xFFE4E6EB) : Colors.blueAccent,
                      foregroundColor: amIFollowingThisUser ? Colors.black87 : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      amIFollowingThisUser ? StaticString.following.tr : StaticString.follow.tr,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ],
          );
        });
      },
    );
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
        title: Text(
          userName == 'Shahriar' ? StaticString.myNetwork.tr : userName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blueAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blueAccent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          tabs: [
            Obx(() {
              final followersCount = controller.getFollowers().length;
              return Tab(text: "$followersCount ${StaticString.followers.tr}");
            }),
            Obx(() {
              final followingCount = controller.getFollowing().length;
              return Tab(text: "$followingCount ${StaticString.following.tr}");
            }),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Obx(() => _buildUserList(controller.getFollowers(), true)),
          Obx(() => _buildUserList(controller.getFollowing(), false)),
        ],
      ),
    );
  }
}
