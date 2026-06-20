import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/View/Screen/SettingsScreen/settings_screen.dart';
import 'package:onepipo/Core/AppRoute/app_route.dart';
import 'package:onepipo/helper/shared_prefe/shared_prefe.dart';
import 'package:http/http.dart' as http;
import 'package:onepipo/service/api_client.dart';
import 'package:onepipo/View/Screen/HomeScreen/Controller/home_controller.dart';

void main() {
  setUp(() async {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
    Get.put<SharedPreferenceHelper>(SharedPreferenceHelper(sharedPreferences: sharedPreferences), permanent: true);
    Get.lazyPut<ApiClient>(() => MockApiClient(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('SettingsScreen navigation and ChangePasswordScreen validation tests', (WidgetTester tester) async {
    // Mock the fluttertoast channel to capture the toast messages.
    final List<MethodCall> methodCalls = [];
    const channel = MethodChannel('PonnamKarthik/fluttertoast');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      return true;
    });

    // Render SettingsScreen inside a GetMaterialApp
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        getPages: AppRoute.routes,
        home: const SettingsScreen(),
      ),
    );

    await tester.pump();

    // Verify settings screen has "Password" tile
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Change your password'), findsOneWidget);

    // Tap on the Password tile to trigger navigation
    await tester.tap(find.text('Password'));
    await tester.pumpAndSettle();

    // Verify we navigated to ChangePasswordScreen (ChangePassword title and Reset password header should be visible)
    expect(find.text('Reset password'), findsOneWidget);

    // Verify prefix |** is shown 3 times
    expect(find.text('|**'), findsNWidgets(3));

    // Find the three TextFields using indices
    final textFieldsFinder = find.byType(TextField);
    expect(textFieldsFinder, findsNWidgets(3));

    final currentPasswordFieldFinder = textFieldsFinder.at(0);
    final newPasswordFieldFinder = textFieldsFinder.at(1);
    final confirmPasswordFieldFinder = textFieldsFinder.at(2);

    // Initially, obscureText must be true for all
    final TextField currentField = tester.widget(currentPasswordFieldFinder);
    final TextField newField = tester.widget(newPasswordFieldFinder);
    final TextField confirmField = tester.widget(confirmPasswordFieldFinder);
    expect(currentField.obscureText, isTrue);
    expect(newField.obscureText, isTrue);
    expect(confirmField.obscureText, isTrue);

    // Find the eye icon buttons (initially visibility_off_outlined)
    final eyeIconsFinder = find.byIcon(Icons.visibility_off_outlined);
    expect(eyeIconsFinder, findsNWidgets(3));

    // Tap on the second eye icon (new password field visibility toggle)
    await tester.ensureVisible(newPasswordFieldFinder);
    await tester.pumpAndSettle();
    await tester.tap(eyeIconsFinder.at(1));
    await tester.pump();

    // Now, new field's obscureText must be false
    final TextField newFieldUpdated = tester.widget(newPasswordFieldFinder);
    expect(newFieldUpdated.obscureText, isFalse);

    // Verification 1: empty fields validation
    final updateButtonFinder = find.widgetWithText(ElevatedButton, 'Update');
    expect(updateButtonFinder, findsOneWidget);

    await tester.ensureVisible(updateButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(updateButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Please fill in all fields');

    // Fill in current password, but leave others empty
    await tester.enterText(currentPasswordFieldFinder, 'oldpass123');
    await tester.ensureVisible(updateButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(updateButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Please fill in all fields');

    // Fill in current password and new password too short (< 6 chars)
    await tester.enterText(newPasswordFieldFinder, '12345');
    await tester.enterText(confirmPasswordFieldFinder, '12345');
    await tester.ensureVisible(updateButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(updateButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Password must be at least 6 characters long');

    // Fill in valid new password but mismatching confirmation
    await tester.enterText(newPasswordFieldFinder, 'newpass123');
    await tester.enterText(confirmPasswordFieldFinder, 'mismatch123');
    await tester.ensureVisible(updateButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(updateButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Passwords do not match');

    // Valid inputs
    await tester.enterText(confirmPasswordFieldFinder, 'newpass123');
    await tester.ensureVisible(updateButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(updateButtonFinder);
    await tester.pumpAndSettle();

    // Success toast and popped screen
    expect(methodCalls.last.arguments['msg'], 'Password updated successfully');
    expect(find.text('Reset password'), findsNothing); // Should navigate back to settings screen
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('SettingsScreen language selection test', (WidgetTester tester) async {
    // Mock the fluttertoast channel to capture the toast messages.
    final List<MethodCall> methodCalls = [];
    const channel = MethodChannel('PonnamKarthik/fluttertoast');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      return true;
    });


    // Render SettingsScreen inside a GetMaterialApp
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        getPages: AppRoute.routes,
        home: const SettingsScreen(),
      ),
    );

    await tester.pump();

    // Verify settings screen has "Change Language" tile in English
    expect(find.text('Change Language'), findsOneWidget);

    // Tap on the Change Language tile to open language bottom sheet
    await tester.tap(find.text('Change Language'));
    await tester.pumpAndSettle();

    // Verify language selector sheet header is shown
    expect(find.text('Select Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('French'), findsOneWidget);

    // Tap on French option inside runAsync to allow the async updateLocale to complete
    await tester.runAsync(() async {
      await tester.tap(find.text('French'));
      await Future.delayed(const Duration(milliseconds: 300));
    });
    await tester.pumpAndSettle();

    // Verify bottom sheet is dismissed and language changed success toast is shown
    expect(find.text('Select Language'), findsNothing);
    expect(methodCalls.last.arguments['msg'], 'Langue changée avec succès');

    // Verify that the UI changed to French dynamically ("Change Language" should now be "Changer de langue")
    expect(find.text('Changer de langue'), findsOneWidget);
    expect(find.text('Paramètres'), findsOneWidget); // Settings header also translated
  });

  testWidgets('SettingsScreen logout test', (WidgetTester tester) async {
    // Set a larger test viewport size to prevent scrolling hit-test warnings
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Mock the fluttertoast channel to capture the toast messages.
    final List<MethodCall> methodCalls = [];
    const channel = MethodChannel('PonnamKarthik/fluttertoast');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      return true;
    });

    // Set initial auth token in mock SharedPreferenceHelper
    final prefHelper = Get.find<SharedPreferenceHelper>();
    await prefHelper.setString('auth_token', 'mock_user_token_12345');

    // Verify token exists initially
    expect(prefHelper.getString('auth_token'), 'mock_user_token_12345');

    // Render SettingsScreen inside a GetMaterialApp
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        getPages: AppRoute.routes,
        home: const SettingsScreen(),
      ),
    );

    await tester.pump();

    // Verify "Logout" button is present
    expect(find.text('Logout'), findsOneWidget);

    // Tap on Logout button to open confirmation dialog
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog is visible
    expect(find.text('Are you sure you want to log out?'), findsOneWidget);
    expect(find.text('Yes'), findsOneWidget);
    expect(find.text('No'), findsOneWidget);

    // Tap Yes to confirm logout
    await tester.tap(find.text('Yes'));
    await tester.pump(); // Start logout async logic

    // Advance clock by 1100ms to resolve mock verification delay
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    // Verify logout success toast is shown
    expect(methodCalls.last.arguments['msg'], 'Logged out');

    // Verify auth token is deleted from SharedPreferences
    expect(prefHelper.getString('auth_token'), '');
  });

  testWidgets('SettingsScreen Two-Factor Authentication onboarding flow test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Mock the fluttertoast channel to capture the toast messages.
    final List<MethodCall> methodCalls = [];
    const channel = MethodChannel('PonnamKarthik/fluttertoast');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      return true;
    });

    // Render SettingsScreen inside a GetMaterialApp
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        getPages: AppRoute.routes,
        home: const SettingsScreen(),
      ),
    );

    await tester.pump();

    // Verify 2FA title is present
    expect(find.text('Two-factor authentication'), findsOneWidget);

    // Tap on the tile to start onboarding
    await tester.tap(find.text('Two-factor authentication'));
    await tester.pumpAndSettle();

    // STEP 0: Intro
    expect(find.text('Protect your account with an extra layer of security.'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    // Tap Get started
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    // STEP 1: Selection
    expect(find.text('Enabling 2FA'), findsOneWidget);
    expect(find.text('Enable'), findsOneWidget);

    // Tap Enable
    await tester.tap(find.text('Enable'));
    await tester.pump(); // Start request API call
    await tester.pumpAndSettle();

    // STEP 2: OTP verification
    expect(find.text('One-Time Password'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);

    // Enter 5 digit OTP using MaterialPinField
    final fields = find.byType(MaterialPinField);
    expect(fields, findsOneWidget);
    await tester.enterText(fields, '11111');
    await tester.pump();

    // Tap Submit
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pump(); // Start verify API call
    await tester.pumpAndSettle();

    // Verify success toast, popped to SettingsScreen, and 2FA enabled in pref helper
    expect(methodCalls.last.arguments['msg'], 'Two-factor auth enabled');
    expect(find.text('One-Time Password'), findsNothing);
    expect(Get.find<SharedPreferenceHelper>().getIs2faEnabled(), isTrue);
  });

  testWidgets('SettingsScreen notifications toggles and login history navigation test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final List<MethodCall> methodCalls = [];
    const channel = MethodChannel('PonnamKarthik/fluttertoast');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      return true;
    });

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        getPages: AppRoute.routes,
        home: const SettingsScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify "Message notifications" tile is shown (renamed from SMS notifications)
    expect(find.text('Message notifications'), findsOneWidget);
    expect(find.text('Receive message updates'), findsOneWidget);

    // 2. Test Login History Navigation and fetch logs
    expect(find.text('Login histories'), findsOneWidget);
    await tester.tap(find.text('Login histories'));
    await tester.pumpAndSettle();

    // Verify navigating to LoginHistoryScreen
    expect(find.text('Logged in from Chrome on Windows'), findsOneWidget);

    // Go back
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // 3. Test Email Notifications toggle action
    final emailTile = find.ancestor(
      of: find.text('Email notifications'),
      matching: find.byType(ListTile),
    );
    final emailSwitch = find.descendant(
      of: emailTile,
      matching: find.byType(GestureDetector),
    ).last;
    await tester.tap(emailSwitch);
    await tester.pumpAndSettle();

    // Verify success toast
    expect(methodCalls.any((call) => call.arguments['msg'].toString().contains('Email notifications')), isTrue);

    // 4. Test Message Notifications toggle action
    final messageTile = find.ancestor(
      of: find.text('Message notifications'),
      matching: find.byType(ListTile),
    );
    final messageSwitch = find.descendant(
      of: messageTile,
      matching: find.byType(GestureDetector),
    ).last;
    await tester.tap(messageSwitch);
    await tester.pumpAndSettle();

    // Verify success toast
    expect(methodCalls.any((call) => call.arguments['msg'].toString().contains('Message notifications')), isTrue);
  });
}

