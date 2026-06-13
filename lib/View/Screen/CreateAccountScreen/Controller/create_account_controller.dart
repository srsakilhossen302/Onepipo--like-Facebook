import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/AppConst/app_const.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/api_check.dart';

import 'package:package_info_plus/package_info_plus.dart';

class CreateAccountController extends GetxController {
  final currentStep = 1.obs;
  final profilePhotoPath = ''.obs;
  final isPasswordObscured = true.obs;
  final isConfirmPasswordObscured = true.obs;
  final isLoading = false.obs;

  final otpCode = ''.obs;
  final _apiClient = Get.find<ApiClient>();

  // Step 2 Form values
  final selectedCountry = RxnString();
  final selectedGender = RxnString(); // 'male', 'female', or null

  final referralController = TextEditingController();
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final bioController = TextEditingController();

  final ImagePicker _picker = ImagePicker();

  @override
  void onClose() {
    referralController.dispose();
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    bioController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured.value = !isConfirmPasswordObscured.value;
  }

  void selectGender(String gender) {
    if (selectedGender.value == gender) {
      selectedGender.value = null; // Toggle off if selected again
    } else {
      selectedGender.value = gender;
    }
  }

  Future<void> openGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        profilePhotoPath.value = image.path;
        ToastMessage.showToast(message: StaticString.galleryOpenedProfile.tr);
      }
    } catch (e) {
      ToastMessage.showToast(message: "Failed to open gallery: $e");
    }
  }

  void handleBack() {
    if (currentStep.value == 2) {
      currentStep.value = 1;
    } else {
      Get.back();
    }
  }

  int getCountryId(String countryName) {
    switch (countryName) {
      case 'Bangladesh': return 1;
      case 'United States': return 2;
      case 'United Kingdom': return 3;
      case 'Canada': return 4;
      case 'France': return 5;
      case 'Germany': return 6;
      case 'India': return 7;
      case 'Saudi Arabia': return 8;
      default: return 1;
    }
  }

  Future<String> _getDeviceName() async {
    if (Get.testMode) return 'Android';
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.name;
      }
    } catch (_) {}
    return 'Unknown Device';
  }

  Future<String> _getAppVersion() async {
    if (Get.testMode) return '1.0.0';
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (_) {}
    return '1.0.0';
  }

  Future<String> _getDeviceToken() async {
    if (Get.testMode) return 'mock_device_token_xyz';
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'mock_device_token';
      }
    } catch (_) {}
    return 'mock_device_token_xyz';
  }

  void nextStepOrRegister() async {
    if (currentStep.value == 1) {
      final fullName = fullNameController.text.trim();
      final username = usernameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();
      final referralCode = referralController.text.trim();

      if (fullName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
        ToastMessage.showToast(message: StaticString.pleaseFillAllFields.tr);
        return;
      }

      if (!GetUtils.isEmail(email)) {
        ToastMessage.showToast(message: StaticString.invalidEmail.tr);
        return;
      }

      if (password.length < 6) {
        ToastMessage.showToast(message: StaticString.passwordTooShort.tr);
        return;
      }

      if (password != confirmPassword) {
        ToastMessage.showToast(message: StaticString.passwordsDoNotMatch.tr);
        return;
      }

      isLoading.value = true;

      try {
        // 1. Validate username
        final usernameResponse = await _apiClient.post(
          ApiUrl.validateUsername,
          body: {'username': username},
        );

        if (usernameResponse.statusCode != 200 && usernameResponse.statusCode != 201) {
          isLoading.value = false;
          ApiCheck.checkApi(usernameResponse);
          return;
        }

        // 2. Validate referral code if provided
        if (referralCode.isNotEmpty) {
          final referralResponse = await _apiClient.post(
            ApiUrl.validateReferralCode,
            body: {
              'refcode': referralCode,
              'referral_code': referralCode,
              'code': referralCode,
            },
          );

          if (referralResponse.statusCode != 200 && referralResponse.statusCode != 201) {
            isLoading.value = false;
            ApiCheck.checkApi(referralResponse);
            return;
          }
        }

        // 3. Request OTP (2nd image API)
        final deviceToken = await _getDeviceToken();
        final requestOtpResponse = await _apiClient.post(
          ApiUrl.requestOtp,
          body: {
            'credential': email,
            'type': 'register',
            'device_token': deviceToken,
          },
        );

        isLoading.value = false;

        if (requestOtpResponse.statusCode == 200 || requestOtpResponse.statusCode == 201) {
          Get.toNamed(AppRoute.otpVerification, arguments: email);
        } else {
          ApiCheck.checkApi(requestOtpResponse);
        }
      } catch (e) {
        isLoading.value = false;
        ToastMessage.showToast(message: 'Connection error: $e');
      }
    } else if (currentStep.value == 2) {
      final country = selectedCountry.value;

      if (country == null || country.isEmpty) {
        ToastMessage.showToast(message: StaticString.pleaseSelectCountry.tr);
        return;
      }

      isLoading.value = true;

      try {
        final deviceToken = await _getDeviceToken();
        final genderChar = selectedGender.value == 'male'
            ? 'm'
            : (selectedGender.value == 'female' ? 'f' : null);

        final body = {
          'name': fullNameController.text.trim(),
          'username': usernameController.text.trim(),
          'email': emailController.text.trim(),
          'gender': genderChar,
          'bio': bioController.text.trim().isEmpty ? null : bioController.text.trim(),
          'password': passwordController.text.trim(),
          'device_token': deviceToken,
          'country_id': getCountryId(country),
          'code': otpCode.value,
          'referral_code': referralController.text.trim().isEmpty ? null : referralController.text.trim(),
          'password_confirmation': confirmPasswordController.text.trim(),
        };

        // 4. Submit registration (1st image API)
        final response = await _apiClient.post(
          ApiUrl.register,
          body: body,
        );

        isLoading.value = false;

        if (response.statusCode == 200 || response.statusCode == 201) {
          final Map<String, dynamic> responseData = jsonDecode(response.body);
          String? token;

          if (responseData['data'] is Map) {
            final data = responseData['data'] as Map<String, dynamic>;
            if (data.containsKey('token')) {
              token = data['token']?.toString();
            }
          }
          if (token == null && responseData.containsKey('token')) {
            token = responseData['token']?.toString();
          }
          token ??= "mock_register_token_xyz";

          final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
          await sharedPrefHelper.setString(AppConst.token, token);

          ToastMessage.showToast(message: StaticString.registrationSuccess.tr);
          Get.offAllNamed(AppRoute.homeScreen);
        } else {
          ApiCheck.checkApi(response);
        }
      } catch (e) {
        isLoading.value = false;
        ToastMessage.showToast(message: 'Connection error: $e');
      }
    }
  }
}
