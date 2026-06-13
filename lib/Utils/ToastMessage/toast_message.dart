import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../AppColors/app_colors.dart';
import '../StaticString/static_string.dart';

class ToastMessage {
  // Simple toast message
  static void showToast({required String message, bool isError = false}) {
    String cleanMessage = message;
    bool computedIsError = isError;

    // Filter raw developer exceptions and clean them up
    if (message.contains('SocketException') || 
        message.contains('Failed host lookup') || 
        message.contains('Connection error') ||
        message.contains('ClientException') ||
        message.contains('NetworkInfo')) {
      cleanMessage = StaticString.checkConnection.tr;
      computedIsError = true;
    }

    Fluttertoast.showToast(
      msg: cleanMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: computedIsError ? AppColors.error : AppColors.success,
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
    String cleanMessage = message;
    bool computedIsError = isError;

    // Filter raw developer exceptions and clean them up
    if (message.contains('SocketException') || 
        message.contains('Failed host lookup') || 
        message.contains('Connection error') ||
        message.contains('ClientException') ||
        message.contains('NetworkInfo')) {
      cleanMessage = StaticString.checkConnection.tr;
      computedIsError = true;
    }

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
        cleanMessage,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
        ),
      ),
      backgroundColor: computedIsError ? AppColors.error : AppColors.success,
      icon: Icon(
        computedIsError ? Icons.error_outline : Icons.check_circle_outline,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }
}
