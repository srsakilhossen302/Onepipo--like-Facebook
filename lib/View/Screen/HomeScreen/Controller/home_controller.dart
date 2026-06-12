import 'package:get/get.dart';
import '../Model/post_model.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';

class HomeController extends GetxController {
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMockPosts();
  }

  void loadMockPosts() {
    posts.assignAll([
      PostModel(
        id: '1',
        userName: 'Ahmed Wahid',
        userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        timeAgo: '1h ago',
        badgeText: StaticString.solution,
        contentText: 'Are you ready to dive into this exciting journey? Let\'s get started by exploring the fundamentals together! 🚀 We\'ll cover everything you need to know to set a solid foundation for your adventure ahead. So, buckle up and let\'s embark on this learning experience!',
        likesCount: 23,
        commentsCount: 1,
        sharesCount: 8,
        isLiked: false,
        comments: [
          CommentModel(
            id: '101',
            userName: 'africa',
            userAvatarUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150',
            timeAgo: '1h',
            text: 'we need to free the children in Nigeria.',
            likesCount: 0,
            isLiked: false,
            isDisliked: false,
          ),
        ],
      ),
      PostModel(
        id: '2',
        userName: 'Elena Gonzalez',
        userAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        timeAgo: '1h ago',
        badgeText: StaticString.problem,
        contentText: 'Are you ready to dive into this exciting journey? Let\'s get started by exploring the fundamentals together',
        contentImageUrl: 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=800',
        likesCount: 23,
        commentsCount: 1,
        sharesCount: 8,
        isLiked: false,
        comments: [
          CommentModel(
            id: '102',
            userName: 'africa',
            userAvatarUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150',
            timeAgo: '1h',
            text: 'we need to free the children in Nigeria.',
            likesCount: 0,
            isLiked: false,
            isDisliked: false,
          ),
        ],
      ),
      PostModel(
        id: '3',
        userName: 'Ahmed Wahid',
        userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        timeAgo: '1h ago',
        badgeText: StaticString.solution,
        contentText: 'Are you ready to dive into this exciting journey? Let\'s get started by exploring the fundamentals together',
        likesCount: 23,
        commentsCount: 1,
        sharesCount: 8,
        isLiked: false,
        comments: [
          CommentModel(
            id: '103',
            userName: 'africa',
            userAvatarUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150',
            timeAgo: '1h',
            text: 'we need to free the children in Nigeria.',
            likesCount: 0,
            isLiked: false,
            isDisliked: false,
          ),
        ],
      ),
    ]);
  }

  void toggleLike(int index) {
    if (index < 0 || index >= posts.length) return;
    
    final post = posts[index];
    if (post.isLiked) {
      post.isLiked = false;
      post.likesCount--;
    } else {
      post.isLiked = true;
      post.likesCount++;
    }
    posts[index] = post;
    posts.refresh();
  }

  void addComment(int index, String commentText) {
    if (index < 0 || index >= posts.length || commentText.trim().isEmpty) return;
    
    final post = posts[index];
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'shahriar',
      userAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      timeAgo: 'Just now',
      text: commentText,
      likesCount: 0,
      isLiked: false,
      isDisliked: false,
    );
    post.comments.add(newComment);
    post.commentsCount = post.comments.length;
    posts[index] = post;
    posts.refresh();
    
    ToastMessage.showToast(message: StaticString.commentAdded.tr);
  }

  void toggleLikeComment(int postIndex, int commentIndex) {
    if (postIndex < 0 || postIndex >= posts.length) return;
    final post = posts[postIndex];
    if (commentIndex < 0 || commentIndex >= post.comments.length) return;
    final comment = post.comments[commentIndex];
    
    if (comment.isLiked) {
      comment.isLiked = false;
      comment.likesCount--;
    } else {
      comment.isLiked = true;
      comment.likesCount++;
      if (comment.isDisliked) {
        comment.isDisliked = false;
      }
    }
    posts[postIndex] = post;
    posts.refresh();
  }

  void toggleDislikeComment(int postIndex, int commentIndex) {
    if (postIndex < 0 || postIndex >= posts.length) return;
    final post = posts[postIndex];
    if (commentIndex < 0 || commentIndex >= post.comments.length) return;
    final comment = post.comments[commentIndex];
    
    if (comment.isDisliked) {
      comment.isDisliked = false;
    } else {
      comment.isDisliked = true;
      if (comment.isLiked) {
        comment.isLiked = false;
        comment.likesCount--;
      }
    }
    posts[postIndex] = post;
    posts.refresh();
  }

  void addReply(int postIndex, String parentCommentId, String replyText) {
    if (postIndex < 0 || postIndex >= posts.length || replyText.trim().isEmpty) return;
    
    final post = posts[postIndex];
    final parentComment = post.comments.firstWhereOrNull((c) => c.id == parentCommentId);
    if (parentComment == null) return;

    final newReply = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'shahriar',
      userAvatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      timeAgo: 'Just now',
      text: replyText,
      likesCount: 0,
      isLiked: false,
      isDisliked: false,
    );

    parentComment.replies.add(newReply);
    post.commentsCount++;
    posts[postIndex] = post;
    posts.refresh();
    
    ToastMessage.showToast(message: StaticString.commentAdded.tr);
  }

  void toggleLikeCommentReply(int postIndex, String parentCommentId, String replyId) {
    if (postIndex < 0 || postIndex >= posts.length) return;
    final post = posts[postIndex];
    final parentComment = post.comments.firstWhereOrNull((c) => c.id == parentCommentId);
    if (parentComment == null) return;
    final reply = parentComment.replies.firstWhereOrNull((r) => r.id == replyId);
    if (reply == null) return;
    
    if (reply.isLiked) {
      reply.isLiked = false;
      reply.likesCount--;
    } else {
      reply.isLiked = true;
      reply.likesCount++;
      if (reply.isDisliked) {
        reply.isDisliked = false;
      }
    }
    posts[postIndex] = post;
    posts.refresh();
  }

  void toggleDislikeCommentReply(int postIndex, String parentCommentId, String replyId) {
    if (postIndex < 0 || postIndex >= posts.length) return;
    final post = posts[postIndex];
    final parentComment = post.comments.firstWhereOrNull((c) => c.id == parentCommentId);
    if (parentComment == null) return;
    final reply = parentComment.replies.firstWhereOrNull((r) => r.id == replyId);
    if (reply == null) return;
    
    if (reply.isDisliked) {
      reply.isDisliked = false;
    } else {
      reply.isDisliked = true;
      if (reply.isLiked) {
        reply.isLiked = false;
        reply.likesCount--;
      }
    }
    posts[postIndex] = post;
    posts.refresh();
  }

  void sharePost(int index) {
    if (index < 0 || index >= posts.length) return;
    
    final post = posts[index];
    post.sharesCount++;
    posts[index] = post;
    posts.refresh();
    
    ToastMessage.showSnackBar(
      title: StaticString.shared.tr,
      message: StaticString.sharedMsg.tr,
    );
  }

  Future<void> refreshFeed() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    loadMockPosts();
    isLoading.value = false;
  }
}
