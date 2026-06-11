import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import '../helper/shared_prefe/shared_prefe.dart';
import '../Utils/AppConst/app_const.dart';
import '../Utils/ToastMessage/toast_message.dart';

class ApiCheck {
  static void checkApi(dio.Response response) {
    if (response.statusCode == 401) {
      final sharedPrefHelper = Get.find<SharedPreferenceHelper>();
      sharedPrefHelper.removeKey(AppConst.token);
      
      ToastMessage.showSnackBar(
        title: 'unauthorized'.tr,
        message: 'Please login again to continue.',
        isError: true,
      );
      
      // Navigate to splash or login
      // Get.offAllNamed(AppRoute.splashScreen);
    } else if (response.statusCode != 200 && response.statusCode != 201) {
      ToastMessage.showSnackBar(
        title: 'error'.tr,
        message: response.statusMessage ?? 'Something went wrong.',
        isError: true,
      );
    }
  }
}
