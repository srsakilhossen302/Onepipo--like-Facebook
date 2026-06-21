import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../Model/post_model.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/api_check.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';

class FollowerModel {
  final String id;
  final String name;
  final String avatarUrl;
  final Map<String, dynamic>? rawJson;

  FollowerModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.rawJson,
  });
}

class HomeController extends GetxController {
  var posts = <PostModel>[].obs;
  var savedPosts = <PostModel>[].obs;
  var archivedPosts = <PostModel>[].obs;
  var followers = <FollowerModel>[].obs;
  var userFollowers = <String, List<FollowerModel>>{}.obs;
  var userFollowing = <String, List<FollowerModel>>{}.obs;
  var sharedFollowers = <String, Set<String>>{}.obs;
  var blockedUsers = <FollowerModel>[].obs;
  var isLoadingBlockedUsers = false.obs;
  var isLoadingSavedPosts = false.obs;
  var isLoadingArchivedPosts = false.obs;
  var unblockingUserIds = <String>{}.obs;
  var isLoading = false.obs;
  var isLoadingComments = false.obs;
  var selectedIndex = 0.obs;

  // Pagination & Scroll variables for Posts Feed
  final ScrollController scrollController = ScrollController();
  int _currentPage = 1;
  bool _isMorePostsAvailable = true;
  var isLoadingMore = false.obs;

  // Pagination & Scroll variables for Comments
  final ScrollController commentsScrollController = ScrollController();
  int _currentCommentsPage = 1;
  bool _isMoreCommentsAvailable = true;
  var isLoadingMoreComments = false.obs;
  var activePostDetailsIndex = (-1).obs;

  String get loggedInUserName {
    try {
      final name = Get.find<SharedPreferenceHelper>().getUserName();
      return name.isEmpty ? 'Shahriar' : name;
    } catch (_) {
      return 'Shahriar';
    }
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    commentsScrollController.addListener(_commentsScrollListener);
    if (!Get.testMode) {
      fetchPosts();
      fetchBlockedUsers();
      fetchSavedPosts();
      fetchArchivedPosts();
    }
  }

  Future<void> fetchBlockedUsers() async {
    isLoadingBlockedUsers.value = true;
    try {
      final response = await Get.find<ApiClient>().get(ApiUrl.blockedUsersList);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final List<FollowerModel> users = data.map((json) {
            // Assuming API returns { id, name, avatar } or similar
            return FollowerModel(
              id:
                  json['id']?.toString() ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              name: json['name'] ?? 'Unknown',
              avatarUrl:
                  json['avatar'] ??
                  json['photo'] ??
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150',
            );
          }).toList();
          blockedUsers.assignAll(users);
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      print('Error fetching blocked users: $e');
    } finally {
      isLoadingBlockedUsers.value = false;
    }
  }

