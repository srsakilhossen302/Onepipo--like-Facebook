import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:onepipo/View/Screen/CreatePostScreen/create_post_screen.dart';
import 'package:onepipo/View/Screen/HomeScreen/Controller/home_controller.dart';

void main() {
  testWidgets('CreatePostScreen renders and validates correctly', (WidgetTester tester) async {
    // Inject HomeController for the view to fetch
    final controller = HomeController();
    Get.put<HomeController>(controller);

    await tester.pumpWidget(
      const GetMaterialApp(
        home: CreatePostScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify all static text and layout components exist
    expect(find.text('Create Post'), findsOneWidget);
    expect(find.text('Shahriar'), findsOneWidget);
    expect(find.text('@shahriar_'), findsOneWidget);
    expect(find.text('Public'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    // Post button should be disabled initially
    final postButtonFinder = find.widgetWithText(TextButton, 'Post');
    expect(postButtonFinder, findsOneWidget);
    TextButton postButton = tester.widget<TextButton>(postButtonFinder);
    expect(postButton.onPressed, isNull);

    // Typing content should enable the post button
    await tester.enterText(find.byType(TextField), 'Sharing thoughts on situation');
    await tester.pump();
    
    postButton = tester.widget<TextButton>(postButtonFinder);
    expect(postButton.onPressed, isNotNull);

    // Clean up
    Get.delete<HomeController>();
  });
}
