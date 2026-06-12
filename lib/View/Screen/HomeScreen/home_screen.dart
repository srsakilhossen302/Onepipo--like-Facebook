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
    final selectedReplyComment = Rxn<CommentModel>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "Comments",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF04070D),
                    ),
                  ),
                  // Positioned(
                  //   right: 0,
                  //   child: IconButton(
                  //     icon: const Icon(Icons.close, color: Colors.black, size: 24),
                  //     onPressed: () => Navigator.pop(context),
                  //   ),
                  // ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            
            // Comments List
            Expanded(
              child: Obx(() {
                final post = controller.posts[index];
                if (post.comments.isEmpty) {
                  return const Center(
                    child: Text(
                      "No comments yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: post.comments.length,
                  itemBuilder: (context, cIndex) {
                    final comment = post.comments[cIndex];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              NetworkImg(
                                imageUrl: comment.userAvatarUrl,
                                width: 36,
                                height: 36,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF04070D),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          comment.timeAgo,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      comment.text,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF04070D),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            selectedReplyComment.value = comment;
                                          },
                                          child: Text(
                                            "Reply",
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        GestureDetector(
                                          onTap: () => controller.toggleLikeComment(index, cIndex),
                                          child: Icon(
                                            comment.isLiked
                                                ? Icons.thumb_up_alt_rounded
                                                : Icons.thumb_up_off_alt_rounded,
                                            size: 16,
                                            color: comment.isLiked ? Colors.blueAccent : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${comment.likesCount}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        GestureDetector(
                                          onTap: () => controller.toggleDislikeComment(index, cIndex),
                                          child: Icon(
                                            comment.isDisliked
                                                ? Icons.thumb_down_alt_rounded
                                                : Icons.thumb_down_off_alt_rounded,
                                            size: 16,
                                            color: comment.isDisliked ? Colors.redAccent : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // Replies list under this comment
                          if (comment.replies.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comment.replies.length,
                              itemBuilder: (context, rIndex) {
                                final reply = comment.replies[rIndex];
                                return Padding(
                                  padding: const EdgeInsets.only(left: 48, top: 6, bottom: 6),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      NetworkImg(
                                        imageUrl: reply.userAvatarUrl,
                                        width: 28,
                                        height: 28,
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  reply.userName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: Color(0xFF04070D),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  reply.timeAgo,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              reply.text,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF04070D),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Spacer(),
                                                GestureDetector(
                                                  onTap: () => controller.toggleLikeCommentReply(index, comment.id, reply.id),
                                                  child: Icon(
                                                    reply.isLiked
                                                        ? Icons.thumb_up_alt_rounded
                                                        : Icons.thumb_up_off_alt_rounded,
                                                    size: 14,
                                                    color: reply.isLiked ? Colors.blueAccent : Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${reply.likesCount}',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                GestureDetector(
                                                  onTap: () => controller.toggleDislikeCommentReply(index, comment.id, reply.id),
                                                  child: Icon(
                                                    reply.isDisliked
                                                        ? Icons.thumb_down_alt_rounded
                                                        : Icons.thumb_down_off_alt_rounded,
                                                    size: 14,
                                                    color: reply.isDisliked ? Colors.redAccent : Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            
            // Reply Target Indicator Bar
            Obx(() {
              if (selectedReplyComment.value == null) return const SizedBox.shrink();
              return Container(
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Replying to @${selectedReplyComment.value!.userName}",
                      style: const TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => selectedReplyComment.value = null,
                      child: const Icon(
                        Icons.cancel_rounded,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              );
            }),
            
            const Divider(height: 1, thickness: 0.5),
            
            // Bottom Input Bar
            Obx(() {
              final isReplying = selectedReplyComment.value != null;
              final replyUser = selectedReplyComment.value?.userName ?? "";
              return Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: textController,
                          decoration: InputDecoration(
                            hintText: isReplying
                                ? "Reply to @$replyUser..."
                                : "Commenting as shahriar",
                            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (textController.text.trim().isNotEmpty) {
                          if (isReplying) {
                            controller.addReply(
                              index,
                              selectedReplyComment.value!.id,
                              textController.text,
                            );
                            selectedReplyComment.value = null;
                          } else {
                            controller.addComment(index, textController.text);
                          }
                          textController.clear();
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_upward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
