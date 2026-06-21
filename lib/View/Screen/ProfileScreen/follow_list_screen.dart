import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../helper/network_img/network_img.dart';
import '../../../Utils/StaticString/static_string.dart';
import 'Controller/follow_list_controller.dart';
import 'profile_screen.dart';
import '../HomeScreen/Controller/home_controller.dart';
import '../../../Core/AppRoute/app_route.dart';
import '../../../helper/shared_prefe/shared_prefe.dart';

class FollowListScreen extends StatefulWidget {
  const FollowListScreen({super.key});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  late final FollowListController controller;
  late final String userName;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    userName = args['userName'] ?? Get.find<SharedPreferenceHelper>().getUserName();
    controller = FollowListController()..initUser(userName);
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onUserTap(FollowerModel user) {
    final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
    final isMe = sharedPrefHelper.isMe(
          userId: user.id,
          userName: user.name,
          authorRaw: user.rawJson,
        );

    if (isMe) {
      Get.toNamed(AppRoute.myProfile);
    } else {
      Get.toNamed(
        AppRoute.profile,
        arguments: {
          'userId': user.id,
          'userName': user.name,
          'author':
              user.rawJson ??
              {'id': user.id, 'name': user.name, 'photo': user.avatarUrl},
        },
      );
    }
  }

  Widget _buildUserList(List<FollowerModel> list, bool isLoading) {
    final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
    final loggedInUserName = sharedPrefHelper.getUserName();
    final loggedInUserUsername = sharedPrefHelper.getUserUsername();
    final isOwnProfile =
        userName.toLowerCase() == loggedInUserName.toLowerCase() ||
        userName.toLowerCase() == loggedInUserUsername.toLowerCase();

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blueAccent),
      );
    }

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_outlined, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              list == controller.followers ? StaticString.noFollowersYet.tr : StaticString.notFollowingYet.tr,
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
      separatorBuilder: (context, index) =>
          const Divider(height: 24, thickness: 0.5, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final user = list[index];
        final isMe = sharedPrefHelper.isMe(
              userId: user.id,
              userName: user.name,
              authorRaw: user.rawJson,
            );

        return Obx(() {
          // Dynamic status checks for lists
          final amIFollowingThisUser = controller.isFollowing(user.name);

          return Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => _onUserTap(user),
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
                  onTap: () => _onUserTap(user),
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
                if (isOwnProfile && list == controller.followers) ...[
                  // My own profile: "Remove" on Followers
                  ElevatedButton(
                    onPressed: () => controller.removeFollower(user.name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF0F2F5),
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      StaticString.remove.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else ...[
                  // Either someone else's profile, or our own "Following" list:
                  // Show "Follow" or "Following" based on our relation
                  ElevatedButton(
                    onPressed: () {
                      if (amIFollowingThisUser) {
                        controller.unfollowUser(user);
                      } else {
                        controller.followUser(user);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: amIFollowingThisUser
                          ? const Color(0xFFE4E6EB)
                          : Colors.blueAccent,
                      foregroundColor: amIFollowingThisUser
                          ? Colors.black87
                          : Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      amIFollowingThisUser
                          ? StaticString.following.tr
                          : StaticString.follow.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
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
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final initialIndex = args['initialIndex'] ?? 0;

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
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
            userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: [
              Tab(text: StaticString.followers.tr),
              Tab(text: StaticString.following.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Obx(() => _buildUserList(controller.followers, controller.isLoadingFollowers.value)),
            Obx(() => _buildUserList(controller.following, controller.isLoadingFollowing.value)),
          ],
        ),
      ),
    );
  }
}
