import 'package:get/get.dart';
import '../../View/Screen/SplashScreen/splash_screen.dart';
import '../../View/Screen/SplashScreen/Controller/splash_screen_controller.dart';

class AppRoute {
  static const String splashScreen = '/splash_screen';

  static String getSplashScreen() => splashScreen;

  static List<GetPage> routes = [
    GetPage(
      name: splashScreen,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashScreenController>(() => SplashScreenController());
      }),
    ),
  ];
}