class MockApiClient extends ApiClient {
  @override
  Future<http.Response> get(
    String uri, {
    Map<String, String>? headers,
  }) async {
    if (RegExp(r'^\/users\/[^/]+\/posts(\?.*)?$').hasMatch(uri)) {
      return http.Response(
        '{"status":"success","data":[]}',
        200,
      );
    } else if (uri == '/user/profile') {
      return http.Response(
        '{"status":"success","data":{"id":5,"name":"Shahriar","username":"shahriar","photo":""}}',
        200,
      );
    } else if (uri.startsWith('/users/search')) {
      return http.Response(
        '{"status":"success","data":[{"id":"1","name":"Owolabi Ridwan","username":"owolabi","photo":"https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150"}]}',
        200,
      );
    } else if (uri == '/notifications?filter=login') {
      return http.Response(
        '{"status":"success","data":[{"id":1,"message":"Logged in from Chrome on Windows","time":"Just now"}]}',
        200,
      );
    }
    return http.Response('{"error":"not found"}', 404);
  }

  @override
  Future<http.Response> post(
    String uri, {
    dynamic body,
    Map<String, String>? headers,
  }) async {
    if (uri == '/auth/login') {
      return http.Response(
        '{"status":"success","message":"Login successful","data":{"token":"mock_user_token_12345"}}',
        200,
      );
    } else if (uri == '/users/update-settings') {
      return http.Response(
        '{"status":"success","message":"Settings updated successfully"}',
        200,
      );
    } else if (uri == '/users/update-profile') {
      return http.Response(
        '{"status":"success","message":"Profile updated successfully"}',
        200,
      );
    } else if (uri == '/account/change-password') {
      return http.Response(
        '{"status":"success","message":"Password updated successfully"}',
        200,
      );
    } else if (uri == '/auth/2fa/request') {
      return http.Response(
        '{"status":"success","message":"2FA request successful"}',
        200,
      );
    } else if (uri == '/auth/2fa/verify') {
      return http.Response(
        '{"status":"success","message":"2FA verification successful"}',
        200,
      );
    } else if (uri == '/notifications?filter=all') {
      return http.Response(
        '{"status":"success","message":"Message notifications settings updated successfully"}',
        200,
      );
    }
    return http.Response('{"error":"not found"}', 404);
  }
}
