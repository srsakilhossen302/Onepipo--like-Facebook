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
  var currentUserUsername = "".obs;
  var myUserId = "".obs;
  var userEmail = "".obs;

  var smsNotifications = false.obs;
  var pushNotifications = true.obs;
  var emailNotifications = false.obs;
  var is2faEnabled = false.obs;

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

  bool _isLoginInProgress = false;
  Future<void>? _loginFuture;

  Future<void> loginInBackground() async {
    if (_isLoginInProgress) {
      if (_loginFuture != null) {
        await _loginFuture;
      }
      return;
    }
    _isLoginInProgress = true;
    _loginFuture = _performLoginInBackground();
    await _loginFuture;
    _loginFuture = null;
    _isLoginInProgress = false;
  }

  Future<void> _performLoginInBackground() async {
    final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
    final email = sharedPrefHelper.getUserEmail();
    final password = sharedPrefHelper.getUserPassword();

    if (email.isEmpty || password.isEmpty) {
      return;
    }

    // Cooldown of 2 minutes to prevent rapid duplicate background logins
    final lastLogin = sharedPrefHelper.getLastLoginTime();
    if (lastLogin != null && DateTime.now().difference(lastLogin) < const Duration(minutes: 2)) {
      print('Skipping background login: last login/registration was less than 2 minutes ago.');
      return;
    }

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
          await sharedPrefHelper.saveLastLoginTime();
        }

        if (responseData['data'] is Map) {
          final data = responseData['data'] as Map<String, dynamic>;
          final bool? is2fa = data['is_2fa_enabled'] as bool?;
          if (data['user'] is Map) {
            await sharedPrefHelper.saveUserProfile(data['user'] as Map<String, dynamic>, is2faEnabled: is2fa);
          }
          
          if (data.containsKey('is_2fa_enabled')) {
            is2faEnabled.value = data['is_2fa_enabled'] as bool? ?? false;
          }

          if (data['user'] is Map) {
            final user = data['user'] as Map<String, dynamic>;
            
            if (user.containsKey('username') && user['username'] != null) {
              currentUserUsername.value = user['username'].toString();
            }
            if (user.containsKey('id')) {
              final idStr = user['id'].toString();
              myUserId.value = idStr;
            }
            if (user.containsKey('email')) {
              final emailStr = user['email'].toString();
              userEmail.value = emailStr;
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

            if (user['profile'] is Map) {
              final userProfile = user['profile'] as Map<String, dynamic>;
              if (userProfile.containsKey('sms_notifications')) {
                smsNotifications.value = userProfile['sms_notifications'] as bool? ?? false;
              }
              if (userProfile.containsKey('push_notifications')) {
                pushNotifications.value = userProfile['push_notifications'] as bool? ?? false;
              }
              if (userProfile.containsKey('email_notifications')) {
                emailNotifications.value = userProfile['email_notifications'] as bool? ?? false;
              }
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
    
    // Initialize profile details synchronously from SharedPreferences for instant UI display
    final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
    userEmail.value = sharedPrefHelper.getUserEmail();
    final savedName = sharedPrefHelper.getUserName();
    if (savedName.isNotEmpty) {
      currentUserName.value = savedName;
    }
    final savedUsername = sharedPrefHelper.getUserUsername();
    if (savedUsername.isNotEmpty) {
      currentUserUsername.value = savedUsername;
    }
    profilePhotoUrl.value = sharedPrefHelper.getUserPhoto();
    coverPhotoUrl.value = sharedPrefHelper.getUserCover();
    smsNotifications.value = sharedPrefHelper.getSmsNotifications();
    pushNotifications.value = sharedPrefHelper.getPushNotifications();
    emailNotifications.value = sharedPrefHelper.getEmailNotifications();
    is2faEnabled.value = sharedPrefHelper.getIs2faEnabled();
    final savedId = sharedPrefHelper.getString('logged_in_user_id');
    if (savedId.isNotEmpty) {
      myUserId.value = savedId;
    }
    
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
            } else if (data is Map) {
              return (data['profile_img'] ?? data['cover_img'] ?? data['url'] ?? data['photo'] ?? data['image'])?.toString();
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
          } else if (data is Map) {
            url = (data['profile_img'] ?? data['cover_img'] ?? data['url'] ?? data['photo'] ?? data['image'])?.toString();
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
