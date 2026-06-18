import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../helper/shared_prefe/shared_prefe.dart';
import '../Utils/AppConst/app_const.dart';
import '../Utils/StaticString/static_string.dart';
import '../Utils/ToastMessage/toast_message.dart';

import '../Core/AppRoute/app_route.dart';

class ApiCheck {
  static void checkApi(http.Response response) {
    if (response.statusCode == 401) {
      final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
      final currentToken = sharedPrefHelper.getString(AppConst.token);
      
      // Extract the token that was sent in the request headers
      final authHeader = response.request?.headers['Authorization'] ?? response.request?.headers['authorization'] ?? '';
      String sentToken = '';
      if (authHeader.startsWith('Bearer ')) {
        sentToken = authHeader.substring(7).trim();
      }
      
      // If the token has changed in the meantime (e.g., via background login), do not log out
      if (currentToken.isNotEmpty && sentToken.isNotEmpty && currentToken != sentToken) {
        print("Prevented logout: Request was sent with an old token, but a new token is now active.");
        return;
      }

      sharedPrefHelper.removeKey(AppConst.token);
      
      ToastMessage.showSnackBar(
        title: StaticString.unauthorized.tr,
        message: 'Please login again to continue.',
        isError: true,
      );
      
      // Dismiss keyboard to prevent layout transition crash
      FocusManager.instance.primaryFocus?.unfocus();
      
      Get.offAllNamed(AppRoute.loginScreen);
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      String errorMessage = 'Something went wrong.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          errorMessage = decoded['message'].toString();
        } else if (decoded is Map && decoded.containsKey('error')) {
          errorMessage = decoded['error'].toString();
        }
      } catch (_) {}

      ToastMessage.showSnackBar(
        title: StaticString.error.tr,
        message: 'Error ${response.statusCode}: $errorMessage',
        isError: true,
      );
    }
  }
}
