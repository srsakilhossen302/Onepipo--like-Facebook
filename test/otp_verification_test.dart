import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:onepipo/View/Screen/OtpVerificationScreen/otp_verification_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/Core/AppRoute/app_route.dart';
import 'package:onepipo/helper/shared_prefe/shared_prefe.dart';
import 'package:onepipo/View/Screen/OtpVerificationScreen/Controller/otp_verification_controller.dart';
import 'package:onepipo/service/api_client.dart';
import 'package:http/http.dart' as http;

class MockApiClient extends ApiClient {
  @override
  Future<http.Response> get(
    String uri, {
    Map<String, String>? headers,
  }) async {
    if (RegExp(r'^\/users\/[^/]+\/posts(\?post_limit=\d+)?$').hasMatch(uri)) {
      return http.Response(
        '{"status":"success","data":[]}',
        200,
      );
    } else if (uri == '/user/profile') {
      return http.Response(
        '{"status":"success","data":{"id":5,"name":"Shahriar","username":"shahriar","photo":""}}',
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
    if (uri == '/auth/request-otp') {
      return http.Response(
        '{"status":"success","message":"OTP code sent"}',
        200,
      );
    } else if (uri == '/auth/verify-otp') {
      return http.Response(
        '{"status":"success","data":{"token":"mock_register_token_xyz"}}',
        200,
      );
    } else if (uri == '/users/upload-photo') {
      return http.Response(
        '{"status":"success","data":["https://onepipo.com/uploads/mock_photo.png"]}',
        200,
      );
    }
    return http.Response('{"error":"not found"}', 404);
  }
}

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
    Get.lazyPut<ApiClient>(() => MockApiClient(), fenix: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('OtpVerificationScreen rendering, validation, timer, and submission tests', (WidgetTester tester) async {
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

    // Setup Route Arguments for Email address
    const mockEmail = 'shahriar@gmail.com';

    // Render OtpVerificationScreen
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        initialRoute: AppRoute.otpVerification,
        initialBinding: BindingsBuilder(() {
          Get.put<OtpVerificationController>(OtpVerificationController(), tag: 'test_otp');
        }),
        getPages: [
          GetPage(
            name: AppRoute.otpVerification,
            page: () => const OtpVerificationScreen(),
            binding: BindingsBuilder(() {
              Get.put<OtpVerificationController>(OtpVerificationController());
            }),
            arguments: mockEmail,
          ),
          GetPage(
            name: AppRoute.homeScreen,
            page: () => const Scaffold(body: Text('Home Feed')),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    final controller = Get.find<OtpVerificationController>();
    controller.email.value = mockEmail;
    await tester.pump();

    // --- 1. RENDER VERIFICATION ---
    // Verify title "One Time Password" is shown twice (AppBar title and Screen Title)
    expect(find.text('One Time Password'), findsNWidgets(2));

    // Verify close icon and key icon are rendered
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(find.byIcon(Icons.key_outlined), findsOneWidget);

    // Verify explanatory subtitle contains email address
    final subtitleFinder = find.byWidgetPredicate((widget) =>
        widget is RichText &&
        widget.text.toPlainText().contains('Enter 5 digit OTP that has been sent to') &&
        widget.text.toPlainText().contains(mockEmail));
    expect(subtitleFinder, findsOneWidget);

    // Verify 5 input fields are present
    final pinInputsFinder = find.byType(TextField);
    expect(pinInputsFinder, findsNWidgets(5));

    // Verify submit button exists
    final submitButtonFinder = find.widgetWithText(ElevatedButton, 'Submit');
    expect(submitButtonFinder, findsOneWidget);

    // --- 2. CLOSE BUTTON FUNCTIONALITY ---
    // Tap close button and verify navigation pop
    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    // In test Get.back pop exits the app since it is root route inside test context,
    // but we can verify it triggers navigation or just let it close.

    // --- 3. INPUT VALIDATION ---
    // Submit with empty inputs
    await tester.tap(submitButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Please fill in all fields');

    // Submit with partial inputs (2 digits)
    await tester.enterText(pinInputsFinder.at(0), '1');
    await tester.enterText(pinInputsFinder.at(1), '2');
    await tester.tap(submitButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Please fill in all fields');

    // --- 4. COUNTDOWN TIMER AND RESEND CODE ---
    // Verify timer text displays initially
    expect(find.textContaining('Resend Code in:'), findsOneWidget);
    expect(find.textContaining('00:59'), findsOneWidget);

    // Advance clock by 60 seconds to finish countdown
    await tester.pump(const Duration(seconds: 60));
    await tester.pumpAndSettle();

    // Verify "Resend Code" link is now visible
    expect(find.text('Resend Code'), findsOneWidget);
    expect(find.textContaining('Resend Code in:'), findsNothing);

    // Click Resend Code and verify toast and timer reset
    await tester.tap(find.text('Resend Code'));
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'OTP code has been resent successfully.');
    expect(find.textContaining('Resend Code in:'), findsOneWidget);
    expect(find.textContaining('00:59'), findsOneWidget);

    // --- 5. SUCCESSFUL SUBMISSION AND NAVIGATION ---
    // Fill all 5 digits
    await tester.enterText(pinInputsFinder.at(0), '1');
    await tester.enterText(pinInputsFinder.at(1), '2');
    await tester.enterText(pinInputsFinder.at(2), '3');
    await tester.enterText(pinInputsFinder.at(3), '4');
    await tester.enterText(pinInputsFinder.at(4), '5');

    await tester.tap(submitButtonFinder);
    await tester.pump();

    // Advance simulated clock by 1600ms to resolve mock verification delay
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle(); // Settle navigation transition

    // Confirm navigation success toast
    expect(methodCalls.last.arguments['msg'], 'OTP verified successfully.');
  });
}
