import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../helper/network_img/network_img.dart';
import 'Controller/home_controller.dart';
import 'Model/post_model.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

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
            onPressed: () {},
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
              final post = controller.posts[index];
              return _buildPostItem(context, index, post);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPostItem(BuildContext context, int index, PostModel post) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Time, Badge, Menu
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                NetworkImg(
                  imageUrl: post.userAvatarUrl,
                  width: 44,
                  height: 44,
                  borderRadius: BorderRadius.circular(22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            post.timeAgo,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: post.badgeText == StaticString.solution
                                  ? const Color(0xFF00A86B)
                                  : const Color(0xFFC62828),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              post.badgeText.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: AppColors.textLight),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Post Content Text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Text(
              post.contentText,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.4,
                color: AppColors.textLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Post Image (if any)
          if (post.contentImageUrl != null) ...[
            NetworkImg(
              imageUrl: post.contentImageUrl!,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 8),
          ],
          
          // Bottom Actions: Like, Comment, Share
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildActionButton(
                  iconAsset: 'assets/icons/Like-icons.svg',
                  label: '${post.likesCount}',
                  color: post.isLiked ? Colors.blueAccent : const Color(0xFF04070D),
                  onTap: () => controller.toggleLike(index),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  iconAsset: 'assets/icons/ChatCircleDots.svg',
                  label: '${post.commentsCount}',
                  color: const Color(0xFF04070D),
                  onTap: () => _showCommentDialog(context, index),
                ),
                const SizedBox(width: 24),
                _buildActionButton(
                  iconAsset: 'assets/icons/ShareFat.svg',
                  label: '${post.sharesCount}',
                  color: const Color(0xFF04070D),
                  onTap: () => controller.sharePost(index),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String iconAsset,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            SvgPicture.asset(
              iconAsset,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentDialog(BuildContext context, int index) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              StaticString.addComment.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: StaticString.writeComment.tr,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                controller.addComment(index, textController.text);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(StaticString.post.tr),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
