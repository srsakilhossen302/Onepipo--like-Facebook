import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/Core/AppRoute/app_route.dart';
import 'package:onepipo/helper/shared_prefe/shared_prefe.dart';
import 'package:onepipo/View/Screen/CreateAccountScreen/Controller/create_account_controller.dart';
import 'package:onepipo/View/Screen/OtpVerificationScreen/otp_verification_screen.dart';
import 'package:http/http.dart' as http;
import 'package:onepipo/service/api_client.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
    Get.lazyPut<ApiClient>(() => MockApiClient(), fenix: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('CreateAccountScreen revised flow: Step 1 -> OTP Verification -> Step 2 -> Home Feed', (WidgetTester tester) async {
    // Set a larger test viewport size to prevent scrolling hit-test warnings
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Mock fluttertoast channel to capture the toast messages.
    final List<MethodCall> methodCalls = [];
    const channel = MethodChannel('PonnamKarthik/fluttertoast');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      methodCalls.add(methodCall);
      return true;
    });

    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
    Get.put<SharedPreferenceHelper>(SharedPreferenceHelper(sharedPreferences: Get.find()), permanent: true);

    // Render CreateAccountScreen under routing context
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        initialRoute: AppRoute.createAccount,
        getPages: AppRoute.routes,
      ),
    );

    await tester.pumpAndSettle();

    // --- STEP 1 UI VERIFICATION ---
    expect(find.text('Step 1 of 2'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text("Let's get you started with the basics"), findsOneWidget);

    final textFieldsStep1 = find.byType(TextField);
    expect(textFieldsStep1, findsNWidgets(6));

    final fullNameField = textFieldsStep1.at(1);
    final usernameField = textFieldsStep1.at(2);
    final emailField = textFieldsStep1.at(3);
    final passwordField = textFieldsStep1.at(4);
    final confirmPasswordField = textFieldsStep1.at(5);

    // Verify obscurity and eye toggle
    final TextField passWidget = tester.widget(passwordField);
    expect(passWidget.obscureText, isTrue);

    final eyeButtons = find.byIcon(Icons.visibility_off_outlined);
    expect(eyeButtons, findsNWidgets(2)); // for both password & confirm password

    await tester.ensureVisible(eyeButtons.first);
    await tester.pumpAndSettle();
    await tester.tap(eyeButtons.first);
    await tester.pump();
    final TextField passWidgetUpdated = tester.widget(passwordField);
    expect(passWidgetUpdated.obscureText, isFalse);

    // --- STEP 1 VALIDATIONS ---
    final actionButtonFinder = find.byType(ElevatedButton);
    expect(actionButtonFinder, findsOneWidget);

    // Validation 1: empty fields submit
    await tester.tap(actionButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Please fill in all fields');

    // Enter details for Step 1
    await tester.enterText(fullNameField, 'Shahriar Hossen');
    await tester.enterText(usernameField, 'shahriar');
    await tester.enterText(emailField, 'shahriar@gmail.com');
    await tester.enterText(passwordField, '123456');
    await tester.enterText(confirmPasswordField, '123456');
    await tester.pumpAndSettle();

    // Step 1 Success -> Triggers navigation transition to OTP Verification screen
    await tester.tap(actionButtonFinder);
    await tester.pump();

    // Advance clock by 1.5s for Step 1 navigation delay
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // --- OTP VERIFICATION SCREEN INTERACTION ---
    expect(find.byType(OtpVerificationScreen), findsOneWidget);
    expect(find.text('One Time Password'), findsNWidgets(2));

    // Verify 5 inputs on OTP Screen
    final otpFields = find.byType(TextField);
    expect(otpFields, findsNWidgets(5));

    await tester.enterText(otpFields.at(0), '1');
    await tester.enterText(otpFields.at(1), '2');
    await tester.enterText(otpFields.at(2), '3');
    await tester.enterText(otpFields.at(3), '4');
    await tester.enterText(otpFields.at(4), '5');

    // Tap submit on OTP Screen
    final otpSubmitButton = find.widgetWithText(ElevatedButton, 'Submit');
    await tester.tap(otpSubmitButton);
    await tester.pump();

    // Advance mock timer by 1.5s for verification delay
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();

    // OTP verification successful toast
    expect(methodCalls.last.arguments['msg'], 'OTP verified successfully.');

    // --- STEP 2: FINAL STEP UI VERIFICATION ---
    // Pinned back to CreateAccountScreen, now displaying Step 2
    expect(find.byType(OtpVerificationScreen), findsNothing);
    final controller = Get.find<CreateAccountController>();
    expect(controller.currentStep.value, 2);
    expect(find.text('Step 2 of 2'), findsOneWidget);
    expect(find.text('Final step'), findsOneWidget);

    // Verify final step form elements
    expect(find.text('Select your country'), findsNWidgets(2)); // label + hint inside dropdown
    expect(find.text('Gender (optional)'), findsOneWidget);
    expect(find.text('Bio (optional)'), findsOneWidget);

    final bioField = find.byType(TextField);
    expect(bioField, findsOneWidget);

    // Submit Step 2 validations (missing country selection)
    final step2SubmitButton = find.widgetWithText(ElevatedButton, 'Submit');
    await tester.tap(step2SubmitButton);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Please select your country');

    // Select country Bangladesh
    controller.selectedCountry.value = 'Bangladesh';
    await tester.pumpAndSettle();

    // Select gender Male
    await tester.tap(find.byIcon(Icons.male));
    await tester.pump();

    // Type bio details
    await tester.enterText(bioField.first, 'My biography information.');
    await tester.pump();

    // Tap Step 2 Submit
    await tester.tap(step2SubmitButton);
    await tester.pump();

    // Resolve final sign-up delay
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pump(const Duration(seconds: 1));

    // Final registration completed successfully
    expect(methodCalls.last.arguments['msg'], 'Registration successful');
    expect(find.text('Step 2 of 2'), findsNothing);
  });
}

class MockApiClient extends ApiClient {
  @override
  Future<http.Response> get(
    String uri, {
    Map<String, String>? headers,
  }) async {
    if (uri == '/countries') {
      return http.Response(
        '{"status":"success","data":[{"id":1,"name":"Bangladesh","code":"BD"},{"id":2,"name":"United States","code":"US"}]}',
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
    } else if (uri == '/misc/validate/username') {
      return http.Response(
        '{"status":"success","message":"Username is valid"}',
        200,
      );
    } else if (uri == '/misc/validate/refcode') {
      return http.Response(
        '{"status":"success","message":"Referral code is valid"}',
        200,
      );
    } else if (uri == '/auth/request-otp') {
      return http.Response(
        '{"status":"success","message":"OTP code sent"}',
        200,
      );
    } else if (uri == '/auth/verify-otp') {
      return http.Response(
        '{"status":"success","data":{"token":"mock_register_token_xyz"}}',
        200,
      );
    } else if (uri == '/auth/register') {
      return http.Response(
        '{"status":"success","message":"Registration successful","data":{"token":"mock_register_token_xyz"}}',
        200,
      );
    } else if (uri == '/users/update-profile') {
      return http.Response(
        '{"status":"success","message":"Profile updated successfully"}',
        200,
      );
    }
    return http.Response('{"error":"not found"}', 404);
  }
}
