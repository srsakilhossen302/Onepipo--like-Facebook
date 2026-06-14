import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../HomeScreen/Controller/home_controller.dart';
import '../../HomeScreen/Model/post_model.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/api_check.dart';
import '../../CreateAccountScreen/Controller/create_account_controller.dart';

class MyProfileController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  final String userName = 'Shahriar';

  var myPosts = <PostModel>[].obs;
  var coverPhotoPath = ''.obs;
  var profilePhotoPath = ''.obs;

  final countriesList = <CountryModel>[].obs;
  final isLoadingCountries = false.obs;
  final isLoadingUpdate = false.obs;
  final isLoadingUploadPhoto = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    loadMyPosts();
    fetchCountries();
    // React to changes in home controller posts to refresh user posts
    ever(homeController.posts, (_) => loadMyPosts());
  }

  void loadMyPosts() {
    myPosts.assignAll(homeController.posts.where((p) => p.userName == userName).toList());
  }

  Future<void> fetchCountries() async {
    isLoadingCountries.value = true;
    try {
      final response = await Get.find<ApiClient>().get(ApiUrl.countries);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final List<CountryModel> fetchedCountries = data.map((json) => CountryModel.fromJson(json)).toList();
          countriesList.assignAll(fetchedCountries);
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      print('Error loading countries: $e');
    } finally {
      isLoadingCountries.value = false;
    }
  }

  Future<bool> updateProfileData({
    required String names,
    required String username,
    required String bio,
    required String countryId,
    required String cityId,
  }) async {
    isLoadingUpdate.value = true;
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.updateProfile,
        body: {
          'names': names,
          'username': username,
          'bio': bio.isEmpty ? null : bio,
          'gender': 'M',
          'country_id': countryId,
          'city_id': cityId,
        },
      );

      isLoadingUpdate.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessage.showToast(message: 'Profile updated successfully');
        return true;
      } else {
        ApiCheck.checkApi(response);
        return false;
      }
    } catch (e) {
      isLoadingUpdate.value = false;
      ToastMessage.showToast(message: 'Connection error: $e');
      return false;
    }
  }

  Future<void> openGallery(String target) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 1024,
        maxHeight: 1024,
      );
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

        // Upload photo immediately
        await uploadPhoto(image.path);
      }
    } catch (e) {
      ToastMessage.showToast(message: "Failed to open gallery: $e");
    }
  }

  Future<String?> uploadPhoto(String imagePath) async {
    isLoadingUploadPhoto.value = true;
    try {
      final file = File(imagePath);
      if (Get.testMode) {
        isLoadingUploadPhoto.value = false;
        final response = await Get.find<ApiClient>().post(
          ApiUrl.uploadPhoto,
          body: {
            'image': 'mock_base64_data',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          if (responseData.containsKey('data')) {
            final data = responseData['data'];
            if (data is List && data.isNotEmpty) {
              return data[0].toString();
            } else if (data is String) {
              return data;
            }
          }
          return 'https://onepipo.com/uploads/mock_photo.png';
        }
        return null;
      }

      if (!await file.exists()) {
        isLoadingUploadPhoto.value = false;
        ToastMessage.showToast(message: 'File does not exist');
        return null;
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await Get.find<ApiClient>().post(
        ApiUrl.uploadPhoto,
        body: {
          'image': base64Image,
        },
      );

      isLoadingUploadPhoto.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String? url;
        if (responseData.containsKey('data')) {
          final data = responseData['data'];
          if (data is List && data.isNotEmpty) {
            url = data[0].toString();
          } else if (data is String) {
            url = data;
          }
        }
        ToastMessage.showToast(message: 'Photo uploaded successfully');
        return url;
      } else {
        ApiCheck.checkApi(response);
        return null;
      }
    } catch (e) {
      isLoadingUploadPhoto.value = false;
      ToastMessage.showToast(message: 'Failed to upload photo: $e');
      return null;
    }
  }
}
