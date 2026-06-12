import 'package:get/get.dart';
import '../Model/post_model.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';

class FollowerModel {
  final String id;
  final String name;
  final String avatarUrl;

  FollowerModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });
}

class HomeController extends GetxController {
  var posts = <PostModel>[].obs;
  var followers = <FollowerModel>[].obs;
  var userFollowers = <String, List<FollowerModel>>{}.obs;
  var userFollowing = <String, List<FollowerModel>>{}.obs;
  var sharedFollowers = <String, Set<String>>{}.obs;
  var isLoading = false.obs;
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    loadMockPosts();
    loadMockFollowers();
  }

  void loadMockFollowers() {
    final owolabi = FollowerModel(
      id: '1',
      name: 'Owolabi Ridwan',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    );
    final elena = FollowerModel(
      id: '2',
      name: 'Elena Gonzalez',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
    );
    final africa = FollowerModel(
      id: '3',
      name: 'Africa',
      avatarUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150',
    );
    final ahmed = FollowerModel(
      id: '4',
      name: 'Ahmed Wahid',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
    );
    final shahriarModel = FollowerModel(
      id: '5',
      name: 'Shahriar',
      avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
    );

    // Set initial followers
    userFollowers['Shahriar'] = [owolabi, elena, africa].obs;
    userFollowers['Ahmed Wahid'] = [elena, shahriarModel].obs;
    userFollowers['Elena Gonzalez'] = [owolabi, africa, shahriarModel].obs;
    userFollowers['Africa'] = [elena, ahmed, shahriarModel].obs;

    // Set initial following
    userFollowing['Shahriar'] = [elena, ahmed].obs;
    userFollowing['Ahmed Wahid'] = [elena, africa].obs;
    userFollowing['Elena Gonzalez'] = [owolabi, africa, ahmed, shahriarModel].obs;
    userFollowing['Africa'] = [elena, ahmed].obs;

    followers.assignAll([owolabi, elena, africa, ahmed]);
  }

  void loadMockPosts() {
    posts.assignAll([
      PostModel(
        id: '1',
        userName: 'Ahmed Wahid',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        timeAgo: '1h ago',
        badgeText: StaticString.solution,
        contentText:
            'Are you ready to dive into this exciting journey? Let\'s get started by exploring the fundamentals together! 🚀 We\'ll cover everything you need to know to set a solid foundation for your adventure ahead. So, buckle up and let\'s embark on this learning experience!',
        likesCount: 23,
        commentsCount: 1,
        sharesCount: 8,
        isLiked: false,
        comments: [
          CommentModel(
            id: '101',
            userName: 'africa',
            userAvatarUrl:
                'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150',
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
        userAvatarUrl:
            'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        timeAgo: '1h ago',
        badgeText: StaticString.problem,
        contentText:
            'Are you ready to dive into this exciting journey? Let\'s get started by exploring the fundamentals together',
        contentImageUrl:
            'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=800',
        likesCount: 23,
        commentsCount: 1,
        sharesCount: 8,
        isLiked: false,
        comments: [
          CommentModel(
            id: '102',
            userName: 'africa',
            userAvatarUrl:
                'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150',
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
        userAvatarUrl:
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        timeAgo: '1h ago',
        badgeText: StaticString.solution,
        contentText:
            'Are you ready to dive into this exciting journey? Let\'s get started by exploring the fundamentals together',
        likesCount: 23,
        commentsCount: 1,
        sharesCount: 8,
        isLiked: false,
        comments: [
          CommentModel(
            id: '103',
            userName: 'africa',
            userAvatarUrl:
                'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150',
            timeAgo: '1h',
            text: 'we need to free the children in Nigeria.',
            likesCount: 0,
            isLiked: false,
            isDisliked: false,
          ),
        ],
      ),
      PostModel(
        id: '4',
        userName: 'Shahriar',
        userAvatarUrl:
            'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
        timeAgo: '2h ago',
        badgeText: StaticString.solution,
        contentText:
            'Excited to join Onepipo! Building the future of social networking with a clean and premium design system. Let\'s connect and build together! 🚀💻',
        likesCount: 15,
        commentsCount: 0,
        sharesCount: 3,
        isLiked: false,
        comments: [],
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
    if (index < 0 || index >= posts.length || commentText.trim().isEmpty)
      return;

    final post = posts[index];
    final newComment = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'shahriar',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
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
    if (postIndex < 0 || postIndex >= posts.length || replyText.trim().isEmpty)
      return;

    final post = posts[postIndex];
    final parentComment = post.comments.firstWhereOrNull(
      (c) => c.id == parentCommentId,
    );
    if (parentComment == null) return;

    final newReply = CommentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'shahriar',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
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

  void toggleLikeCommentReply(
    int postIndex,
    String parentCommentId,
    String replyId,
  ) {
    if (postIndex < 0 || postIndex >= posts.length) return;
    final post = posts[postIndex];
    final parentComment = post.comments.firstWhereOrNull(
      (c) => c.id == parentCommentId,
    );
    if (parentComment == null) return;
    final reply = parentComment.replies.firstWhereOrNull(
      (r) => r.id == replyId,
    );
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

  void toggleDislikeCommentReply(
    int postIndex,
    String parentCommentId,
    String replyId,
  ) {
    if (postIndex < 0 || postIndex >= posts.length) return;
    final post = posts[postIndex];
    final parentComment = post.comments.firstWhereOrNull(
      (c) => c.id == parentCommentId,
    );
    if (parentComment == null) return;
    final reply = parentComment.replies.firstWhereOrNull(
      (r) => r.id == replyId,
    );
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

  void shareWithFollower(int postIndex, String followerId) {
    if (postIndex < 0 || postIndex >= posts.length) return;
    final post = posts[postIndex];

    var sentSet =
        Map<String, Set<String>>.from(sharedFollowers)[post.id] ?? <String>{};
    if (sentSet.contains(followerId)) return;

    final newSet = Set<String>.from(sentSet)..add(followerId);
    sharedFollowers[post.id] = newSet;
    sharedFollowers.refresh();

    post.sharesCount++;
    posts[postIndex] = post;
    posts.refresh();
  }

  bool isFollowerShared(String postId, String followerId) {
    return sharedFollowers[postId]?.contains(followerId) ?? false;
  }

  void addNewPost(String contentText, String badgeText, {String? groupName, List<String>? taggedFriends, String? contentImageUrl}) {
    if (contentText.trim().isEmpty && contentImageUrl == null) return;

    final newPost = PostModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: 'Shahriar',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
      timeAgo: 'Just now',
      badgeText: badgeText,
      contentText: contentText,
      contentImageUrl: contentImageUrl,
      groupName: groupName,
      taggedFriends: taggedFriends,
      likesCount: 0,
      commentsCount: 0,
      sharesCount: 0,
      isLiked: false,
      comments: [],
    );

    posts.insert(0, newPost);
    posts.refresh();

    ToastMessage.showToast(message: StaticString.postCreatedSuccess.tr);
  }

  void updatePost(int index, String contentText, String badgeText, {String? groupName, List<String>? taggedFriends, String? contentImageUrl}) {
    if (index >= 0 && index < posts.length) {
      final post = posts[index];
      post.contentText = contentText;
      post.badgeText = badgeText;
      post.groupName = groupName;
      post.taggedFriends = taggedFriends;
      post.contentImageUrl = contentImageUrl;
      posts[index] = post;
      posts.refresh();
      ToastMessage.showToast(message: StaticString.postUpdatedSuccess.tr);
    }
  }

  Future<void> refreshFeed() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    loadMockPosts();
    isLoading.value = false;
  }

  void toggleFollowUser(String targetUserName) {
    final currentUserName = 'Shahriar';
    if (targetUserName.toLowerCase() == currentUserName.toLowerCase()) return;

    final targetUserAvatar = _getUserAvatar(targetUserName);
    final followingList = userFollowing[currentUserName] ?? <FollowerModel>[];
    final isAlreadyFollowing = followingList.any((u) => u.name.toLowerCase() == targetUserName.toLowerCase());

    if (isAlreadyFollowing) {
      // Unfollow
      userFollowing[currentUserName]?.removeWhere((u) => u.name.toLowerCase() == targetUserName.toLowerCase());
      userFollowers[targetUserName]?.removeWhere((u) => u.name.toLowerCase() == currentUserName.toLowerCase());
      ToastMessage.showToast(message: StaticString.unfollowedUser.trParams({'name': targetUserName}));
    } else {
      // Follow
      final currentModel = FollowerModel(
        id: '5',
        name: currentUserName,
        avatarUrl: _getUserAvatar(currentUserName),
      );
      final targetModel = FollowerModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: targetUserName,
        avatarUrl: targetUserAvatar,
      );

      if (userFollowing[currentUserName] == null) {
        userFollowing[currentUserName] = <FollowerModel>[].obs;
      }
      userFollowing[currentUserName]!.add(targetModel);

      if (userFollowers[targetUserName] == null) {
        userFollowers[targetUserName] = <FollowerModel>[].obs;
      }
      userFollowers[targetUserName]!.add(currentModel);

      ToastMessage.showToast(message: StaticString.followingUser.trParams({'name': targetUserName}));
    }

    userFollowing.refresh();
    userFollowers.refresh();
  }

  void removeFollower(String followerName) {
    final currentUserName = 'Shahriar';
    userFollowers[currentUserName]?.removeWhere((u) => u.name.toLowerCase() == followerName.toLowerCase());
    userFollowing[followerName]?.removeWhere((u) => u.name.toLowerCase() == currentUserName.toLowerCase());

    userFollowers.refresh();
    userFollowing.refresh();
    ToastMessage.showToast(message: StaticString.removedFromFollowers.trParams({'name': followerName}));
  }

  void deletePost(int index) {
    if (index >= 0 && index < posts.length) {
      posts.removeAt(index);
    }
  }

  String _getUserAvatar(String name) {
    if (name.toLowerCase() == 'shahriar') {
      return 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';
    } else if (name.toLowerCase() == 'elena gonzalez') {
      return 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150';
    } else if (name.toLowerCase() == 'africa') {
      return 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150';
    } else if (name.toLowerCase() == 'ahmed wahid') {
      return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150';
    }
    return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150';
  }
}
