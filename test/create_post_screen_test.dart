import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/View/Screen/CreatePostScreen/create_post_screen.dart';
import 'package:onepipo/View/Screen/CreatePostScreen/group_selection_screen.dart';
import 'package:onepipo/View/Screen/CreatePostScreen/tag_friends_screen.dart';
import 'package:onepipo/View/Screen/HomeScreen/Controller/home_controller.dart';

void main() {
  setUp(() {
    Get.reset(); // Reset GetX dependency injector and routing state
    final controller = HomeController();
    Get.put<HomeController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('CreatePostScreen renders and validates correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        home: const CreatePostScreen(),
      ),
    );

    await tester.pump();

    // Verify all static text and layout components exist
    expect(find.text('Create Post'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) =>
          widget is RichText && widget.text.toPlainText().contains('Shahriar')),
      findsOneWidget,
    );
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
  });

  testWidgets('CreatePostScreen preloads data and updates post when editing', (WidgetTester tester) async {
    final controller = Get.find<HomeController>();

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
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

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
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Check that the controller updated the post
    expect(controller.posts[editingIndex].contentText, 'Updated test post content');
  });

  testWidgets('GroupSelectionScreen lists, filters, selects a group', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        home: const Scaffold(),
      ),
    );

    String? returnedGroup;
    Get.to(() => const GroupSelectionScreen())?.then((val) {
      returnedGroup = val as String?;
    });
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify groups list is displayed
    expect(find.text('Select Group'), findsOneWidget);
    expect(find.text('Flutter Developers'), findsOneWidget);
    expect(find.text('Onepipo Community'), findsOneWidget);

    // Filter list
    await tester.enterText(find.byType(TextField), 'Tech');
    await tester.pump();

    expect(find.text('Flutter Developers'), findsNothing);
    expect(find.text('Tech Enthusiasts'), findsOneWidget);

    // Select group
    await tester.tap(find.text('Tech Enthusiasts'));
    await tester.pump();

    // Tap Next
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify it popped and returned the correct group name
    expect(returnedGroup, 'Tech Enthusiasts');
  });

  testWidgets('TagFriendsScreen lists, selects friends', (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslator(),
        locale: const Locale('en', 'US'),
        home: const Scaffold(),
      ),
    );

    List<String>? returnedFriends;
    Get.to(() => const TagFriendsScreen())?.then((val) {
      returnedFriends = (val as List?)?.cast<String>();
    });
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify friends list
    expect(find.text('Tag Friends'), findsOneWidget);
    expect(find.text('Owolabi Ridwan'), findsOneWidget);
    expect(find.text('Elena Gonzalez'), findsOneWidget);

    // Toggle select
    await tester.tap(find.text('Owolabi Ridwan'));
    await tester.pump();

    await tester.tap(find.text('Elena Gonzalez'));
    await tester.pump();

    // Tap Next
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // Verify selected friends are returned
    expect(returnedFriends, isNotNull);
    expect(returnedFriends, contains('Owolabi Ridwan'));
    expect(returnedFriends, contains('Elena Gonzalez'));
  });
}
