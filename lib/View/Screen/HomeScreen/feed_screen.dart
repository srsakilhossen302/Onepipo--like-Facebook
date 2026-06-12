import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../Utils/ToastMessage/toast_message.dart';
import '../../../helper/network_img/network_img.dart';
import 'Controller/home_controller.dart';
import 'Model/post_model.dart';

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
                  onPressed: () => _showPostOptionsBottomSheet(context, index),
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
                  onTap: () => _showShareBottomSheet(context, index),
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

  void _showShareBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
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
              padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 4.0, bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Share post with:",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey, size: 24),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            Expanded(
              child: Obx(() {
                if (controller.followers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.format_quote_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No followers found.",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final post = controller.posts[index];
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.followers.length,
                  itemBuilder: (context, fIndex) {
                    final follower = controller.followers[fIndex];
                    final isSent = controller.isFollowerShared(post.id, follower.id);
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          NetworkImg(
                            imageUrl: follower.avatarUrl,
                            width: 44,
                            height: 44,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              follower.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Color(0xFF04070D),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            height: 36,
                            child: ElevatedButton(
                              onPressed: isSent
                                  ? null
                                  : () => controller.shareWithFollower(index, follower.id),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSent
                                    ? Colors.grey[200]
                                    : Colors.blueAccent,
                                foregroundColor: isSent
                                    ? Colors.grey[600]
                                    : Colors.white,
                                disabledBackgroundColor: Colors.grey[200],
                                disabledForegroundColor: Colors.grey[600],
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(
                                isSent ? "Sent" : "Send",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showPostOptionsBottomSheet(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(
                  Icons.bookmark_outline_rounded,
                  color: Colors.blueAccent,
                  size: 28,
                ),
                title: const Text(
                  "Save",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF04070D),
                  ),
                ),
                subtitle: Text(
                  "Save this post.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ToastMessage.showToast(message: "Successful save this post");
                },
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(
                  Icons.flag_outlined,
                  color: Colors.redAccent,
                  size: 28,
                ),
                title: const Text(
                  "Report",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF04070D),
                  ),
                ),
                subtitle: Text(
                  "Flag this post if sensitive.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showReportBottomSheet(context, index);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportBottomSheet(BuildContext context, int index) {
    final reasons = [
      "Spam", "Harassment", "Misinformation",
      "Inappropriate", "Violence", "Nudity",
      "Hate Speech", "Self-Harm", "Other"
    ];
    final selectedReason = "".obs;
    final textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
                    "Report this post",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF04070D),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Select your reporting reason",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: reasons.map((reason) {
                        final isSelected = selectedReason.value == reason;
                        return ChoiceChip(
                          label: Text(
                            reason,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              selectedReason.value = reason;
                            } else {
                              selectedReason.value = "";
                            }
                          },
                          selectedColor: Colors.blueAccent,
                          backgroundColor: const Color(0xFFE5E7EB),
                          checkmarkColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    )),
                    const SizedBox(height: 24),
                    TextField(
                      controller: textController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Tell us more..",
                        labelStyle: TextStyle(color: Colors.grey[600]),
                        alignLabelWithHint: true,
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ToastMessage.showToast(message: "Report submitted successfully");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