  Future<void> fetchSavedPosts() async {
    isLoadingSavedPosts.value = true;
    try {
      final response = await Get.find<ApiClient>().get(ApiUrl.savedPosts);
      print('Saved Posts API Response: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          savedPosts.value = data
              .map((json) => PostModel.fromJson(json))
              .toList();

          // Add any missing saved posts to main posts list
          final existingPostIds = posts.map((p) => p.id).toSet();
          for (final savedPost in savedPosts) {
            if (!existingPostIds.contains(savedPost.id)) {
              posts.add(savedPost);
            }
          }

          // Update isSaved in main posts list
          final savedPostIds = savedPosts.map((p) => p.id).toSet();
          for (int i = 0; i < posts.length; i++) {
            posts[i].isSaved = savedPostIds.contains(posts[i].id);
          }
          posts.refresh();
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      print('Error fetching saved posts: $e');
    } finally {
      isLoadingSavedPosts.value = false;
    }
  }

  Future<void> fetchArchivedPosts() async {
    isLoadingArchivedPosts.value = true;
    try {
      final response = await Get.find<ApiClient>().get(ApiUrl.archivedPosts);
      print('Archived Posts API Response: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          archivedPosts.value = data
              .map((json) => PostModel.fromJson(json))
              .toList();

          // Add any missing archived posts to main posts list
          final existingPostIds = posts.map((p) => p.id).toSet();
          for (final archivedPost in archivedPosts) {
            if (!existingPostIds.contains(archivedPost.id)) {
              posts.add(archivedPost);
            }
          }
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      print('Error fetching archived posts: $e');
    } finally {
      isLoadingArchivedPosts.value = false;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    commentsScrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!isLoading.value && !isLoadingMore.value && _isMorePostsAvailable) {
        fetchMorePosts();
      }
    }
  }

  void _commentsScrollListener() {
    if (commentsScrollController.position.pixels >=
        commentsScrollController.position.maxScrollExtent - 200) {
      if (!isLoadingComments.value &&
          !isLoadingMoreComments.value &&
          _isMoreCommentsAvailable &&
          activePostDetailsIndex.value != -1) {
        fetchMoreCommentsForPost(activePostDetailsIndex.value);
      }
    }
  }

  void _syncPostStateAcrossLists(PostModel updatedPost) {
    final idxInPosts = posts.indexWhere((p) => p.id == updatedPost.id);
    if (idxInPosts != -1) {
      posts[idxInPosts] = updatedPost;
      posts.refresh();
    }
    final idxInSaved = savedPosts.indexWhere((p) => p.id == updatedPost.id);
    if (idxInSaved != -1) {
      savedPosts[idxInSaved] = updatedPost;
      savedPosts.refresh();
    }
    final idxInArchived = archivedPosts.indexWhere(
      (p) => p.id == updatedPost.id,
    );
    if (idxInArchived != -1) {
      archivedPosts[idxInArchived] = updatedPost;
      archivedPosts.refresh();
    }
  }

  Future<void> toggleLike(int index, {List<PostModel>? list}) async {
    final postList = list ?? posts;
    if (index < 0 || index >= postList.length) return;

    final post = postList[index];
    final originalIsLiked = post.isLiked;
    final originalLikesCount = post.likesCount;

    if (post.isLiked) {
      post.isLiked = false;
      post.likesCount--;
    } else {
      post.isLiked = true;
      post.likesCount++;
    }
    postList[index] = post;
    if (postList is RxList) {
      (postList as RxList).refresh();
    }
    _syncPostStateAcrossLists(post);

    try {
      final response = await Get.find<ApiClient>().post(
        '/posts/${post.id}/like',
        body: {"type": "like"},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        post.isLiked = originalIsLiked;
        post.likesCount = originalLikesCount;
        postList[index] = post;
        if (postList is RxList) {
          (postList as RxList).refresh();
        }
        _syncPostStateAcrossLists(post);

        ApiCheck.checkApi(response);
      }
    } catch (e) {
      post.isLiked = originalIsLiked;
      post.likesCount = originalLikesCount;
      postList[index] = post;
      if (postList is RxList) {
        (postList as RxList).refresh();
      }
      _syncPostStateAcrossLists(post);

      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  Future<void> toggleSave(int index, {List<PostModel>? list}) async {
    final postList = list ?? posts;
    if (index < 0 || index >= postList.length) return;

    final post = postList[index];
    final originalIsSaved = post.isSaved;

    post.isSaved = !post.isSaved;
    postList[index] = post;
    if (postList is RxList) {
      (postList as RxList).refresh();
    }

    if (post.isSaved) {
      if (!savedPosts.any((p) => p.id == post.id)) {
        savedPosts.add(post);
        savedPosts.refresh();
      }
    } else {
      savedPosts.removeWhere((p) => p.id == post.id);
      savedPosts.refresh();
    }
    _syncPostStateAcrossLists(post);

    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.savePost(post.id),
        body: {},
      );
      print('Save Post API Response: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        post.isSaved = originalIsSaved;
        postList[index] = post;
        if (postList is RxList) {
          (postList as RxList).refresh();
        }

        if (originalIsSaved) {
          if (!savedPosts.any((p) => p.id == post.id)) {
            savedPosts.add(post);
          }
        } else {
          savedPosts.removeWhere((p) => p.id == post.id);
        }
        savedPosts.refresh();
        _syncPostStateAcrossLists(post);

        ApiCheck.checkApi(response);
      } else {
        try {
          final responseData = jsonDecode(response.body);
          bool savedFromApi = post.isSaved;
          final message =
              responseData['message']?.toString().toLowerCase() ?? '';
          if (message.contains('deleted') || message.contains('removed')) {
            savedFromApi = false;
          } else if (message.contains('saved') || message.contains('added')) {
            savedFromApi = true;
          } else if (responseData['data'] != null) {
            savedFromApi =
                responseData['data']['is_saved'] ??
                responseData['data']['saved'] ??
                post.isSaved;
          }

          post.isSaved = savedFromApi;
          postList[index] = post;
          if (postList is RxList) {
            (postList as RxList).refresh();
          }

          if (post.isSaved) {
            if (!savedPosts.any((p) => p.id == post.id)) {
              savedPosts.add(post);
            }
          } else {
            savedPosts.removeWhere((p) => p.id == post.id);
          }
          savedPosts.refresh();
          _syncPostStateAcrossLists(post);
        } catch (e) {
          print('Error parsing save response: $e');
        }

        ToastMessage.showToast(
          message: post.isSaved
              ? 'Successful save this post'
              : 'Removed from saved posts',
        );
      }
    } catch (e) {
      post.isSaved = originalIsSaved;
      postList[index] = post;
      if (postList is RxList) {
        (postList as RxList).refresh();
      }

      if (originalIsSaved) {
        if (!savedPosts.any((p) => p.id == post.id)) {
          savedPosts.add(post);
        }
      } else {
        savedPosts.removeWhere((p) => p.id == post.id);
      }
      savedPosts.refresh();
      _syncPostStateAcrossLists(post);

      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  Future<void> toggleArchive(int index, {List<PostModel>? list}) async {
    final postList = list ?? posts;
    if (index < 0 || index >= postList.length) return;

    final post = postList[index];
    final wasArchived = archivedPosts.any((p) => p.id == post.id);

    if (wasArchived) {
      archivedPosts.removeWhere((p) => p.id == post.id);
      archivedPosts.refresh();
      if (!posts.any((p) => p.id == post.id)) {
        posts.insert(0, post);
        posts.refresh();
      }
    } else {
      posts.removeWhere((p) => p.id == post.id);
      posts.refresh();
      if (!archivedPosts.any((p) => p.id == post.id)) {
        archivedPosts.add(post);
        archivedPosts.refresh();
      }
    }

    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.archivePost(post.id),
        body: {},
      );
      print('Archive Post API Response: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (wasArchived) {
          if (!archivedPosts.any((p) => p.id == post.id)) {
            archivedPosts.add(post);
            archivedPosts.refresh();
          }
          posts.removeWhere((p) => p.id == post.id);
          posts.refresh();
        } else {
          if (!posts.any((p) => p.id == post.id)) {
            posts.insert(index, post);
            posts.refresh();
          }
          archivedPosts.removeWhere((p) => p.id == post.id);
          archivedPosts.refresh();
        }
        ApiCheck.checkApi(response);
      } else {
        ToastMessage.showToast(
          message: wasArchived
              ? 'Post unarchived successfully!'
              : 'Post archived successfully!',
        );
      }
    } catch (e) {
      if (wasArchived) {
        if (!archivedPosts.any((p) => p.id == post.id)) {
          archivedPosts.add(post);
          archivedPosts.refresh();
        }
        posts.removeWhere((p) => p.id == post.id);
        posts.refresh();
      } else {
        if (!posts.any((p) => p.id == post.id)) {
          posts.insert(index, post);
          posts.refresh();
        }
        archivedPosts.removeWhere((p) => p.id == post.id);
        archivedPosts.refresh();
      }
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  Future<bool> reportPost(
    int index,
    String reason,
    String details, {
    List<PostModel>? list,
  }) async {
    final postList = list ?? posts;
    if (index < 0 || index >= postList.length) return false;

    final post = postList[index];
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.reportPost(post.id),
        body: {"reason": reason, "description": details},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessage.showToast(message: "Report submitted successfully");
        return true;
      } else {
        ApiCheck.checkApi(response);
        return false;
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
      return false;
    }
  }

  Future<void> addComment(
    int index,
    String commentText, {
    List<PostModel>? list,
  }) async {
    final postList = list ?? posts;
    if (index < 0 || index >= postList.length || commentText.trim().isEmpty)
      return;

    final post = postList[index];
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.comments(post.id),
        body: {"content": commentText, "mentions": ""},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        CommentModel newComment;
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          newComment = CommentModel.fromJson(responseData['data']);
        } else {
          final sharedPref = Get.find<SharedPreferenceHelper>();
          final savedName = sharedPref.getUserName();
          final savedPhoto = sharedPref.getUserPhoto();
          newComment = CommentModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userName: savedName.isNotEmpty ? savedName : 'User',
            userAvatarUrl: savedPhoto.isNotEmpty
                ? savedPhoto
                : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            timeAgo: 'Just now',
            text: commentText,
            likesCount: 0,
            isLiked: false,
            isDisliked: false,
          );
        }
        post.comments.add(newComment);
        post.commentsCount = post.comments.length;
        postList[index] = post;
        if (postList is RxList) {
          (postList as RxList).refresh();
        }
        _syncPostStateAcrossLists(post);

