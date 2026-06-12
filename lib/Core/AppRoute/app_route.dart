import 'package:get/get.dart';
import '../../View/Screen/SplashScreen/splash_screen.dart';
import '../../View/Screen/SplashScreen/Controller/splash_screen_controller.dart';
import '../../View/Screen/HomeScreen/home_screen.dart';
import '../../View/Screen/HomeScreen/Controller/home_controller.dart';
import '../../View/Screen/CreatePostScreen/create_post_screen.dart';
import '../../View/Screen/HomeScreen/post_details_screen.dart';
import '../../View/Screen/ProfileScreen/profile_screen.dart';

class AppRoute {
  static const String splashScreen = '/splash_screen';
  static const String homeScreen = '/home_screen';
  static const String createPost = '/create_post';
  static const String postDetails = '/post_details';
  static const String profile = '/profile';

  static String getSplashScreen() => splashScreen;
  static String getHomeScreen() => homeScreen;
  static String getCreatePost() => createPost;
  static String getPostDetails() => postDetails;
  static String getProfile() => profile;

  static List<GetPage> routes = [
    GetPage(
      name: splashScreen,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put<SplashScreenController>(SplashScreenController());
      }),
    ),
    GetPage(
      name: homeScreen,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.put<HomeController>(HomeController());
      }),
    ),
    GetPage(
      name: createPost,
      page: () => const CreatePostScreen(),
    ),
    GetPage(
      name: postDetails,
      page: () => const PostDetailsScreen(),
    ),
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
    ),
  ];
}
