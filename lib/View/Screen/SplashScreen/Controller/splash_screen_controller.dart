import 'package:get/get.dart';
import '../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../Utils/AppConst/app_const.dart';
import '../../../../Core/AppRoute/app_route.dart';

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
      
      // Navigate to the newly implemented Feed Home Page
      Get.offAllNamed(AppRoute.homeScreen);
      
      print("Splash navigation completed. Auth token present: ${token.isNotEmpty}");
    });
  }
}
