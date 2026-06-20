import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/api_check.dart';
import '../../../../Core/AppRoute/app_route.dart';

class TwoFactorVerificationController extends GetxController {
  final otpController = PinInputController();
  
  final timerSeconds = 59.obs;
  final canResend = false.obs;
  final email = ''.obs;
  final isLoading = false.obs;

  final _apiClient = Get.find<ApiClient>();
  final _sharedPrefHelper = Get.find<SharedPreferenceHelper>();

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is String) {
      email.value = Get.arguments as String;
    }
    startTimer();
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
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

  void resendCode() async {
    if (!canResend.value) return;
    
    otpController.clear();
    isLoading.value = true;
    
    try {
      final deviceToken = await _getDeviceToken();
      final response = await _apiClient.post(
        ApiUrl.request2fa,
        body: {
          'credential': email.value,
          'type': 'email',
          'device_token': deviceToken,
        },
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        startTimer();
        ToastMessage.showToast(message: StaticString.otpResent.tr);
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      isLoading.value = false;
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  void verifyOtp() async {
    final code = otpController.text.trim();

    if (code.length < 5) {
      ToastMessage.showToast(message: StaticString.pleaseFillAllFields.tr);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    try {
      final response = await _apiClient.post(
        ApiUrl.verify2fa,
        body: {
          'code': code,
        },
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Mark 2FA as verified/enabled in local preferences
        await _sharedPrefHelper.setBool('is_2fa_enabled', true);
        
        ToastMessage.showToast(message: StaticString.loginSuccess.tr);
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
