import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../helper/network_img/network_img.dart';
import '../../../Core/AppRoute/app_route.dart';
import '../../../helper/shared_prefe/shared_prefe.dart';
import '../../Screen/HomeScreen/Controller/home_controller.dart';
import '../../Screen/HomeScreen/Model/post_model.dart';

class CommentBottomSheet extends StatefulWidget {
  final int postIndex;

  const CommentBottomSheet({super.key, required this.postIndex});

  @override
  State<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends State<CommentBottomSheet> {
  final HomeController controller = Get.find<HomeController>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final Rxn<CommentModel> selectedReplyComment = Rxn<CommentModel>();
  final RxSet<String> expandedCommentIds = <String>{}.obs;

  @override
  void initState() {
    super.initState();
    controller.activePostDetailsIndex.value = widget.postIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCommentsForPost(widget.postIndex);
    });
  }

  @override
  void dispose() {
    controller.activePostDetailsIndex.value = -1;
    _textController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Widget _buildCommentText(String text, String parentUserName) {
    final trimmedText = text.trim();
    if (trimmedText.startsWith(parentUserName)) {
      final remainingText = trimmedText.substring(parentUserName.length);
      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Color(0xFF04070D)),
          children: [
            TextSpan(
              text: parentUserName,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: remainingText),
          ],
        ),
      );
    } else if (trimmedText.startsWith('@$parentUserName')) {
      final prefix = '@$parentUserName';
      final remainingText = trimmedText.substring(prefix.length);
      return RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 13, color: Color(0xFF04070D)),
          children: [
            TextSpan(
              text: prefix,
              style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(text: remainingText),
          ],
        ),
      );
    }

    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: Color(0xFF04070D)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
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
            const SizedBox(height: 12),
            // Header
            Obx(() {
              if (widget.postIndex < 0 ||
                  widget.postIndex >= controller.posts.length) {
                return const SizedBox.shrink();
              }
              final post = controller.posts[widget.postIndex];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StaticString.commentsCount.trParams({
                        'count': post.comments.length.toString(),
                      }),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF04070D),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              );
            }),
            const Divider(height: 1, thickness: 0.5),

            // Comments List Area
            Expanded(
              child: Obx(() {
                if (widget.postIndex < 0 ||
                    widget.postIndex >= controller.posts.length) {
                  return Center(child: Text(StaticString.postNotFound.tr));
                }
                final post = controller.posts[widget.postIndex];

                if (controller.isLoadingComments.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blueAccent),
                  );
                }

                return SingleChildScrollView(
                  controller: controller.commentsScrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 60.0),
                          child: Center(
                            child: Text(
                              StaticString.noCommentsYet.tr,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: post.comments.length,
                          itemBuilder: (context, cIndex) {
                            final comment = post.comments[cIndex];
                            final isExpanded = expandedCommentIds.contains(
                              comment.id,
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                          final bool isMyComment =
                                              sharedPrefHelper.isMe(
                                            userId: comment.userId.isNotEmpty
                                                ? comment.userId
                                                : comment.postUserId,
                                            userName: comment.userName,
                                            authorRaw: comment.authorRaw,
                                          );
                                          if (isMyComment) {
                                            Get.toNamed(AppRoute.myProfile);
                                          } else {
                                            Get.toNamed(
                                              AppRoute.profile,
                                              arguments: {
                                                'userId':
                                                    comment.userId.isNotEmpty
                                                    ? comment.userId
                                                    : comment.postUserId,
                                                'userName': comment.userName,
                                                'author': comment.authorRaw,
                                              },
                                            );
                                          }
                                        },
                                        child: NetworkImg(
                                          imageUrl: comment.userAvatarUrl,
                                          width: 36,
                                          height: 36,
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    final bool isMyComment =
                                                        sharedPrefHelper.isMe(
                                                      userId: comment.userId.isNotEmpty
                                                          ? comment.userId
                                                          : comment.postUserId,
                                                      userName: comment.userName,
                                                      authorRaw: comment.authorRaw,
                                                    );
                                                    if (isMyComment) {
                                                      Get.toNamed(
                                                        AppRoute.myProfile,
                                                      );
                                                    } else {
                                                      Get.toNamed(
                                                        AppRoute.profile,
                                                        arguments: {
                                                          'userId':
                                                              comment
                                                                  .userId
                                                                  .isNotEmpty
                                                              ? comment.userId
                                                              : comment
                                                                    .postUserId,
                                                          'userName':
                                                              comment.userName,
                                                          'author':
                                                              comment.authorRaw,
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: Text(
                                                    comment.userName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                      color: Color(0xFF04070D),
                                                    ),
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
                                                    selectedReplyComment.value =
                                                        comment;
                                                    _commentFocusNode
                                                        .requestFocus();
                                                  },
                                                  child: Text(
                                                    StaticString.reply.tr,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                GestureDetector(
                                                  onTap: () => controller
                                                      .toggleLikeComment(
                                                        widget.postIndex,
                                                        cIndex,
                                                      ),
                                                  child: Icon(
                                                    comment.isLiked
                                                        ? Icons
                                                              .thumb_up_alt_rounded
                                                        : Icons
                                                              .thumb_up_off_alt_rounded,
                                                    size: 16,
                                                    color: comment.isLiked
                                                        ? Colors.blueAccent
                                                        : Colors.grey[600],
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
                                                  onTap: () => controller
                                                      .toggleDislikeComment(
                                                        widget.postIndex,
                                                        cIndex,
                                                      ),
                                                  child: Icon(
                                                    comment.isDisliked
                                                        ? Icons
                                                              .thumb_down_alt_rounded
                                                        : Icons
                                                              .thumb_down_off_alt_rounded,
                                                    size: 16,
                                                    color: comment.isDisliked
                                                        ? Colors.redAccent
                                                        : Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Toggle Replies Expand/Collapse Button
                                  if (comment.replies.isNotEmpty ||
                                      comment.repliesCount > 0) ...[
                                    const SizedBox(height: 8),
                                    GestureDetector(
                                      onTap: () {
                                        if (isExpanded) {
                                          expandedCommentIds.remove(comment.id);
                                        } else {
                                          expandedCommentIds.add(comment.id);
                                          controller.fetchRepliesForComment(
                                            widget.postIndex,
                                            comment.id,
                                          );
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 48,
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              isExpanded
                                                  ? Icons
                                                        .keyboard_arrow_up_rounded
                                                  : Icons
                                                        .keyboard_arrow_down_rounded,
                                              size: 18,
                                              color: Colors.grey[600],
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isExpanded
                                                  ? StaticString.hideReplies.tr
                                                  : StaticString
                                                        .viewRepliesCount
                                                        .trParams({
                                                          'count': comment
                                                              .repliesCount
                                                              .toString(),
                                                        }),
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],

                                  // Replies list nested under this comment
                                  if (comment.replies.isNotEmpty &&
                                      isExpanded) ...[
                                    const SizedBox(height: 4),
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: comment.replies.length,
                                      itemBuilder: (context, rIndex) {
                                        final reply = comment.replies[rIndex];
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            left: 48,
                                            top: 6,
                                            bottom: 6,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  final bool isMyReply =
                                                      sharedPrefHelper.isMe(
                                                    userId: reply.userId.isNotEmpty
                                                        ? reply.userId
                                                        : reply.postUserId,
                                                    userName: reply.userName,
                                                    authorRaw: reply.authorRaw,
                                                  );
                                                  if (isMyReply) {
                                                    Get.toNamed(
                                                      AppRoute.myProfile,
                                                    );
                                                  } else {
                                                    Get.toNamed(
                                                      AppRoute.profile,
                                                      arguments: {
                                                        'userId':
                                                            reply
                                                                .userId
                                                                .isNotEmpty
                                                            ? reply.userId
                                                            : reply.postUserId,
                                                        'userName':
                                                            reply.userName,
                                                        'author':
                                                            reply.authorRaw,
                                                      },
                                                    );
                                                  }
                                                },
                                                child: NetworkImg(
                                                  imageUrl: reply.userAvatarUrl,
                                                  width: 28,
                                                  height: 28,
                                                  borderRadius:
                                                      BorderRadius.circular(14),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.pop(
                                                              context,
                                                            );
                                                            final bool isMyReply =
                                                                sharedPrefHelper.isMe(
                                                              userId: reply.userId.isNotEmpty
                                                                  ? reply.userId
                                                                  : reply.postUserId,
                                                              userName: reply.userName,
                                                              authorRaw: reply.authorRaw,
                                                            );
                                                            if (isMyReply) {
                                                              Get.toNamed(
                                                                AppRoute
                                                                    .myProfile,
                                                              );
                                                            } else {
                                                              Get.toNamed(
                                                                AppRoute
                                                                    .profile,
                                                                arguments: {
                                                                  'userId':
                                                                      reply
                                                                          .userId
                                                                          .isNotEmpty
                                                                      ? reply
                                                                            .userId
                                                                      : reply
                                                                            .postUserId,
                                                                  'userName': reply
                                                                      .userName,
                                                                  'author': reply
                                                                      .authorRaw,
                                                                },
                                                              );
                                                            }
                                                          },
                                                          child: Text(
                                                            reply.userName,
                                                            style:
                                                                const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13,
                                                                  color: Color(
                                                                    0xFF04070D,
                                                                  ),
                                                                ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          reply.timeAgo,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey[500],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 2),
                                                    _buildCommentText(
                                                      reply.text,
                                                      comment.userName,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Row(
                                                      children: [
                                                        const Spacer(),
                                                        GestureDetector(
                                                          onTap: () => controller
                                                              .toggleLikeCommentReply(
                                                                widget
                                                                    .postIndex,
                                                                comment.id,
                                                                reply.id,
                                                              ),
                                                          child: Icon(
                                                            reply.isLiked
                                                                ? Icons
                                                                      .thumb_up_alt_rounded
                                                                : Icons
                                                                      .thumb_up_off_alt_rounded,
                                                            size: 14,
                                                            color: reply.isLiked
                                                                ? Colors
                                                                      .blueAccent
                                                                : Colors
                                                                      .grey[600],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 4,
                                                        ),
                                                        Text(
                                                          '${reply.likesCount}',
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 12,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () => controller
                                                              .toggleDislikeCommentReply(
                                                                widget
                                                                    .postIndex,
                                                                comment.id,
                                                                reply.id,
                                                              ),
                                                          child: Icon(
                                                            reply.isDisliked
                                                                ? Icons
                                                                      .thumb_down_alt_rounded
                                                                : Icons
                                                                      .thumb_down_off_alt_rounded,
                                                            size: 14,
                                                            color:
                                                                reply.isDisliked
                                                                ? Colors
                                                                      .redAccent
                                                                : Colors
                                                                      .grey[600],
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
                        ),
                      if (controller.isLoadingMoreComments.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),

            // Reply Target Indicator Bar
            Obx(() {
              if (selectedReplyComment.value == null)
                return const SizedBox.shrink();
              return Container(
                color: const Color(0xFFF9FAFB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      StaticString.replyingToUser.trParams({
                        'name': selectedReplyComment.value!.userName,
                      }),
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
                          controller: _textController,
                          focusNode: _commentFocusNode,
                          decoration: InputDecoration(
                            hintText: isReplying
                                ? StaticString.replyToUserHint.trParams({
                                    'name': replyUser,
                                  })
                                : StaticString.commentingAsUser.trParams({
                                    'name': sharedPrefHelper.getUserName(),
                                  }),
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        if (_textController.text.trim().isNotEmpty) {
                          if (isReplying) {
                            controller.addReply(
                              widget.postIndex,
                              selectedReplyComment.value!.id,
                              _textController.text,
                            );
                            expandedCommentIds.add(
                              selectedReplyComment.value!.id,
                            );
                            selectedReplyComment.value = null;
                          } else {
                            controller.addComment(
                              widget.postIndex,
                              _textController.text,
                            );
                          }
                          _textController.clear();
                          _commentFocusNode.unfocus();
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
