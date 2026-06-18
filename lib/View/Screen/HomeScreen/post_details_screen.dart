import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../helper/network_img/network_img.dart';
import '../../../Core/AppRoute/app_route.dart';
import '../../../helper/shared_prefe/shared_prefe.dart';
import '../../Widgegt/PostCard/post_card.dart';
import 'Controller/home_controller.dart';
import 'Model/post_model.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final HomeController controller = Get.find<HomeController>();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final Rxn<CommentModel> selectedReplyComment = Rxn<CommentModel>();
  final RxSet<String> expandedCommentIds = <String>{}.obs;
  late final int postIndex;
  List<PostModel>? postList;

  List<PostModel> get posts => postList ?? controller.posts;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map) {
      postIndex = args['index'] as int;
      postList = args['list'] as List<PostModel>?;
    } else {
      postIndex = args as int;
      postList = null;
    }
    controller.activePostDetailsIndex.value = postIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (postIndex >= 0 && postIndex < posts.length) {
        controller.fetchCommentsForPost(postIndex, list: postList);
      }
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        scrolledUnderElevation: 0,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textLight,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          StaticString.postDetails.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (postIndex < 0 || postIndex >= posts.length) {
                  return Center(child: Text(StaticString.postNotFound.tr));
                }
                final post = posts[postIndex];
                return SingleChildScrollView(
                  controller: controller.commentsScrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Original Post Item UI using reusable PostCard
                      PostCard(
                        postIndex: postIndex,
                        isClickable: false,
                        onCommentTap: () => _commentFocusNode.requestFocus(),
                        postList: postList,
                      ),

                      const Divider(height: 1, thickness: 0.5),

                      // Comments Section Header
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          StaticString.commentsCount.trParams({
                            'count': post.comments.length.toString(),
                          }),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF04070D),
                          ),
                        ),
                      ),

                      // Comments & Replies List
                      if (controller.isLoadingComments.value)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.blueAccent,
                            ),
                          ),
                        )
                      else if (post.comments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40.0),
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
                                                  onTap: () => controller.toggleLikeComment(postIndex, cIndex, list: postList),
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
                                                  onTap: () => controller.toggleDislikeComment(postIndex, cIndex, list: postList),
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
                                          controller.fetchRepliesForComment(postIndex, comment.id, list: postList);
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
                                                          onTap: () => controller.toggleLikeCommentReply(postIndex, comment.id, reply.id, list: postList),
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
                                                          onTap: () => controller.toggleDislikeCommentReply(postIndex, comment.id, reply.id, list: postList),
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
                            controller.addReply(postIndex, selectedReplyComment.value!.id, _textController.text, list: postList);
                            expandedCommentIds.add(
                              selectedReplyComment.value!.id,
                            );
                            selectedReplyComment.value = null;
                          } else {
                            controller.addComment(postIndex, _textController.text, list: postList);
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
