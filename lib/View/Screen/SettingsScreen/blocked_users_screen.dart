import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../helper/network_img/network_img.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../HomeScreen/Controller/home_controller.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final HomeController homeController = Get.find<HomeController>();

  Future<void> _unblockUser(String userId, String userName) async {
    await homeController.unblockUser(userId, userName);
  }

  Future<void> _refreshBlockedUsers() async {
    await homeController.fetchBlockedUsers();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.block_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "No blocked users",
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

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.blueAccent),
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
        centerTitle: true,
        title: Text(
          StaticString.blockedUsers.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        actions: [
          Obx(() {
            if (homeController.isLoadingBlockedUsers.value) {
              return const Padding(
                padding: EdgeInsets.only(right: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            return IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.textLight),
              onPressed: _refreshBlockedUsers,
            );
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (homeController.isLoadingBlockedUsers.value) {
            return _buildLoadingState();
          }

          final blockedUsers = homeController.blockedUsers;
          if (blockedUsers.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: _refreshBlockedUsers,
            color: Colors.blueAccent,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: blockedUsers.length,
              separatorBuilder: (context, index) => const Divider(
                height: 24,
                thickness: 0.5,
                color: Color(0xFFEEEEEE),
              ),
              itemBuilder: (context, index) {
                final user = blockedUsers[index];
                return Row(
                  children: [
                    // Avatar
                    Container(
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
                    const SizedBox(width: 14),

                    // Name
                    Expanded(
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

                    // Unblock button
                    ElevatedButton(
                      onPressed: () => _unblockUser(user.id, user.name),
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
                      child: const Text(
                        "Unblock",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
