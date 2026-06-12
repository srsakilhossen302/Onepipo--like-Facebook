import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';

import '../../CreateAccountScreen/Controller/create_account_controller.dart';

class OtpVerificationController extends GetxController {
  final otpControllers = List.generate(5, (_) => TextEditingController());
  final focusNodes = List.generate(5, (_) => FocusNode());
  
  final timerSeconds = 59.obs;
  final canResend = false.obs;
  final email = 'wavate9721@synsky.com'.obs;
  final isLoading = false.obs;

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

  void resendCode() {
    if (!canResend.value) return;
    
    // Reset inputs
    for (var controller in otpControllers) {
      controller.clear();
    }
    
    // Shift focus back to the first box
    if (focusNodes.isNotEmpty) {
      focusNodes[0].requestFocus();
    }
    
    startTimer();
    ToastMessage.showToast(message: StaticString.otpResent.tr);
  }

  void verifyOtp() {
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

    // Simulate OTP Verification
    Future.delayed(const Duration(milliseconds: 1500), () async {
      isLoading.value = false;
      
      // Update Create Account flow to Step 2
      try {
        if (Get.isRegistered<CreateAccountController>()) {
          final createAccountController = Get.find<CreateAccountController>();
          createAccountController.currentStep.value = 2;
        }
      } catch (_) {}

      ToastMessage.showToast(message: StaticString.otpVerified.tr);
      
      // Pop back to CreateAccount screen showing Step 2
      Get.back();
    });
  }
}
