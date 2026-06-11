import 'package:get/get.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../Utils/AppConst/app_const.dart';

class SplashScreenController extends GetxController {
  final _sharedPrefHelper = Get.find<SharedPreferenceHelper>();

  @override
  void onInit() {
    super.onInit();
    _startNavigationDelay();
  }

  void _startNavigationDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      final token = _sharedPrefHelper.getString(AppConst.token);
      
      // Boilerplate setup logic:
      // if (token.isNotEmpty) {
      //   Get.offAllNamed(AppRoute.homeScreen);
      // } else {
      //   Get.offAllNamed(AppRoute.loginScreen);
      // }
      
      // Since we don't have other screens in the initial structure, 
      // we print the state. Developers can wire up the actual landing page here.
      print("Splash navigation completed. Auth token present: ${token.isNotEmpty}");
    });
  }
}
