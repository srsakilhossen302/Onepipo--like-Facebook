import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/Core/AppRoute/app_route.dart';
import 'package:onepipo/helper/shared_prefe/shared_prefe.dart';
import 'package:onepipo/View/Screen/LoginScreen/Controller/login_controller.dart';

void main() {
  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('LoginScreen rendering and input validation tests', (WidgetTester tester) async {
    // Mock the fluttertoast channel to capture the toast messages.
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

    // Render LoginScreen by routing to `/login` inside GetMaterialApp
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        initialRoute: AppRoute.loginScreen,
        getPages: AppRoute.routes,
      ),
    );

    await tester.pumpAndSettle();

    // Verify static layout texts
    expect(find.text('Join Onepipo'), findsOneWidget);
    expect(find.text('Connect with people who matter to you'), findsOneWidget);
    expect(find.text('Email address'), findsOneWidget);
    expect(find.text('Password'), findsNWidgets(2));
    expect(find.text('Forget password'), findsOneWidget);
    expect(find.text('I agree to the Terms of Service and Privacy policy'), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
    expect(find.text("Don't have an account? "), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Verify prefix components
    expect(find.byIcon(Icons.alternate_email_rounded), findsOneWidget);
    expect(find.text('|**'), findsOneWidget);

    // Verify TextFields exist
    final textFieldsFinder = find.byType(TextField);
    expect(textFieldsFinder, findsNWidgets(2));

    final emailFieldFinder = textFieldsFinder.at(0);
    final passwordFieldFinder = textFieldsFinder.at(1);

    // Verify password is initially obscured
    final TextField passwordTextField = tester.widget(passwordFieldFinder);
    expect(passwordTextField.obscureText, isTrue);

    // Toggle password visibility
    final eyeIconFinder = find.byIcon(Icons.visibility_off_outlined);
    expect(eyeIconFinder, findsOneWidget);
    await tester.tap(eyeIconFinder);
    await tester.pump();

    final TextField passwordTextFieldUpdated = tester.widget(passwordFieldFinder);
    expect(passwordTextFieldUpdated.obscureText, isFalse);

    // Test Validation 1: Submit with empty fields
    final submitButtonFinder = find.widgetWithText(ElevatedButton, 'Submit');
    expect(submitButtonFinder, findsOneWidget);

    await tester.ensureVisible(submitButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(submitButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Please fill in all fields');

    // Test Validation 2: Invalid email format
    await tester.enterText(emailFieldFinder, 'sakil_invalid_email');
    await tester.enterText(passwordFieldFinder, 'password123');
    await tester.ensureVisible(submitButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(submitButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Please enter a valid email address');

    // Test Validation 3: Password too short (< 6 characters)
    await tester.enterText(emailFieldFinder, 'sakil@gmail.com');
    await tester.enterText(passwordFieldFinder, '12345');
    await tester.ensureVisible(submitButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(submitButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'Password must be at least 6 characters long');

    // Test Validation 4: Not agreeing to terms and conditions
    await tester.enterText(passwordFieldFinder, 'password123');
    await tester.ensureVisible(submitButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(submitButtonFinder);
    await tester.pump();
    expect(methodCalls.last.arguments['msg'], 'You must agree to the terms of service and privacy policy');

    // Agree to terms programmatically and submit successfully
    Get.find<LoginController>().agreeTerms.value = true;
    await tester.pumpAndSettle();

    await tester.ensureVisible(submitButtonFinder);
    await tester.tap(submitButtonFinder);
    await tester.pump(); // Dispatch the tap event immediately to trigger controller.login()

    // Advance the FakeAsync clock by 1600ms so the 1500ms delay fires
    await tester.pump(const Duration(milliseconds: 1600));

    // Settle the navigation transition to Home Screen
    await tester.pump(const Duration(seconds: 1));

    // Verify success toast and route transition to Home
    expect(methodCalls.last.arguments['msg'], 'Login successful');
    expect(find.text('Join Onepipo'), findsNothing);
  });
}
