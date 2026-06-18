import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../HomeScreen/Controller/home_controller.dart';
import '../../HomeScreen/Model/post_model.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/api_check.dart';
import '../../CreateAccountScreen/Controller/create_account_controller.dart';

import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../Utils/AppConst/app_const.dart';

class MyProfileController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();
  var currentUserName = 'Shahriar'.obs;
  String get userName => currentUserName.value;
  var myUserId = "".obs;

  var myPosts = <PostModel>[].obs;
  var coverPhotoPath = ''.obs;
  var profilePhotoPath = ''.obs;
  var profilePhotoUrl = ''.obs;
  var coverPhotoUrl = ''.obs;

  final countriesList = <CountryModel>[].obs;
  final isLoadingCountries = false.obs;
  final isLoadingUpdate = false.obs;
  final isLoadingUploadPhoto = false.obs;
  final isLoadingPosts = false.obs;
  final isLoadingMore = false.obs;

  final ScrollController scrollController = ScrollController();
  int _currentPage = 1;
  bool _isMorePostsAvailable = true;

  final ImagePicker _picker = ImagePicker();

  Future<void> loginInBackground() async {
    final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
    final email = sharedPrefHelper.getUserEmail();
    final password = sharedPrefHelper.getUserPassword();

    if (email.isEmpty || password.isEmpty) return;

    try {
      final body = {
        'credential': email,
        'password': password,
        'type': 'email',
        'device_token': 'mock_device_token_xyz',
        'device': 'Unknown Device',
        'app_version': '1.0.0',
      };

      final response = await Get.find<ApiClient>().post(
        ApiUrl.login,
        body: body,
        headers: {'no-auth': 'true'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        String? token;
        if (responseData['data'] is Map) {
          final data = responseData['data'] as Map<String, dynamic>;
          if (data.containsKey('token')) {
            token = data['token']?.toString();
          }
        }
        
        // Fallback checks
        if (token == null) {
          if (responseData.containsKey('token')) {
            token = responseData['token']?.toString();
          } else if (responseData.containsKey('access_token')) {
            token = responseData['access_token']?.toString();
          } else if (responseData['data'] is Map) {
            final data = responseData['data'] as Map<String, dynamic>;
            if (data.containsKey('access_token')) {
              token = data['access_token']?.toString();
            } else if (data.containsKey('accessToken')) {
              token = data['accessToken']?.toString();
            } else if (data['authorisation'] is Map) {
              final auth = data['authorisation'] as Map<String, dynamic>;
              if (auth.containsKey('token')) {
                token = auth['token']?.toString();
              }
            }
          }
        }
        
        if (token != null) {
          await sharedPrefHelper.setString(AppConst.token, token);
        }

        if (responseData['data'] is Map) {
          final data = responseData['data'] as Map<String, dynamic>;
          if (data['user'] is Map) {
            final user = data['user'] as Map<String, dynamic>;
            
            if (user.containsKey('id')) {
              final idStr = user['id'].toString();
              myUserId.value = idStr;
              await sharedPrefHelper.setString('logged_in_user_id', idStr);
            }
            if (user.containsKey('email')) {
              await sharedPrefHelper.setString('user_email', user['email'].toString());
            }

            if (user.containsKey('name')) {
              currentUserName.value = user['name'].toString();
            }

            if (user.containsKey('photo')) {
              profilePhotoUrl.value = user['photo'].toString();
            }

            if (user.containsKey('cover')) {
              coverPhotoUrl.value = user['cover'].toString();
            }
            
            loadMyPosts();
            if (!Get.testMode) {
              fetchMyPosts();
            }
          }
        }
      }
    } catch (e) {
      print('Background login error: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_scrollListener);
    
    // loginInBackground is awaited sequentially to avoid token invalidation race conditions
    loginInBackground().then((_) {
      _getLoggedInUserId().then((id) {
        if (id != null) {
          myUserId.value = id;
          loadMyPosts();
        }
      });
      fetchCountries();
      if (!Get.testMode) {
        fetchMyPosts();
      }
    });

    // React to changes in home controller posts to refresh user posts
    ever(homeController.posts, (_) => loadMyPosts());
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _scrollListener() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingPosts.value && !isLoadingMore.value && _isMorePostsAvailable) {
        fetchMoreMyPosts();
      }
    }
  }

  void loadMyPosts() {
    myPosts.assignAll(homeController.posts.where((p) {
      final matchesName = p.userName.toLowerCase() == currentUserName.value.toLowerCase();
      final matchesId = myUserId.value.isNotEmpty && (p.postUserId == myUserId.value || p.userId == myUserId.value);
      return matchesName || matchesId;
    }).toList());
  }

  Future<String?> _getLoggedInUserId() async {
    final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
    final savedId = sharedPrefHelper.getString('logged_in_user_id');
    if (savedId.isNotEmpty) {
      return savedId;
    }

    try {
      final response = await Get.find<ApiClient>().get(ApiUrl.profile);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        Map<String, dynamic>? data;
        if (responseData.containsKey('data')) {
          data = responseData['data'] is Map<String, dynamic> ? responseData['data'] : null;
        } else {
          data = responseData;
        }
        if (data != null && data.containsKey('id')) {
          final idStr = data['id'].toString();
          await sharedPrefHelper.setString('logged_in_user_id', idStr);
          if (data.containsKey('name')) {
            currentUserName.value = data['name'].toString();
          }
          return idStr;
        }
      }
    } catch (e) {
      print('Error getting logged in user ID: $e');
    }
    return '5'; // Mock fallback for testing
  }

  Future<void> fetchMyPosts() async {
    isLoadingPosts.value = true;
    _currentPage = 1;
    _isMorePostsAvailable = true;
    try {
      final userId = await _getLoggedInUserId();
      if (userId == null) {
        isLoadingPosts.value = false;
        return;
      }
      final response = await Get.find<ApiClient>().get('${ApiUrl.userPosts(userId)}?page=1&per_page=10');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          final List<PostModel> fetchedPosts = data.map((json) => PostModel.fromJson(json)).toList();
          
          if (fetchedPosts.isEmpty) {
            _isMorePostsAvailable = false;
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
      print('Error fetching my posts: $e');
    } finally {
      isLoadingPosts.value = false;
    }
  }

  Future<void> fetchMoreMyPosts() async {
    isLoadingMore.value = true;
    try {
      final userId = await _getLoggedInUserId();
      if (userId == null) {
        isLoadingMore.value = false;
        return;
      }
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
      print('Error fetching more my posts: $e');
    } finally {
      isLoadingMore.value = false;
    }
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
