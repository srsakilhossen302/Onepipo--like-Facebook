import 'package:flutter/material.dart';
import 'dart:io';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../Utils/ToastMessage/toast_message.dart';
import '../../../helper/network_img/network_img.dart';
import '../../../Core/AppRoute/app_route.dart';
import '../../Screen/HomeScreen/Controller/home_controller.dart';
import '../../Screen/HomeScreen/Model/post_model.dart';
import 'comment_bottom_sheet.dart';
import '../../../helper/shared_prefe/shared_prefe.dart';

class PostCard extends StatelessWidget {
  final int postIndex;
  final bool isClickable;
  final VoidCallback? onCommentTap;
  final List<PostModel>? postList;

  const PostCard({
    super.key,
    required this.postIndex,
    this.isClickable = true,
    this.onCommentTap,
    this.postList,
  });

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();
    final posts = postList ?? controller.posts;

    return Obx(() {
      if (postIndex < 0 || postIndex >= posts.length) {
        return const SizedBox.shrink();
      }
      final post = posts[postIndex];

      return Container(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: isClickable
                  ? () =>
                        Get.toNamed(AppRoute.postDetails, arguments: postIndex)
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Avatar, Name, Time, Badge, Menu
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
                            final bool isMyPost = sharedPrefHelper.isMe(
                                  userId: post.userId,
                                  userName: post.userName,
                                  authorRaw: post.authorRaw,
                                ) ||
                                sharedPrefHelper.isMe(userId: post.postUserId);
                            if (isMyPost) {
                              Get.toNamed(AppRoute.myProfile);
                            } else {
                              Get.toNamed(
                                AppRoute.profile,
                                arguments: {
                                  'userId': post.postUserId,
                                  'userName': post.userName,
                                  'author': post.authorRaw,
                                },
                              );
                            }
                          },
                          child: NetworkImg(
                            imageUrl: post.userAvatarUrl,
                            width: 44,
                            height: 44,
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
                                  final bool isMyPost = sharedPrefHelper.isMe(
                                        userId: post.userId,
                                        userName: post.userName,
                                        authorRaw: post.authorRaw,
                                      ) ||
                                      sharedPrefHelper.isMe(userId: post.postUserId);
                                  if (isMyPost) {
                                    Get.toNamed(AppRoute.myProfile);
                                  } else {
                                    Get.toNamed(
                                      AppRoute.profile,
                                      arguments: {
                                        'userId': post.postUserId,
                                        'userName': post.userName,
                                        'author': post.authorRaw,
                                      },
                                    );
                                  }
                                },
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textLight,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: post.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (post.groupName != null) ...[
                                        const TextSpan(
                                          text: " ▶ ",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        TextSpan(
                                          text: post.groupName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1877F2),
                                          ),
                                        ),
                                      ],
                                      if (post.taggedFriends != null &&
                                          post.taggedFriends!.isNotEmpty) ...[
                                        TextSpan(
                                          text: " ${StaticString.isWith.tr} ",
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 13.5,
                                          ),
                                        ),
                                        TextSpan(
                                          text: post.taggedFriends!.join(', '),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textLight,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          post.badgeText ==
                                              StaticString.solution
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
                          icon: const Icon(
                            Icons.more_vert,
                            color: AppColors.textLight,
                          ),
                          onPressed: () => _showPostOptionsBottomSheet(
                            context,
                            controller,
                            postIndex,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Post Content Text
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
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
                    post.contentImageUrl!.startsWith('http')
                        ? NetworkImg(
                            imageUrl: post.contentImageUrl!,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(post.contentImageUrl!),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),

            // Bottom Actions: Like, Comment, Share
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4.0,
                vertical: 6.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _buildActionButton(
                    iconAsset: 'assets/icons/Like-icons.svg',
                    label: '${post.likesCount}',
                    color: post.isLiked
                        ? Colors.blueAccent
                        : const Color(0xFF04070D),
                    onTap: () => controller.toggleLike(postIndex),
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    iconAsset: 'assets/icons/ChatCircleDots.svg',
                    label: '${post.commentsCount}',
                    color: const Color(0xFF04070D),
                    onTap: () {
                      if (onCommentTap != null) {
                        onCommentTap!();
                      } else {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              CommentBottomSheet(postIndex: postIndex),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 24),
                  _buildActionButton(
                    iconAsset: 'assets/icons/ShareFat.svg',
                    label: '${post.sharesCount}',
                    color: const Color(0xFF04070D),
                    onTap: () =>
                        _showShareBottomSheet(context, controller, postIndex),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.5),
          ],
        ),
      );
    });
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

