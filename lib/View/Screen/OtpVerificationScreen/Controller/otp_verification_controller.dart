import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../Utils/AppConst/app_const.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/api_check.dart';
import '../../CreateAccountScreen/Controller/create_account_controller.dart';

class OtpVerificationController extends GetxController {
  final otpControllers = List.generate(5, (_) => TextEditingController());
  final focusNodes = List.generate(5, (_) => FocusNode());
  
  final timerSeconds = 59.obs;
  final canResend = false.obs;
  final email = 'wavate9721@synsky.com'.obs;
  final isLoading = false.obs;

  final _apiClient = Get.find<ApiClient>();

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
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
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
    
    // Reset inputs
    for (var controller in otpControllers) {
      controller.clear();
    }
    
    // Shift focus back to the first box
    if (focusNodes.isNotEmpty) {
      focusNodes[0].requestFocus();
    }
    
    isLoading.value = true;
    try {
      final deviceToken = await _getDeviceToken();
      final response = await _apiClient.post(
        ApiUrl.requestOtp,
        body: {
          'credential': email.value,
          'type': 'register',
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
    // Check if code is fully filled
    String code = '';
    for (var controller in otpControllers) {
      code += controller.text.trim();
    }

    if (code.length < 5) {
      ToastMessage.showToast(message: StaticString.pleaseFillAllFields.tr);
      return;
    }

    isLoading.value = true;

    try {
      final deviceToken = await _getDeviceToken();
      final response = await _apiClient.post(
        ApiUrl.verifyOtp,
        body: {
          'code': code,
          'credential': email.value,
          'device_token': deviceToken,
        },
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
        if (token == null && responseData['data'] is List && (responseData['data'] as List).isNotEmpty) {
          token = responseData['data'][0].toString();
        }
        token ??= "mock_register_token_xyz";

        final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
        await sharedPrefHelper.setString(AppConst.token, token);

        // Update Create Account flow to Step 2
        try {
          if (Get.isRegistered<CreateAccountController>()) {
            final createAccountController = Get.find<CreateAccountController>();
            createAccountController.otpCode.value = code;
            createAccountController.currentStep.value = 2;
          }
        } catch (_) {}

        ToastMessage.showToast(message: StaticString.otpVerified.tr);
        Get.back();
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      isLoading.value = false;
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }
}
