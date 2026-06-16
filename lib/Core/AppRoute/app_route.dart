import 'package:get/get.dart';
import '../../View/Screen/SplashScreen/splash_screen.dart';
import '../../View/Screen/SplashScreen/Controller/splash_screen_controller.dart';
import '../../View/Screen/HomeScreen/home_screen.dart';
import '../../View/Screen/HomeScreen/Controller/home_controller.dart';
import '../../View/Screen/CreatePostScreen/create_post_screen.dart';
import '../../View/Screen/HomeScreen/post_details_screen.dart';
import '../../View/Screen/ProfileScreen/profile_screen.dart';
import '../../View/Screen/ProfileScreen/my_profile_screen.dart';
import '../../View/Screen/ProfileScreen/follow_list_screen.dart';
import '../../View/Screen/CreatePostScreen/group_selection_screen.dart';
import '../../View/Screen/CreatePostScreen/tag_friends_screen.dart';
import '../../View/Screen/SettingsScreen/change_password_screen.dart';
import '../../View/Screen/SettingsScreen/blocked_users_screen.dart';
import '../../View/Screen/SettingsScreen/saved_posts_screen.dart';
import '../../View/Screen/SettingsScreen/archived_posts_screen.dart';
import '../../View/Screen/NotificationScreen/notification_screen.dart';
import '../../View/Screen/LoginScreen/login_screen.dart';
import '../../View/Screen/LoginScreen/Controller/login_controller.dart';
import '../../View/Screen/CreateAccountScreen/create_account_screen.dart';
import '../../View/Screen/CreateAccountScreen/Controller/create_account_controller.dart';
import '../../View/Screen/OtpVerificationScreen/otp_verification_screen.dart';
import '../../View/Screen/OtpVerificationScreen/Controller/otp_verification_controller.dart';

class AppRoute {
  static const String splashScreen = '/splash_screen';
  static const String loginScreen = '/login';
  static const String createAccount = '/create_account';
  static const String otpVerification = '/otp_verification';
  static const String homeScreen = '/home_screen';
  static const String createPost = '/create_post';
  static const String postDetails = '/post_details';
  static const String profile = '/profile';
  static const String myProfile = '/my_profile';
  static const String followList = '/follow_list';
  static const String groupSelection = '/group_selection';
  static const String tagFriends = '/tag_friends';
  static const String changePassword = '/change_password';
  static const String blockedUsers = '/blocked_users';
  static const String notifications = '/notifications';
  static const String savedPosts = '/saved_posts';
  static const String archivedPosts = '/archived_posts';

  static String getSplashScreen() => splashScreen;
  static String getLoginScreen() => loginScreen;
  static String getCreateAccount() => createAccount;
  static String getOtpVerification() => otpVerification;
  static String getHomeScreen() => homeScreen;
  static String getCreatePost() => createPost;
  static String getPostDetails() => postDetails;
  static String getProfile() => profile;
  static String getMyProfile() => myProfile;
  static String getFollowList() => followList;
  static String getGroupSelection() => groupSelection;
  static String getTagFriends() => tagFriends;
  static String getChangePassword() => changePassword;
  static String getBlockedUsers() => blockedUsers;
  static String getNotifications() => notifications;
  static String getSavedPosts() => savedPosts;
  static String getArchivedPosts() => archivedPosts;

  static List<GetPage> routes = [
    GetPage(
      name: splashScreen,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put<SplashScreenController>(SplashScreenController());
      }),
    ),
    GetPage(
      name: loginScreen,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(() {
        Get.put<LoginController>(LoginController());
      }),
    ),
    GetPage(
      name: createAccount,
      page: () => const CreateAccountScreen(),
      binding: BindingsBuilder(() {
        Get.put<CreateAccountController>(CreateAccountController());
      }),
    ),
    GetPage(
      name: otpVerification,
      page: () => const OtpVerificationScreen(),
      binding: BindingsBuilder(() {
        Get.put<OtpVerificationController>(OtpVerificationController());
      }),
    ),
    GetPage(
      name: homeScreen,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(() {
        Get.put<HomeController>(HomeController());
      }),
    ),
    GetPage(name: createPost, page: () => const CreatePostScreen()),
    GetPage(name: postDetails, page: () => const PostDetailsScreen()),
    GetPage(name: profile, page: () => const ProfileScreen()),
    GetPage(name: myProfile, page: () => const MyProfileScreen()),
    GetPage(name: followList, page: () => const FollowListScreen()),
    GetPage(name: groupSelection, page: () => const GroupSelectionScreen()),
    GetPage(name: tagFriends, page: () => const TagFriendsScreen()),
    GetPage(name: changePassword, page: () => const ChangePasswordScreen()),
    GetPage(name: blockedUsers, page: () => const BlockedUsersScreen()),
    GetPage(name: notifications, page: () => const NotificationScreen()),
    GetPage(name: savedPosts, page: () => const SavedPostsScreen()),
    GetPage(name: archivedPosts, page: () => const ArchivedPostsScreen()),
  ];
}
