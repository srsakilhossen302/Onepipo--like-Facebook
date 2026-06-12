import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/AppConst/app_const.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordObscured = true.obs;
  final agreeTerms = false.obs;
  final isLoading = false.obs;

  final _sharedPrefHelper = Get.find<SharedPreferenceHelper>();

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void toggleAgreeTerms(bool? value) {
    agreeTerms.value = value ?? false;
  }

  void login() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
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

    if (!agreeTerms.value) {
      ToastMessage.showToast(message: StaticString.mustAgreeTerms.tr);
      return;
    }

    isLoading.value = true;
    
    // Simulate API call
    Future.delayed(const Duration(milliseconds: 1500), () async {
      isLoading.value = false;
      
      // Save mock token
      await _sharedPrefHelper.setString(AppConst.token, "mock_user_token_12345");
      
      ToastMessage.showToast(message: StaticString.loginSuccess.tr);
      
      // Navigate to Home screen
      Get.offAllNamed(AppRoute.homeScreen);
    });
  }
}