        ToastMessage.showToast(message: StaticString.commentAdded.tr);
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  Future<void> toggleLikeComment(
    int postIndex,
    int commentIndex, {
    List<PostModel>? list,
  }) async {
    final postList = list ?? posts;
    if (postIndex < 0 || postIndex >= postList.length) return;
    final post = postList[postIndex];
    if (commentIndex < 0 || commentIndex >= post.comments.length) return;
    final comment = post.comments[commentIndex];

    final originalIsLiked = comment.isLiked;
    final originalLikesCount = comment.likesCount;
    final originalIsDisliked = comment.isDisliked;

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
    postList[postIndex] = post;
    if (postList is RxList) {
      (postList as RxList).refresh();
    }
    _syncPostStateAcrossLists(post);

    try {
      final endpoint = originalIsLiked
          ? ApiUrl.unlikeComment(comment.id)
          : ApiUrl.likeComment(comment.id);

      final response = await Get.find<ApiClient>().post(
        endpoint,
        body: {"type": "like"},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        comment.isLiked = originalIsLiked;
        comment.likesCount = originalLikesCount;
        comment.isDisliked = originalIsDisliked;
        postList[postIndex] = post;
        if (postList is RxList) {
          (postList as RxList).refresh();
        }
        _syncPostStateAcrossLists(post);

        ApiCheck.checkApi(response);
      }
    } catch (e) {
      comment.isLiked = originalIsLiked;
      comment.likesCount = originalLikesCount;
      comment.isDisliked = originalIsDisliked;
      postList[postIndex] = post;
      if (postList is RxList) {
        (postList as RxList).refresh();
      }
      _syncPostStateAcrossLists(post);

      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  void toggleDislikeComment(
    int postIndex,
    int commentIndex, {
    List<PostModel>? list,
  }) {
    final postList = list ?? posts;
    if (postIndex < 0 || postIndex >= postList.length) return;
    final post = postList[postIndex];
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
    postList[postIndex] = post;
    if (postList is RxList) {
      (postList as RxList).refresh();
    }
    _syncPostStateAcrossLists(post);
  }

  Future<void> addReply(
    int postIndex,
    String parentCommentId,
    String replyText, {
    List<PostModel>? list,
  }) async {
    final postList = list ?? posts;
    if (postIndex < 0 ||
        postIndex >= postList.length ||
        replyText.trim().isEmpty)
      return;

    final post = postList[postIndex];
    final parentComment = post.comments.firstWhereOrNull(
      (c) => c.id == parentCommentId,
    );
    if (parentComment == null) return;

    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.commentReplies(parentCommentId),
        body: {"content": replyText},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        CommentModel newReply;
        if (responseData.containsKey('data') &&
            responseData['data'] is Map<String, dynamic>) {
          newReply = CommentModel.fromJson(responseData['data']);
        } else {
          final sharedPref = Get.find<SharedPreferenceHelper>();
          final savedName = sharedPref.getUserName();
          final savedPhoto = sharedPref.getUserPhoto();
          newReply = CommentModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userName: savedName.isNotEmpty ? savedName : 'User',
            userAvatarUrl: savedPhoto.isNotEmpty
                ? savedPhoto
                : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
            timeAgo: 'Just now',
            text: replyText,
            likesCount: 0,
            isLiked: false,
            isDisliked: false,
          );
        }

        parentComment.replies.add(newReply);
        parentComment.repliesCount = parentComment.replies.length;
        post.commentsCount++;
        postList[postIndex] = post;
        if (postList is RxList) {
          (postList as RxList).refresh();
        }
        _syncPostStateAcrossLists(post);

        ToastMessage.showToast(message: StaticString.commentAdded.tr);
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  Future<void> fetchRepliesForComment(
    int postIndex,
    String commentId, {
    List<PostModel>? list,
  }) async {
    final postList = list ?? posts;
    if (postIndex < 0 || postIndex >= postList.length) return;
    final post = postList[postIndex];
    final parentComment = post.comments.firstWhereOrNull(
      (c) => c.id == commentId,
    );
    if (parentComment == null) return;

    try {
      final response = await Get.find<ApiClient>().get(
        '${ApiUrl.commentReplies(commentId)}?per_page=10',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final List<CommentModel> fetchedReplies = data
              .map((json) => CommentModel.fromJson(json))
              .toList();
          parentComment.replies.clear();
          parentComment.replies.addAll(fetchedReplies);
          parentComment.repliesCount = parentComment.replies.length;
          postList[postIndex] = post;
          if (postList is RxList) {
            (postList as RxList).refresh();
          }
          _syncPostStateAcrossLists(post);
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  Future<void> toggleLikeCommentReply(
    int postIndex,
    String parentCommentId,
    String replyId, {
    List<PostModel>? list,
  }) async {
    final postList = list ?? posts;
    if (postIndex < 0 || postIndex >= postList.length) return;
    final post = postList[postIndex];
    final parentComment = post.comments.firstWhereOrNull(
      (c) => c.id == parentCommentId,
    );
    if (parentComment == null) return;
    final reply = parentComment.replies.firstWhereOrNull(
      (r) => r.id == replyId,
    );
    if (reply == null) return;

    final originalIsLiked = reply.isLiked;
    final originalLikesCount = reply.likesCount;
    final originalIsDisliked = reply.isDisliked;

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
    postList[postIndex] = post;
    if (postList is RxList) {
      (postList as RxList).refresh();
    }
    _syncPostStateAcrossLists(post);

    try {
      final endpoint = originalIsLiked
          ? ApiUrl.unlikeComment(reply.id)
          : ApiUrl.likeComment(reply.id);

      final response = await Get.find<ApiClient>().post(
        endpoint,
        body: {"type": "like"},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        reply.isLiked = originalIsLiked;
        reply.likesCount = originalLikesCount;
        reply.isDisliked = originalIsDisliked;
        postList[postIndex] = post;
        if (postList is RxList) {
          (postList as RxList).refresh();
        }
        _syncPostStateAcrossLists(post);

        ApiCheck.checkApi(response);
      }
    } catch (e) {
      reply.isLiked = originalIsLiked;
      reply.likesCount = originalLikesCount;
      reply.isDisliked = originalIsDisliked;
      postList[postIndex] = post;
      if (postList is RxList) {
        (postList as RxList).refresh();
      }
      _syncPostStateAcrossLists(post);

      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  void toggleDislikeCommentReply(
    int postIndex,
    String parentCommentId,
    String replyId, {
    List<PostModel>? list,
  }) {
    final postList = list ?? posts;
    if (postIndex < 0 || postIndex >= postList.length) return;
    final post = postList[postIndex];
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
    postList[postIndex] = post;
    if (postList is RxList) {
      (postList as RxList).refresh();
    }
    _syncPostStateAcrossLists(post);
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

  Future<void> shareWithFollower(
    int postIndex,
    String followerId, {
    List<PostModel>? list,
  }) async {
    final postList = list ?? posts;
    if (postIndex < 0 || postIndex >= postList.length) return;
    final post = postList[postIndex];

    var sentSet =
        Map<String, Set<String>>.from(sharedFollowers)[post.id] ?? <String>{};
    if (sentSet.contains(followerId)) return;

    final newSet = Set<String>.from(sentSet)..add(followerId);
    sharedFollowers[post.id] = newSet;
    sharedFollowers.refresh();

    post.sharesCount++;
    postList[postIndex] = post;
    if (postList is RxList) {
      (postList as RxList).refresh();
    }
    _syncPostStateAcrossLists(post);

    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.sharePost(post.id, followerId),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final revertedSet = Set<String>.from(newSet)..remove(followerId);
        sharedFollowers[post.id] = revertedSet;
        sharedFollowers.refresh();

        post.sharesCount--;
        postList[postIndex] = post;
        if (postList is RxList) {
          (postList as RxList).refresh();
        }
        _syncPostStateAcrossLists(post);

        ApiCheck.checkApi(response);
      }
    } catch (e) {
      final revertedSet = Set<String>.from(newSet)..remove(followerId);
      sharedFollowers[post.id] = revertedSet;
      sharedFollowers.refresh();

      post.sharesCount--;
      postList[postIndex] = post;
      if (postList is RxList) {
        (postList as RxList).refresh();
      }
      _syncPostStateAcrossLists(post);

      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  bool isFollowerShared(String postId, String followerId) {
    return sharedFollowers[postId]?.contains(followerId) ?? false;
  }

  Future<bool> addNewPost(
    String contentText,
    String badgeText, {
    String? groupName,
    List<String>? taggedFriends,
    String? contentImageUrl,
  }) async {
    if (contentText.trim().isEmpty && contentImageUrl == null) return false;

    final sharedPref = Get.find<SharedPreferenceHelper>();
    isLoading.value = true;
    try {
      final bool isLocalImage = contentImageUrl != null && !contentImageUrl.startsWith('http');
      final response = isLocalImage
          ? await Get.find<ApiClient>().postMultipart(
              ApiUrl.createPost,
              'image',
              contentImageUrl,
              fields: {
                "description": contentText,
                "type": badgeText,
                "is_anonymous": "0",
                "action": "create",
              },
            )
          : await Get.find<ApiClient>().post(
              ApiUrl.createPost,
              body: {
                "description": contentText,
                "type": badgeText,
                "is_anonymous": false,
                "action": "create",
                if (contentImageUrl != null) "image": contentImageUrl,
              },
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        PostModel newPost;
        if (responseData.containsKey('data') && responseData['data'] is Map<String, dynamic>) {
          newPost = PostModel.fromJson(responseData['data']);
        } else {
          final savedName = sharedPref.getUserName();
          newPost = PostModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            userName: savedName.isNotEmpty ? savedName : 'User',
            userAvatarUrl: sharedPref.getUserPhoto(),
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
        }

        posts.insert(0, newPost);
        posts.refresh();

        ToastMessage.showToast(message: StaticString.postCreatedSuccess.tr);
        return true;
      } else {
        ApiCheck.checkApi(response);
        return false;
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePost(
    int index,
    String contentText,
    String badgeText, {
    String? groupName,
    List<String>? taggedFriends,
    String? contentImageUrl,
    List<PostModel>? list,
  }) async {
    final postList = list ?? posts;
    if (index < 0 || index >= postList.length) return false;

    isLoading.value = true;
    try {
      final post = postList[index];
      final bool isLocalImage = contentImageUrl != null && !contentImageUrl.startsWith('http');
      final response = isLocalImage
          ? await Get.find<ApiClient>().postMultipart(
              ApiUrl.createPost,
              'image',
              contentImageUrl,
              fields: {
                "description": contentText,
                "type": badgeText,
                "is_anonymous": "0",
                "action": "edit",
                "post_id": post.id,
              },
            )
          : await Get.find<ApiClient>().post(
              ApiUrl.createPost,
              body: {
                "description": contentText,
                "type": badgeText,
                "is_anonymous": false,
                "image": contentImageUrl ?? "",
                "action": "edit",
                "post_id": int.tryParse(post.id) ?? 0,
              },
            );

      if (response.statusCode == 200 || response.statusCode == 201) {
        post.contentText = contentText;
        post.badgeText = badgeText;
        post.groupName = groupName;
        post.taggedFriends = taggedFriends;
        post.contentImageUrl = contentImageUrl;
        postList[index] = post;
        if (postList is RxList) {
          (postList as RxList).refresh();
        }
        _syncPostStateAcrossLists(post);
        ToastMessage.showToast(message: StaticString.postUpdatedSuccess.tr);
        return true;
      } else {
        ApiCheck.checkApi(response);
        return false;
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPosts() async {
    isLoading.value = true;
    _currentPage = 1;
    _isMorePostsAvailable = true;
    try {
      final response = await Get.find<ApiClient>().get(
        '${ApiUrl.posts}?page=1',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final List<PostModel> fetchedPosts = data
              .map((json) => PostModel.fromJson(json))
              .toList();

          final savedPostIds = savedPosts.map((p) => p.id).toSet();
          for (var post in fetchedPosts) {
            post.isSaved = savedPostIds.contains(post.id);
          }

          posts.assignAll(fetchedPosts);
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMorePosts() async {
    isLoadingMore.value = true;
    try {
      final response = await Get.find<ApiClient>().get(
        '${ApiUrl.posts}?page=${_currentPage + 1}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          if (data.isEmpty) {
            _isMorePostsAvailable = false;
          } else {
            final List<PostModel> fetchedPosts = data
                .map((json) => PostModel.fromJson(json))
                .toList();

            final savedPostIds = savedPosts.map((p) => p.id).toSet();
            for (var post in fetchedPosts) {
              post.isSaved = savedPostIds.contains(post.id);
            }

            posts.addAll(fetchedPosts);
            _currentPage++;
          }
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchCommentsForPost(int index, {List<PostModel>? list}) async {
    final postList = list ?? posts;
    if (index < 0 || index >= postList.length) return;

    final post = postList[index];
    isLoadingComments.value = true;
    _currentCommentsPage = 1;
    _isMoreCommentsAvailable = true;
    try {
      final response = await Get.find<ApiClient>().get(
        '${ApiUrl.comments(post.id)}?page=1',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final List<CommentModel> fetchedComments = data
              .map((json) => CommentModel.fromJson(json))
              .toList();
          post.comments.clear();
          post.comments.addAll(fetchedComments);
          post.commentsCount = post.comments.length;
          postList[index] = post;
          if (postList is RxList) {
            (postList as RxList).refresh();
          }
          _syncPostStateAcrossLists(post);
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> fetchMoreCommentsForPost(
    int index, {
    List<PostModel>? list,
  }) async {
    final postList = list ?? posts;
    if (index < 0 || index >= postList.length) return;

    final post = postList[index];
    isLoadingMoreComments.value = true;
    try {
      final response = await Get.find<ApiClient>().get(
        '${ApiUrl.comments(post.id)}?page=${_currentCommentsPage + 1}',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          if (data.isEmpty) {
            _isMoreCommentsAvailable = false;
          } else {
            final List<CommentModel> fetchedComments = data
                .map((json) => CommentModel.fromJson(json))
                .toList();
            post.comments.addAll(fetchedComments);
            post.commentsCount = post.comments.length;
            postList[index] = post;
            if (postList is RxList) {
              (postList as RxList).refresh();
            }
            _syncPostStateAcrossLists(post);
            _currentCommentsPage++;
          }
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    } finally {
      isLoadingMoreComments.value = false;
    }
  }

  Future<void> refreshFeed() async {
    await fetchPosts();
  }

  void toggleFollowUser(String targetUserName) {
    final currentUserName = loggedInUserName;
    if (targetUserName.toLowerCase() == currentUserName.toLowerCase()) return;

    final targetUserAvatar = _getUserAvatar(targetUserName);
    final followingList = userFollowing[currentUserName] ?? <FollowerModel>[];
    final isAlreadyFollowing = followingList.any(
      (u) => u.name.toLowerCase() == targetUserName.toLowerCase(),
    );

    if (isAlreadyFollowing) {
      // Unfollow
      userFollowing[currentUserName]?.removeWhere(
        (u) => u.name.toLowerCase() == targetUserName.toLowerCase(),
      );
      userFollowers[targetUserName]?.removeWhere(
        (u) => u.name.toLowerCase() == currentUserName.toLowerCase(),
      );
      ToastMessage.showToast(
        message: StaticString.unfollowedUser.trParams({'name': targetUserName}),
      );
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

      ToastMessage.showToast(
        message: StaticString.followingUser.trParams({'name': targetUserName}),
      );
    }

    userFollowing.refresh();
    userFollowers.refresh();
  }

  void removeFollower(String followerName) {
    final currentUserName = 'Shahriar';
    userFollowers[currentUserName]?.removeWhere(
      (u) => u.name.toLowerCase() == followerName.toLowerCase(),
    );
    userFollowing[followerName]?.removeWhere(
      (u) => u.name.toLowerCase() == currentUserName.toLowerCase(),
    );

    userFollowers.refresh();
    userFollowing.refresh();
    ToastMessage.showToast(
      message: StaticString.removedFromFollowers.trParams({
        'name': followerName,
      }),
    );
  }

  Future<bool> sendFollowRequest(String userId) async {
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.sendFollowRequest(userId),
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessage.showToast(message: "Follow request sent successfully");
        return true;
      } else {
        ApiCheck.checkApi(response);
        return false;
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
      return false;
    }
  }

  Future<bool> cancelFollowRequest(String userId) async {
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.cancelFollowRequest(userId),
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessage.showToast(message: "Follow request cancelled");
        return true;
      } else {
        ApiCheck.checkApi(response);
        return false;
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.unfollowUser(userId),
        body: {},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessage.showToast(message: "Unfollowed successfully");
        return true;
      } else {
        ApiCheck.checkApi(response);
        return false;
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
      return false;
    }
  }

  Future<bool> blockUser(String userId, String userName) async {
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.blockUser(userId),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Optimistically add to blocked list and remove from followers/following
        final currentUserName = loggedInUserName;
        final userAvatar = _getUserAvatar(userName);
        final blockedUser = FollowerModel(
          id: userId,
          name: userName,
          avatarUrl: userAvatar,
        );
        blockedUsers.add(blockedUser);

        // Remove from following and followers
        userFollowing[currentUserName]?.removeWhere(
          (u) => u.name.toLowerCase() == userName.toLowerCase(),
        );
        userFollowers[userName]?.removeWhere(
          (u) => u.name.toLowerCase() == currentUserName.toLowerCase(),
        );

        userFollowing.refresh();
        userFollowers.refresh();
        blockedUsers.refresh();

        return true;
      } else {
        ApiCheck.checkApi(response);
        return false;
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
      return false;
    }
  }

  Future<bool> unblockUser(String userId, String userName) async {
    // Mark user as being unblocked
    unblockingUserIds.add(userId);
    unblockingUserIds.refresh();

    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.unblockUser(userId),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Remove from blocked list
        blockedUsers.removeWhere((u) => u.id == userId);
        blockedUsers.refresh();
        ToastMessage.showToast(message: "Unblocked $userName");
        return true;
      } else {
        ApiCheck.checkApi(response);
        ToastMessage.showToast(message: "Failed to unblock user");
        return false;
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
      return false;
    } finally {
      // Remove user from unblocking set
      unblockingUserIds.remove(userId);
      unblockingUserIds.refresh();
    }
  }

  Future<void> deletePost(int index, {List<PostModel>? list}) async {
    final postList = list ?? posts;
    if (index < 0 || index >= postList.length) return;

    final post = postList[index];
    final originalIndex = index;

    postList.removeAt(index);
    if (postList is RxList) {
      (postList as RxList).refresh();
    }

    bool removedFromPosts = false;
    int indexInPosts = -1;
    if (postList != posts) {
      indexInPosts = posts.indexWhere((p) => p.id == post.id);
      if (indexInPosts != -1) {
        posts.removeAt(indexInPosts);
        posts.refresh();
        removedFromPosts = true;
      }
    }

    bool removedFromSaved = false;
    if (postList != savedPosts) {
      removedFromSaved = savedPosts.any((p) => p.id == post.id);
      savedPosts.removeWhere((p) => p.id == post.id);
      savedPosts.refresh();
    }

    bool removedFromArchived = false;
    if (postList != archivedPosts) {
      removedFromArchived = archivedPosts.any((p) => p.id == post.id);
      archivedPosts.removeWhere((p) => p.id == post.id);
      archivedPosts.refresh();
    }

    try {
      final response = await Get.find<ApiClient>().delete(
        ApiUrl.deletePost(post.id),
      );
      print('Delete Post API Response: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        if (originalIndex <= postList.length) {
          postList.insert(originalIndex, post);
        } else {
          postList.add(post);
        }
        if (postList is RxList) {
          (postList as RxList).refresh();
        }

        if (removedFromPosts && indexInPosts != -1) {
          if (indexInPosts <= posts.length) {
            posts.insert(indexInPosts, post);
          } else {
            posts.add(post);
          }
          posts.refresh();
        }
        if (removedFromSaved) {
          savedPosts.add(post);
          savedPosts.refresh();
        }
        if (removedFromArchived) {
          archivedPosts.add(post);
          archivedPosts.refresh();
        }
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      if (originalIndex <= postList.length) {
        postList.insert(originalIndex, post);
      } else {
        postList.add(post);
      }
      if (postList is RxList) {
        (postList as RxList).refresh();
      }

      if (removedFromPosts && indexInPosts != -1) {
        if (indexInPosts <= posts.length) {
          posts.insert(indexInPosts, post);
        } else {
          posts.add(post);
        }
        posts.refresh();
      }
      if (removedFromSaved) {
        savedPosts.add(post);
        savedPosts.refresh();
      }
      if (removedFromArchived) {
        archivedPosts.add(post);
        archivedPosts.refresh();
      }
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  String _getUserAvatar(String name) {
    try {
      final sharedPref = Get.find<SharedPreferenceHelper>();
      if (name.toLowerCase() == loggedInUserName.toLowerCase()) {
        final photo = sharedPref.getUserPhoto();
        if (photo.isNotEmpty) return photo;
      }
    } catch (_) {}

    if (name.toLowerCase() == 'elena gonzalez') {
      return 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150';
    } else if (name.toLowerCase() == 'africa') {
      return 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150';
    } else if (name.toLowerCase() == 'ahmed wahid') {
      return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150';
    }
    return 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150';
  }
}
