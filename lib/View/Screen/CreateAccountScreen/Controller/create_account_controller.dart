import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/AppConst/app_const.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';

class CreateAccountController extends GetxController {
  final currentStep = 1.obs;
  final profilePhotoPath = ''.obs;
  final isPasswordObscured = true.obs;
  final isConfirmPasswordObscured = true.obs;
  final isLoading = false.obs;

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

  void nextStepOrRegister() {
    if (currentStep.value == 1) {
      final fullName = fullNameController.text.trim();
      final username = usernameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final confirmPassword = confirmPasswordController.text.trim();

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

      // Navigate to OTP verification screen on Step 1 submit
      Future.delayed(const Duration(milliseconds: 1500), () async {
        isLoading.value = false;
        Get.toNamed(AppRoute.otpVerification, arguments: emailController.text.trim());
      });
    } else if (currentStep.value == 2) {
      final country = selectedCountry.value;

      if (country == null || country.isEmpty) {
        ToastMessage.showToast(message: StaticString.pleaseSelectCountry.tr);
        return;
      }

      isLoading.value = true;

      // Final registration submission
      Future.delayed(const Duration(milliseconds: 1500), () async {
        try {
          if (Get.isRegistered<SharedPreferenceHelper>()) {
            final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
            await sharedPrefHelper.setString(AppConst.token, "mock_register_token_xyz");
          }
        } catch (_) {}

        isLoading.value = false;
        ToastMessage.showToast(message: StaticString.registrationSuccess.tr);

        // Navigate to Home Feed
        Get.offAllNamed(AppRoute.homeScreen);
      });
    }
  }
}
