import 'dart:convert';
import 'package:get/get.dart';
import '../../HomeScreen/Controller/home_controller.dart';
import 'my_profile_controller.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';

class FollowListController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final ApiClient apiClient = Get.find<ApiClient>();
  late String userName;

  var followers = <FollowerModel>[].obs;
  var isLoadingFollowers = false.obs;
  var following = <FollowerModel>[].obs;
  var isLoadingFollowing = false.obs;

  void initUser(String name) {
    userName = name;
    fetchFollowers();
    fetchFollowing();
  }

  Future<void> fetchFollowers() async {
    isLoadingFollowers.value = true;
    try {
      final response = await apiClient.get(ApiUrl.followers);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic responseData = jsonDecode(response.body);
        List<dynamic> dataList = [];
        if (responseData is Map && responseData.containsKey('data') && responseData['data'] is List) {
          dataList = responseData['data'];
        } else if (responseData is List) {
          dataList = responseData;
        }

        final List<FollowerModel> loaded = dataList.map((json) {
          final id = (json['id'] ?? '').toString();
          final name = json['name'] ?? json['username'] ?? json['user_name'] ?? 'Anonymous';
          final photo = json['photo'] ?? json['photo_url'] ?? json['avatar'] ?? json['avatar_url'] ?? json['image'] ?? '';
          return FollowerModel(
            id: id,
            name: name,
            avatarUrl: photo,
            rawJson: json is Map<String, dynamic> ? json : null,
          );
        }).toList();

        followers.assignAll(loaded);
      }
    } catch (e) {
      print('Error fetching followers: $e');
    } finally {
      isLoadingFollowers.value = false;
    }
  }

  Future<void> fetchFollowing() async {
    isLoadingFollowing.value = true;
    try {
      final response = await apiClient.get(ApiUrl.following);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic responseData = jsonDecode(response.body);
        List<dynamic> dataList = [];
        if (responseData is Map && responseData.containsKey('data') && responseData['data'] is List) {
          dataList = responseData['data'];
        } else if (responseData is List) {
          dataList = responseData;
        }

        final List<FollowerModel> loaded = dataList.map((json) {
          final id = (json['id'] ?? '').toString();
          final name = json['name'] ?? json['username'] ?? json['user_name'] ?? 'Anonymous';
          final photo = json['photo'] ?? json['photo_url'] ?? json['avatar'] ?? json['avatar_url'] ?? json['image'] ?? '';
          return FollowerModel(
            id: id,
            name: name,
            avatarUrl: photo,
            rawJson: json is Map<String, dynamic> ? json : null,
          );
        }).toList();

        following.assignAll(loaded);
      }
    } catch (e) {
      print('Error fetching following: $e');
    } finally {
      isLoadingFollowing.value = false;
    }
  }

  List<FollowerModel> getFollowers() {
    return followers;
  }

  List<FollowerModel> getFollowing() {
    return following;
  }

  Future<void> unfollowUser(FollowerModel user) async {
    final success = await homeController.unfollowUser(user.id);
    if (success) {
      following.removeWhere((u) => u.id == user.id);
      try {
        Get.find<MyProfileController>().decreaseFollowingCount();
      } catch (_) {}
      homeController.userFollowing[homeController.loggedInUserName]?.removeWhere((u) => u.id == user.id || u.name.toLowerCase() == user.name.toLowerCase());
      homeController.userFollowing.refresh();
    }
  }

  Future<void> followUser(FollowerModel user) async {
    final success = await homeController.sendFollowRequest(user.id);
    if (success) {
      if (homeController.userFollowing[homeController.loggedInUserName] == null) {
        homeController.userFollowing[homeController.loggedInUserName] = <FollowerModel>[].obs;
      }
      if (!homeController.userFollowing[homeController.loggedInUserName]!.any((u) => u.id == user.id)) {
        homeController.userFollowing[homeController.loggedInUserName]!.add(user);
      }
      homeController.userFollowing.refresh();
    }
  }

  void removeFollower(String followerName) {
    homeController.removeFollower(followerName);
  }

  bool isFollowing(String name) {
    return (homeController.userFollowing[homeController.loggedInUserName] ?? [])
        .any((u) => u.name.toLowerCase() == name.toLowerCase());
  }
}
