import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/View/Screen/HomeScreen/Controller/home_controller.dart';
import 'package:onepipo/View/Screen/HomeScreen/feed_screen.dart';
import 'package:onepipo/View/Screen/NotificationScreen/notification_screen.dart';
import 'package:onepipo/View/Screen/SearchScreen/search_screen.dart';
import 'package:onepipo/View/Widgegt/ShimmerLoading/shimmer_loading.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('FeedScreen displays PostCardShimmer when loading', (WidgetTester tester) async {
    final homeController = HomeController();
    Get.put<HomeController>(homeController);

    homeController.isLoading.value = true;

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        home: const FeedScreen(),
      ),
    );

    // Render initial frame
    await tester.pump();

    // Verify PostCardShimmer is found
    expect(find.byType(PostCardShimmer), findsAtLeastNWidgets(1));
  });

  testWidgets('NotificationScreen displays NotificationShimmer initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        home: const NotificationScreen(),
      ),
    );

    // Render initial frame (which has _isLoading = true)
    await tester.pump();

    // Verify NotificationShimmer is found
    expect(find.byType(NotificationShimmer), findsAtLeastNWidgets(1));

    // Pump 2 seconds to complete the 1500ms Future.delayed timer
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('SearchScreen displays SearchUserShimmer initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        home: const SearchScreen(),
      ),
    );

    // Render initial frame (which has _isLoading = true)
    await tester.pump();

    // Verify SearchUserShimmer is found
    expect(find.byType(SearchUserShimmer), findsAtLeastNWidgets(1));

    // Pump 2 seconds to complete the 1500ms Future.delayed timer
    await tester.pump(const Duration(seconds: 2));
  });
}
