import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../HomeScreen/Controller/home_controller.dart';
import '../../HomeScreen/Model/post_model.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/StaticString/static_string.dart';

class MyProfileController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final String userName = 'Shahriar';

  var myPosts = <PostModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadMyPosts();
    // React to changes in home controller posts to refresh user posts
    ever(homeController.posts, (_) => loadMyPosts());
  }

  void loadMyPosts() {
    myPosts.assignAll(homeController.posts.where((p) => p.userName == userName).toList());
  }

  void showPermissionDialog(BuildContext context, String target) {
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
          title: Row(
            children: [
              const Icon(Icons.perm_media_rounded, color: Colors.blueAccent, size: 28),
              const SizedBox(width: 12),
              Text(
                StaticString.permissionRequest.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            StaticString.permissionContent.tr,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ToastMessage.showToast(message: StaticString.permissionDenied.tr);
              },
              child: Text(
                StaticString.deny.tr,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                final message = target == 'cover photo'
                    ? StaticString.galleryOpenedCover.tr
                    : StaticString.galleryOpenedProfile.tr;
                ToastMessage.showToast(message: message);
              },
              child: Text(
                StaticString.allow.tr,
                style: const TextStyle(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
