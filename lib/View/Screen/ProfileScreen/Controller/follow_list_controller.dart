import 'dart:convert';
import 'package:get/get.dart';
import '../../HomeScreen/Controller/home_controller.dart';
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

  void unfollowUser(String targetName) {
    homeController.toggleFollowUser(targetName);
  }

  void removeFollower(String followerName) {
    homeController.removeFollower(followerName);
  }

  bool isFollowing(String name) {
    return (homeController.userFollowing['Shahriar'] ?? [])
        .any((u) => u.name.toLowerCase() == name.toLowerCase());
  }
}
