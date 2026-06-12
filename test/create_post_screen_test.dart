import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/View/Screen/CreatePostScreen/create_post_screen.dart';
import 'package:onepipo/View/Screen/HomeScreen/Controller/home_controller.dart';

void main() {
  testWidgets('CreatePostScreen renders and validates correctly', (WidgetTester tester) async {
    // Inject HomeController for the view to fetch
    final controller = HomeController();
    Get.put<HomeController>(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        home: const CreatePostScreen(),
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

  testWidgets('CreatePostScreen preloads data and updates post when editing', (WidgetTester tester) async {
    final controller = HomeController();
    Get.put<HomeController>(controller);

    // Ahmed Wahid's is index 0, Shahriar's is index 3 in mock posts
    const editingIndex = 3; 
    final originalPost = controller.posts[editingIndex];

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        home: const Scaffold(),
      ),
    );

    Get.to(() => const CreatePostScreen(), arguments: editingIndex);
    await tester.pumpAndSettle();

    // Title should be "Edit Post" and action button should be "Save"
    expect(find.text('Edit Post'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);

    // Content should be preloaded with original post text
    final textFinder = find.byType(TextField);
    expect(textFinder, findsOneWidget);
    TextField textWidget = tester.widget<TextField>(textFinder);
    expect(textWidget.controller?.text, originalPost.contentText);

    // Modify the content
    await tester.enterText(textFinder, 'Updated test post content');
    await tester.pump();

    // Click Save
    final saveButtonFinder = find.widgetWithText(TextButton, 'Save');
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle();

    // Check that the controller updated the post
    expect(controller.posts[editingIndex].contentText, 'Updated test post content');

    // Clean up
    Get.delete<HomeController>();
  });
}

