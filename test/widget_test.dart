import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:onepipo/main.dart';
import 'package:onepipo/helper/shared_prefe/shared_prefe.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test - loads MyApp', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
    Get.put<SharedPreferenceHelper>(SharedPreferenceHelper(sharedPreferences: Get.find()), permanent: true);

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.byType(MyApp), findsOneWidget);
  });
}
