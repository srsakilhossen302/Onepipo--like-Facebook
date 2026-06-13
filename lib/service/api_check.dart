import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../helper/shared_prefe/shared_prefe.dart';
import '../Utils/AppConst/app_const.dart';
import '../Utils/StaticString/static_string.dart';
import '../Utils/ToastMessage/toast_message.dart';

class ApiCheck {
  static void checkApi(http.Response response) {
    if (response.statusCode == 401) {
      final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
      sharedPrefHelper.removeKey(AppConst.token);
      
      ToastMessage.showSnackBar(
        title: StaticString.unauthorized.tr,
        message: 'Please login again to continue.',
        isError: true,
      );
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