  void _showShareBottomSheet(
    BuildContext context,
    HomeController controller,
    int index,
  ) {
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
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 8.0,
                top: 4.0,
                bottom: 8.0,
              ),
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
                    final isSent = controller.isFollowerShared(
                      post.id,
                      follower.id,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                                  : () => controller.shareWithFollower(
                                      index,
                                      follower.id,
                                    ),
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

  void _showPostOptionsBottomSheet(
    BuildContext context,
    HomeController controller,
    int index,
  ) {
    final post = controller.posts[index];
    final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
    final bool isMyPost = sharedPrefHelper.isMe(
          userId: post.userId,
          userName: post.userName,
          authorRaw: post.authorRaw,
        ) ||
        sharedPrefHelper.isMe(userId: post.postUserId);

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
              if (isMyPost) ...[
                // Archive
                ListTile(
                  leading: const Icon(
                    Icons.archive_outlined,
                    color: Color(0xFF04070D),
                    size: 28,
                  ),
                  title: Text(
                    StaticString.archive.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF04070D),
                    ),
                  ),
                  subtitle: Text(
                    StaticString.archiveSubtitle.tr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.toggleArchive(index);
                  },
                ),
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEEEEEE),
                ),
                // Edit
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF04070D),
                    size: 28,
                  ),
                  title: Text(
                    StaticString.edit.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF04070D),
                    ),
                  ),
                  subtitle: Text(
                    StaticString.editSubtitle.tr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Get.toNamed(AppRoute.createPost, arguments: index);
                  },
                ),
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEEEEEE),
                ),
                // Save
                ListTile(
                  leading: Icon(
                    post.isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: post.isSaved
                        ? Colors.blueAccent
                        : const Color(0xFF04070D),
                    size: 28,
                  ),
                  title: Text(
                    post.isSaved ? "Saved" : StaticString.save.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF04070D),
                    ),
                  ),
                  subtitle: Text(
                    post.isSaved
                        ? "Remove from saved posts"
                        : StaticString.saveSubtitle.tr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.toggleSave(index);
                  },
                ),
                const Divider(
                  height: 1,
                  thickness: 0.5,
                  color: Color(0xFFEEEEEE),
                ),
                // Delete
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                  title: Text(
                    StaticString.delete.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF04070D),
                    ),
                  ),
                  subtitle: Text(
                    StaticString.deleteSubtitle.tr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.deletePost(index);
                    ToastMessage.showToast(
                      message: StaticString.postDeletedSuccess.tr,
                    );
                  },
                ),
              ] else ...[
                // Save
                ListTile(
                  leading: Icon(
                    post.isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_outline_rounded,
                    color: post.isSaved
                        ? Colors.blueAccent
                        : const Color(0xFF04070D),
                    size: 28,
                  ),
                  title: Text(
                    post.isSaved ? "Saved" : StaticString.save.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF04070D),
                    ),
                  ),
                  subtitle: Text(
                    post.isSaved
                        ? "Remove from saved posts"
                        : StaticString.saveSubtitle.tr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    controller.toggleSave(index);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                // Report
                ListTile(
                  leading: const Icon(
                    Icons.flag_outlined,
                    color: Colors.redAccent,
                    size: 28,
                  ),
                  title: Text(
                    StaticString.report.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF04070D),
                    ),
                  ),
                  subtitle: Text(
                    StaticString.reportSubtitle.tr,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showReportBottomSheet(context, index);
                  },
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportBottomSheet(BuildContext context, int index) {
    final controller = Get.find<HomeController>();
    final reasons = [
      "Spam",
      "Harassment",
      "Misinformation",
      "Inappropriate",
      "Violence",
      "Nudity",
      "Hate Speech",
      "Self-Harm",
      "Other",
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
                      icon: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
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
                    Obx(
                      () => Wrap(
                        spacing: 8,
                        runSpacing: 12,
                        children: reasons.map((reason) {
                          final isSelected = selectedReason.value == reason;
                          return ChoiceChip(
                            label: Text(
                              reason,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide.none,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
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
                          borderSide: BorderSide(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
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
                  onPressed: () async {
                    if (selectedReason.value.isEmpty) {
                      ToastMessage.showToast(
                        message: "Please select a reason for reporting",
                        isError: true,
                      );
                      return;
                    }
                    Navigator.pop(context);
                    await controller.reportPost(
                      index,
                      selectedReason.value,
                      textController.text,
                    );
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
