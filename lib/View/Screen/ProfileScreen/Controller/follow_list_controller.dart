import 'package:get/get.dart';
import '../../HomeScreen/Controller/home_controller.dart';

class FollowListController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  late String userName;

  void initUser(String name) {
    userName = name;
  }

  List<FollowerModel> getFollowers() {
    return homeController.userFollowers[userName] ?? [];
  }

  List<FollowerModel> getFollowing() {
    return homeController.userFollowing[userName] ?? [];
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
