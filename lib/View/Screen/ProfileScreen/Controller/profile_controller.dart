import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../HomeScreen/Controller/home_controller.dart';
import '../../HomeScreen/Model/post_model.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';

class ProfileController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  
  late String userName;
  var userPosts = <PostModel>[].obs;
  var isFollowing = false.obs;

  void initUser(String name) {
    userName = name;
    updateFollowStatus();
    loadUserPosts();
    
    // Listen to changes in home controller posts to refresh user posts
    ever(homeController.posts, (_) => loadUserPosts());
  }

  void updateFollowStatus() {
    isFollowing.value = (homeController.userFollowing['Shahriar'] ?? [])
        .any((u) => u.name.toLowerCase() == userName.toLowerCase());
  }

  void loadUserPosts() {
    userPosts.assignAll(homeController.posts.where((p) => p.userName.toLowerCase() == userName.toLowerCase()).toList());
  }

  void toggleFollow() {
    homeController.toggleFollowUser(userName);
    updateFollowStatus();
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
                  await Future.delayed(const Duration(milliseconds: 1500));
                  if (context.mounted) {
                    Navigator.pop(context); // Dismiss loading dialog
                    _showUserBlockedSuccessDialog(context);
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
