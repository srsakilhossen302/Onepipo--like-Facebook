import 'package:get/get.dart';
import '../../View/Screen/SplashScreen/splash_screen.dart';
import '../../View/Screen/SplashScreen/Controller/splash_screen_controller.dart';
import '../../View/Screen/HomeScreen/home_screen.dart';
import '../../View/Screen/HomeScreen/Controller/home_controller.dart';

class AppRoute {
  static const String splashScreen = '/splash_screen';
  static const String homeScreen = '/home_screen';

  static String getSplashScreen() => splashScreen;
  static String getHomeScreen() => homeScreen;

  static List<GetPage> routes = [
    GetPage(
      name: splashScreen,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<SplashScreenController>(() => SplashScreenController());
      }),
    ),
    GetPage(
      name: homeScreen,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(() => HomeController());
      }),
    ),
  ];
}
