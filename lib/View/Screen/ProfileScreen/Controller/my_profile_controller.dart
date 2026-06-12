import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../HomeScreen/Controller/home_controller.dart';
import '../../HomeScreen/Model/post_model.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../Utils/StaticString/static_string.dart';

class MyProfileController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final String userName = 'Shahriar';

  var myPosts = <PostModel>[].obs;
  var coverPhotoPath = ''.obs;
  var profilePhotoPath = ''.obs;

  final ImagePicker _picker = ImagePicker();

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

  Future<void> openGallery(String target) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (target == 'cover photo') {
          coverPhotoPath.value = image.path;
        } else {
          profilePhotoPath.value = image.path;
        }
        final message = target == 'cover photo'
            ? StaticString.galleryOpenedCover.tr
            : StaticString.galleryOpenedProfile.tr;
        ToastMessage.showToast(message: message);
      }
    } catch (e) {
      ToastMessage.showToast(message: "Failed to open gallery: $e");
    }
  }
}
