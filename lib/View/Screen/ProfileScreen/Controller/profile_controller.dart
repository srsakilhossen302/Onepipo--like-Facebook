import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../HomeScreen/Controller/home_controller.dart';
import 'my_profile_controller.dart';
import '../../HomeScreen/Model/post_model.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/api_check.dart';

class ProfileController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  
  late String userName;
  late String userId;
  var userPosts = <PostModel>[].obs;
  var isFollowing = false.obs;
  var isPending = false.obs;
  final isLoadingPosts = false.obs;
  final isLoadingMore = false.obs;

  // Reactive observables for dynamic user stats
  final userPhotoUrl = "".obs;
  final userCoverUrl = "".obs;
  final userBio = "".obs;
  final userFollowersCount = 0.obs;
  final userFollowingCount = 0.obs;
  final userPostsCount = 0.obs;
  final userLocation = "".obs;
  final userCountry = "".obs;
  final userCity = "".obs;

  final ScrollController scrollController = ScrollController();
  int _currentPage = 1;
  bool _isMorePostsAvailable = true;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingPosts.value && !isLoadingMore.value && _isMorePostsAvailable) {
        fetchMoreUserPosts();
      }
    }
  }

  Future<void> initUser(String name, {String? userId, Map<String, dynamic>? authorData}) async {
    userName = name;
    this.userId = userId ?? getUserIdByUsername(name);
    
    // Default initializations
    userPhotoUrl.value = "";
    userCoverUrl.value = "";
    userBio.value = "Member of Onepipo community";
    userFollowersCount.value = (homeController.userFollowers[userName] ?? []).length;
    userFollowingCount.value = (homeController.userFollowing[userName] ?? []).length;
    userPostsCount.value = 0;
    userLocation.value = "";
    userCountry.value = "";
    userCity.value = "";

    if (authorData != null) {
      _parseAuthorData(authorData);
    }

    updateFollowStatus();
    loadUserPosts();
    
    // Listen to changes in home controller posts to refresh user posts
    ever(homeController.posts, (_) => loadUserPosts());
    
    await fetchUserPosts();
  }

  void _parseAuthorData(Map<String, dynamic> authorData) {
    if (authorData.containsKey('photo') && authorData['photo'] != null) {
      userPhotoUrl.value = authorData['photo'].toString();
    }
    if (authorData.containsKey('posts_count') && authorData['posts_count'] != null) {
      userPostsCount.value = authorData['posts_count'] as int;
    }
    
    final profile = authorData['profile'] as Map<String, dynamic>?;
    if (profile != null) {
      if (profile.containsKey('bio') && profile['bio'] != null) {
        userBio.value = profile['bio'].toString();
      }
      if (profile.containsKey('followers_count') && profile['followers_count'] != null) {
        userFollowersCount.value = profile['followers_count'] as int;
      }
      if (profile.containsKey('following_count') && profile['following_count'] != null) {
        userFollowingCount.value = profile['following_count'] as int;
      }
      if (profile.containsKey('cover_photo') && profile['cover_photo'] != null) {
        userCoverUrl.value = profile['cover_photo'].toString();
      } else if (profile.containsKey('cover') && profile['cover'] != null) {
        userCoverUrl.value = profile['cover'].toString();
      }
      if (profile.containsKey('location') && profile['location'] != null) {
        userLocation.value = profile['location'].toString();
      }
      if (profile.containsKey('country') && profile['country'] != null) {
        userCountry.value = profile['country'].toString();
      }
      if (profile.containsKey('city') && profile['city'] != null) {
        userCity.value = profile['city'].toString();
      }
    } else {
      if (authorData.containsKey('bio') && authorData['bio'] != null) {
        userBio.value = authorData['bio'].toString();
      }
      if (authorData.containsKey('followers_count') && authorData['followers_count'] != null) {
        userFollowersCount.value = authorData['followers_count'] as int;
      }
      if (authorData.containsKey('following_count') && authorData['following_count'] != null) {
        userFollowingCount.value = authorData['following_count'] as int;
      }
      if (authorData.containsKey('cover_photo') && authorData['cover_photo'] != null) {
        userCoverUrl.value = authorData['cover_photo'].toString();
      } else if (authorData.containsKey('cover') && authorData['cover'] != null) {
        userCoverUrl.value = authorData['cover'].toString();
      }
      if (authorData.containsKey('location') && authorData['location'] != null) {
        userLocation.value = authorData['location'].toString();
      }
    }

    // Parse follow relationship status
    isFollowing.value = profile != null
        ? (profile['is_following'] ?? authorData['is_following'] ?? isFollowing.value)
        : (authorData['is_following'] ?? isFollowing.value);

    isPending.value = profile != null
        ? (profile['pending_following'] ?? authorData['pending_following'] ?? isPending.value)
        : (authorData['pending_following'] ?? isPending.value);
  }

  void updateFollowStatus() {
    final hasLocalFollowing = (homeController.userFollowing[homeController.loggedInUserName] ?? [])
        .any((u) => u.name.toLowerCase() == userName.toLowerCase());
    if (hasLocalFollowing) {
      isFollowing.value = true;
      isPending.value = false;
    }
  }

  void loadUserPosts() {
    userPosts.assignAll(homeController.posts.where((p) {
      return p.userName.toLowerCase() == userName.toLowerCase();
    }).toList());
  }

  String getUserIdByUsername(String name) {
    // 1. Try to find user ID dynamically from the home feed posts
    final post = homeController.posts.firstWhereOrNull(
      (p) => p.userName.toLowerCase() == name.toLowerCase() && 
             p.postUserId.isNotEmpty
    );
    if (post != null) return post.postUserId;

    // 2. Try to find user ID from the followers list
    final follower = homeController.followers.firstWhereOrNull(
      (f) => f.name.toLowerCase() == name.toLowerCase()
    );
    if (follower != null) return follower.id;

    // 3. Try to find user ID from the following list
    for (var list in homeController.userFollowing.values) {
      final user = list.firstWhereOrNull((u) => u.name.toLowerCase() == name.toLowerCase());
      if (user != null) return user.id;
    }
    return '';
  }

  Future<void> fetchUserPosts() async {
    isLoadingPosts.value = true;
    _currentPage = 1;
    _isMorePostsAvailable = true;
    try {
      final response = await Get.find<ApiClient>().get('${ApiUrl.userPosts(userId)}?page=1&per_page=10');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final List<PostModel> fetchedPosts = data.map((json) => PostModel.fromJson(json)).toList();
          
          if (fetchedPosts.isEmpty) {
            _isMorePostsAvailable = false;
          } else {
            // Update author stats dynamically from fetched data
            final firstPost = fetchedPosts.first;
            if (firstPost.authorRaw != null) {
              _parseAuthorData(firstPost.authorRaw!);
            }
          }
          
          // Merge fetched posts into homeController.posts
          for (var post in fetchedPosts) {
            final idx = homeController.posts.indexWhere((p) => p.id == post.id);
            if (idx != -1) {
              homeController.posts[idx] = post;
            } else {
              homeController.posts.add(post);
            }
          }
          homeController.posts.refresh();
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      print('Error fetching user posts: $e');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  Future<void> fetchMoreUserPosts() async {
    isLoadingMore.value = true;
    try {
      final response = await Get.find<ApiClient>().get('${ApiUrl.userPosts(userId)}?page=${_currentPage + 1}&per_page=10');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          if (data.isEmpty) {
            _isMorePostsAvailable = false;
          } else {
            final List<PostModel> fetchedPosts = data.map((json) => PostModel.fromJson(json)).toList();
            
            // Merge fetched posts into homeController.posts
            for (var post in fetchedPosts) {
              final idx = homeController.posts.indexWhere((p) => p.id == post.id);
              if (idx != -1) {
                homeController.posts[idx] = post;
              } else {
                homeController.posts.add(post);
              }
            }
            homeController.posts.refresh();
            _currentPage++;
          }
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      print('Error fetching more user posts: $e');
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> unfollowUser() async {
    isFollowing.value = false;
    final success = await homeController.unfollowUser(userId);
    if (success) {
      if (userFollowersCount.value > 0) {
        userFollowersCount.value--;
      }
      try {
        Get.find<MyProfileController>().decreaseFollowingCount();
      } catch (_) {}
      homeController.userFollowing[homeController.loggedInUserName]?.removeWhere((u) => u.id == userId || u.name.toLowerCase() == userName.toLowerCase());
      homeController.userFollowing.refresh();
    } else {
      isFollowing.value = true;
    }
  }

  void toggleFollow() {
    unfollowUser();
  }

  Future<void> followUser() async {
    isPending.value = true;
    final success = await homeController.sendFollowRequest(userId);
    if (!success) {
      isPending.value = false;
    }
  }

  Future<void> cancelFollowRequest() async {
    isPending.value = false;
    final success = await homeController.cancelFollowRequest(userId);
    if (!success) {
      isPending.value = true;
    }
  }

  void blockUser(BuildContext context) {
    _showBlockConfirmationDialog(context);
  }

  void _showBlockConfirmationDialog(BuildContext context) {
    final RxBool isDialogLoading = false.obs;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Obx(() {
          if (isDialogLoading.value) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: const SizedBox(
                height: 100,
                child: Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            );
          }
          return AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              StaticString.blockUser.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            content: Text(
              StaticString.blockConfirmation.tr,
              style: const TextStyle(
                color: AppColors.textLight,
                fontSize: 15,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  StaticString.no.tr,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  isDialogLoading.value = true;
                  final success = await homeController.blockUser(userId, userName);
                  if (context.mounted) {
                    Navigator.pop(context); // Dismiss loading dialog
                    if (success) {
                      _showUserBlockedSuccessDialog(context);
                    }
                  }
                },
                child: Text(
                  StaticString.yes.tr,
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _showUserBlockedSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            StaticString.userBlocked.tr,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          content: Text(
            StaticString.userBlockedInfo.tr,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Dismiss success dialog
                Get.back(); // Navigate back from ProfileScreen to Feed
                ToastMessage.showToast(message: StaticString.userBlockedSuccess.tr);
              },
              child: Text(
                StaticString.ok.tr,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
