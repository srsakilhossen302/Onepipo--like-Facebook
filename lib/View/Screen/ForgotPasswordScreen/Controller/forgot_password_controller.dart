import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/api_check.dart';

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final otpController = PinInputController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final currentStep = 1.obs; // 1: Email, 2: OTP, 3: New Password
  final isLoading = false.obs;
  final isPasswordObscured = true.obs;
  final isConfirmPasswordObscured = true.obs;

  final timerSeconds = 59.obs;
  final canResend = false.obs;
  Timer? _timer;

  final _apiClient = Get.find<ApiClient>();

  @override
  void onInit() {
    super.onInit();
    emailController.clear();
    otpController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordObscured.value = !isPasswordObscured.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordObscured.value = !isConfirmPasswordObscured.value;
  }

  void startTimer() {
    _timer?.cancel();
    timerSeconds.value = 59;
    canResend.value = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
      } else {
        canResend.value = true;
        _timer?.cancel();
      }
    });
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

  // Step 1: Send Forgot Password OTP
  void sendOtp() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ToastMessage.showToast(message: StaticString.pleaseFillAllFields.tr);
      return;
    }
    if (!GetUtils.isEmail(email)) {
      ToastMessage.showToast(message: StaticString.invalidEmail.tr);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      final deviceToken = await _getDeviceToken();
      final response = await _apiClient.post(
        ApiUrl.requestPasswordReset,
        body: {
          'credential': email,
          'type': 'email',
          'device_token': deviceToken,
        },
        headers: {'no-auth': 'true'},
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentStep.value = 2;
        startTimer();
        ToastMessage.showToast(message: "OTP sent to your email".tr);
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      isLoading.value = false;
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  // Step 2: Resend OTP
  void resendOtp() async {
    if (!canResend.value) return;

    otpController.clear();
    isLoading.value = true;

    try {
      final deviceToken = await _getDeviceToken();
      final response = await _apiClient.post(
        ApiUrl.requestPasswordReset,
        body: {
          'credential': emailController.text.trim(),
          'type': 'email',
          'device_token': deviceToken,
        },
        headers: {'no-auth': 'true'},
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        startTimer();
        ToastMessage.showToast(message: "OTP resent successfully".tr);
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      isLoading.value = false;
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  // Step 3: Verify OTP Code
  void verifyOtp() async {
    final code = otpController.text.trim();
    if (code.length < 5) {
      ToastMessage.showToast(message: "Please enter a valid OTP code".tr);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      final deviceToken = await _getDeviceToken();
      final response = await _apiClient.post(
        ApiUrl.verifyPasswordReset,
        body: {
          'code': code,
          'credential': emailController.text.trim(),
          'device_token': deviceToken,
        },
        headers: {'no-auth': 'true'},
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        currentStep.value = 3;
        ToastMessage.showToast(message: "OTP verified successfully".tr);
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      isLoading.value = false;
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  // Step 4: Reset & Update Password
  void resetPassword() async {
    final password = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final code = otpController.text.trim();

    if (password.isEmpty || confirmPassword.isEmpty) {
      ToastMessage.showToast(message: StaticString.pleaseFillAllFields.tr);
      return;
    }
    if (password.length < 6) {
      ToastMessage.showToast(message: StaticString.passwordTooShort.tr);
      return;
    }
    if (password != confirmPassword) {
      ToastMessage.showToast(message: "Passwords do not match".tr);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      final response = await _apiClient.post(
        ApiUrl.passwordUpdate,
        body: {
          'code': code,
          'password': password,
          'password_confirmation': confirmPassword,
        },
        headers: {'no-auth': 'true'},
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastMessage.showToast(message: "Password reset successfully. Please login with your new password.".tr);
        Get.offAllNamed(AppRoute.loginScreen);
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      isLoading.value = false;
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  void handleBack() {
    if (currentStep.value > 1) {
      currentStep.value--;
      if (currentStep.value == 1) {
        _timer?.cancel();
      }
    } else {
      Get.back();
    }
  }
}
