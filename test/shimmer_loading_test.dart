import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/View/Screen/HomeScreen/Controller/home_controller.dart';
import 'package:onepipo/View/Screen/HomeScreen/feed_screen.dart';
import 'package:onepipo/View/Screen/NotificationScreen/notification_screen.dart';
import 'package:onepipo/View/Screen/SearchScreen/search_screen.dart';
import 'package:onepipo/View/Widgegt/ShimmerLoading/shimmer_loading.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepipo/helper/shared_prefe/shared_prefe.dart';
import 'package:onepipo/service/api_client.dart';
import 'package:http/http.dart' as http;

class MockApiClient extends ApiClient {
  @override
  Future<http.Response> get(
    String uri, {
    Map<String, String>? headers,
  }) async {
    if (uri.startsWith('/users/search')) {
      await Future.delayed(const Duration(milliseconds: 100));
      return http.Response(
        '{"status":"success","data":[{"id":"1","name":"Owolabi Ridwan","username":"owolabi","photo":"https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150"}]}',
        200,
      );
    } else if (uri.startsWith('/notifications')) {
      await Future.delayed(const Duration(milliseconds: 100));
      return http.Response(
        '{"status":"success","data":[]}',
        200,
      );
    }
    return http.Response('{"error":"not found"}', 404);
  }
}

void main() {
  setUp(() async {
    Get.reset();
    Get.testMode = true;

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
    Get.put<SharedPreferenceHelper>(SharedPreferenceHelper(sharedPreferences: Get.find()), permanent: true);

    Get.lazyPut<ApiClient>(() => MockApiClient(), fenix: true);
    Get.put<HomeController>(HomeController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('FeedScreen displays PostCardShimmer when loading', (WidgetTester tester) async {
    final homeController = Get.find<HomeController>();

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
