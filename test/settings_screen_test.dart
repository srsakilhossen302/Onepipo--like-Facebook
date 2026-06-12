import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/View/Screen/SettingsScreen/settings_screen.dart';
import 'package:onepipo/Core/AppRoute/app_route.dart';

void main() {
  setUp(() {
    Get.reset();
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
}
