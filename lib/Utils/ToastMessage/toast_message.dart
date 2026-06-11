import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../AppColors/app_colors.dart';

class ToastMessage {
  // Simple toast message
  static void showToast({required String message, bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  // GetX Snack bar for a more interactive and visually rich error/success banner
  static void showSnackBar({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      messageText: Text(
        message,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
      backgroundColor: isError ? AppColors.error : AppColors.success,
      icon: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }
}
