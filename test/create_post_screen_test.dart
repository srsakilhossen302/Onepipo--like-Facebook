import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:onepipo/Language/translator.dart';
import 'package:onepipo/View/Screen/CreatePostScreen/create_post_screen.dart';
import 'package:onepipo/View/Screen/CreatePostScreen/group_selection_screen.dart';
import 'package:onepipo/View/Screen/CreatePostScreen/tag_friends_screen.dart';
import 'package:onepipo/View/Screen/HomeScreen/Controller/home_controller.dart';
import 'package:onepipo/View/Screen/HomeScreen/Model/post_model.dart';
import 'package:onepipo/service/api_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:onepipo/helper/shared_prefe/shared_prefe.dart';

class MockApiClient extends ApiClient {
  @override
  Future<http.Response> get(
    String uri, {
    Map<String, String>? headers,
  }) async {
    if (RegExp(r'^\/posts(\?page=\d+)?$').hasMatch(uri)) {
      return http.Response(
        '{"status":"success","data":[]}',
        200,
      );
    } else if (RegExp(r'^\/posts\/[^/]+\/comments(\?page=\d+)?$').hasMatch(uri)) {
      return http.Response(
        '{"status":"success","data":[]}',
        200,
      );
    } else if (RegExp(r'^\/comments\/[^/]+\/replies(\?per_page=\d+)?$').hasMatch(uri)) {
      return http.Response(
        '{"status":"success","data":[{"id":"reply_111","content":"mock reply text","author":{"name":"shahriar","photo":""},"time_ago":"Just now","replies_count":0}]}',
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
    if (uri == '/posts/create') {
      return http.Response(
        '{"status":"success","message":"Post action successful"}',
        200,
      );
    } else if (RegExp(r'^\/posts\/[^/]+\/comments$').hasMatch(uri)) {
      return http.Response(
        '{"status":"success","message":"Comment stored","data":{"id":"comment_999","comment":"test comment","author":{"name":"shahriar","photo":""},"time_ago":"Just now"}}',
        201,
      );
    } else if (RegExp(r'^\/posts\/[^/]+\/like$').hasMatch(uri)) {
      return http.Response(
        '{"status":"success","message":"Post liked successfully"}',
        200,
      );
    } else if (RegExp(r'^\/posts\/[^/]+\/save$').hasMatch(uri)) {
      if (uri.contains('999')) {
        return http.Response('{"error":"server error"}', 500);
      }
      return http.Response(
        '{"status":"success","message":"Post saved successfully"}',
        200,
      );
    } else if (RegExp(r'^\/posts\/[^/]+\/report$').hasMatch(uri)) {
      if (uri.contains('999')) {
        return http.Response('{"error":"server error"}', 500);
      }
      return http.Response(
        '{"status":"success","message":"Post reported successfully"}',
        200,
      );
    } else if (RegExp(r'^\/comments\/[^/]+\/replies$').hasMatch(uri)) {
      return http.Response(
        '{"status":"success","message":"Reply stored","data":{"id":"reply_222","content":"test reply","author":{"name":"shahriar","photo":""},"time_ago":"Just now","replies_count":0}}',
        201,
      );
    } else if (RegExp(r'^\/comments\/[^/]+\/(like|unlike)$').hasMatch(uri)) {
      if (uri.contains('fail')) {
        return http.Response('{"error":"server error"}', 500);
      }
      return http.Response(
        '{"status":"success","message":"Action successful"}',
        200,
      );
    } else if (RegExp(r'^\/posts\/[^/]+\/share\/[^/]+$').hasMatch(uri)) {
      if (uri.contains('fail')) {
        return http.Response('{"error":"server error"}', 500);
      }
      return http.Response(
        '{"status":"success","message":"Post shared successfully"}',
        200,
      );
    }
    return http.Response('{"error":"not found"}', 404);
  }
}

void main() {
  setUp(() async {
    Get.reset(); // Reset GetX dependency injector and routing state
    Get.testMode = true;

    const channel = MethodChannel('PonnamKarthik/fluttertoast');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return true;
    });

    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    Get.put<SharedPreferences>(sharedPreferences, permanent: true);
    Get.put<SharedPreferenceHelper>(SharedPreferenceHelper(sharedPreferences: Get.find()), permanent: true);

    Get.lazyPut<ApiClient>(() => MockApiClient(), fenix: true);
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

  testWidgets('HomeController toggleSave success and failure rollback tests', (WidgetTester tester) async {
    final controller = Get.find<HomeController>();
    
    // Add mock posts to test
    final successPost = PostModel(
      id: '123',
      userName: 'Test User',
      userAvatarUrl: '',
      timeAgo: 'Just now',
      badgeText: 'solution',
      contentText: 'Test body',
      isSaved: false,
      comments: [],
    );
    
    final failurePost = PostModel(
      id: '999',
      userName: 'Test User',
      userAvatarUrl: '',
      timeAgo: 'Just now',
      badgeText: 'solution',
      contentText: 'Test body 2',
      isSaved: false,
      comments: [],
    );

    controller.posts.addAll([successPost, failurePost]);

    // Test toggleSave Success
    final successIndex = controller.posts.indexOf(successPost);
    expect(controller.posts[successIndex].isSaved, isFalse);

    await controller.toggleSave(successIndex);
    expect(controller.posts[successIndex].isSaved, isTrue);

    await controller.toggleSave(successIndex);
    expect(controller.posts[successIndex].isSaved, isFalse);

    // Test toggleSave Failure (ID 999 triggers 500 error, should rollback)
    final failureIndex = controller.posts.indexOf(failurePost);
    expect(controller.posts[failureIndex].isSaved, isFalse);

    await controller.toggleSave(failureIndex);
    expect(controller.posts[failureIndex].isSaved, isFalse); // Rollback to false
  });

  testWidgets('HomeController reportPost success and failure tests', (WidgetTester tester) async {
    final controller = Get.find<HomeController>();

    final successPost = PostModel(
      id: '123',
      userName: 'Test User',
      userAvatarUrl: '',
      timeAgo: 'Just now',
      badgeText: 'solution',
      contentText: 'Test body',
      comments: [],
    );
    
    final failurePost = PostModel(
      id: '999',
      userName: 'Test User',
      userAvatarUrl: '',
      timeAgo: 'Just now',
      badgeText: 'solution',
      contentText: 'Test body 2',
      comments: [],
    );

    controller.posts.addAll([successPost, failurePost]);

    final successIndex = controller.posts.indexOf(successPost);
    final successResult = await controller.reportPost(successIndex, "Spam", "Some details");
    expect(successResult, isTrue);

    final failureIndex = controller.posts.indexOf(failurePost);
    final failureResult = await controller.reportPost(failureIndex, "Inappropriate", "");
    expect(failureResult, isFalse);
  });

  testWidgets('HomeController addReply and fetchRepliesForComment API tests', (WidgetTester tester) async {
    final controller = Get.find<HomeController>();

    final testPost = PostModel(
      id: '123',
      userName: 'Test User',
      userAvatarUrl: '',
      timeAgo: 'Just now',
      badgeText: 'solution',
      contentText: 'Test body',
      comments: [
        CommentModel(
          id: 'comment_abc',
          userName: 'africa',
          userAvatarUrl: '',
          timeAgo: '1h',
          text: 'some comment',
          repliesCount: 0,
        )
      ],
    );

    controller.posts.add(testPost);
    final postIndex = controller.posts.indexOf(testPost);

    // Verify initial state
    expect(testPost.comments[0].replies, isEmpty);
    expect(testPost.comments[0].repliesCount, 0);

    // Test fetchRepliesForComment
    await controller.fetchRepliesForComment(postIndex, 'comment_abc');
    expect(testPost.comments[0].replies.length, 1);
    expect(testPost.comments[0].replies[0].id, 'reply_111');
    expect(testPost.comments[0].repliesCount, 1);

    // Test addReply
    await controller.addReply(postIndex, 'comment_abc', 'Hello, this is a reply');
    expect(testPost.comments[0].replies.length, 2);
    expect(testPost.comments[0].replies[1].id, 'reply_222');
    expect(testPost.comments[0].repliesCount, 2);
  });

  testWidgets('HomeController toggleLikeComment success and failure rollback tests', (WidgetTester tester) async {
    final controller = Get.find<HomeController>();

    final testPost = PostModel(
      id: '123',
      userName: 'Test User',
      userAvatarUrl: '',
      timeAgo: 'Just now',
      badgeText: 'solution',
      contentText: 'Test body',
      comments: [
        CommentModel(
          id: 'comment_success',
          userName: 'User A',
          userAvatarUrl: '',
          timeAgo: '1h',
          text: 'successful comment',
          likesCount: 5,
          isLiked: false,
        ),
        CommentModel(
          id: 'comment_fail',
          userName: 'User B',
          userAvatarUrl: '',
          timeAgo: '2h',
          text: 'failed comment',
          likesCount: 10,
          isLiked: false,
        ),
      ],
    );

    controller.posts.clear();
    controller.posts.add(testPost);
    final postIndex = controller.posts.indexOf(testPost);

    // Success Test
    expect(testPost.comments[0].isLiked, isFalse);
    expect(testPost.comments[0].likesCount, 5);

    await controller.toggleLikeComment(postIndex, 0);
    expect(testPost.comments[0].isLiked, isTrue);
    expect(testPost.comments[0].likesCount, 6);

    await controller.toggleLikeComment(postIndex, 0);
    expect(testPost.comments[0].isLiked, isFalse);
    expect(testPost.comments[0].likesCount, 5);

    // Failure Rollback Test
    expect(testPost.comments[1].isLiked, isFalse);
    expect(testPost.comments[1].likesCount, 10);

    await controller.toggleLikeComment(postIndex, 1);
    // Should rollback to original values due to 500 error
    expect(testPost.comments[1].isLiked, isFalse);
    expect(testPost.comments[1].likesCount, 10);
  });

  testWidgets('HomeController toggleLikeCommentReply success and failure rollback tests', (WidgetTester tester) async {
    final controller = Get.find<HomeController>();

    final testPost = PostModel(
      id: '123',
      userName: 'Test User',
      userAvatarUrl: '',
      timeAgo: 'Just now',
      badgeText: 'solution',
      contentText: 'Test body',
      comments: [
        CommentModel(
          id: 'comment_abc',
          userName: 'User A',
          userAvatarUrl: '',
          timeAgo: '1h',
          text: 'some comment',
          replies: [
            CommentModel(
              id: 'reply_success',
              userName: 'User C',
              userAvatarUrl: '',
              timeAgo: '30m',
              text: 'success reply',
              likesCount: 2,
              isLiked: false,
            ),
            CommentModel(
              id: 'reply_fail',
              userName: 'User D',
              userAvatarUrl: '',
              timeAgo: '15m',
              text: 'failed reply',
              likesCount: 8,
              isLiked: false,
            ),
          ],
        ),
      ],
    );

    controller.posts.clear();
    controller.posts.add(testPost);
    final postIndex = controller.posts.indexOf(testPost);

    // Success Test
    expect(testPost.comments[0].replies[0].isLiked, isFalse);
    expect(testPost.comments[0].replies[0].likesCount, 2);

    await controller.toggleLikeCommentReply(postIndex, 'comment_abc', 'reply_success');
    expect(testPost.comments[0].replies[0].isLiked, isTrue);
    expect(testPost.comments[0].replies[0].likesCount, 3);

    await controller.toggleLikeCommentReply(postIndex, 'comment_abc', 'reply_success');
    expect(testPost.comments[0].replies[0].isLiked, isFalse);
    expect(testPost.comments[0].replies[0].likesCount, 2);

    // Failure Rollback Test
    expect(testPost.comments[0].replies[1].isLiked, isFalse);
    expect(testPost.comments[0].replies[1].likesCount, 8);

    await controller.toggleLikeCommentReply(postIndex, 'comment_abc', 'reply_fail');
    // Should rollback to original values due to 500 error
    expect(testPost.comments[0].replies[1].isLiked, isFalse);
    expect(testPost.comments[0].replies[1].likesCount, 8);
  });

  testWidgets('HomeController shareWithFollower success and failure rollback tests', (WidgetTester tester) async {
    final controller = Get.find<HomeController>();

    final testPost = PostModel(
      id: 'post_123',
      userName: 'Test User',
      userAvatarUrl: '',
      timeAgo: 'Just now',
      badgeText: 'solution',
      contentText: 'Test body',
      sharesCount: 10,
      comments: [],
    );

    controller.posts.clear();
    controller.posts.add(testPost);
    final postIndex = controller.posts.indexOf(testPost);

    // Success Test
    expect(controller.isFollowerShared('post_123', 'follower_success'), isFalse);
    expect(testPost.sharesCount, 10);

    await controller.shareWithFollower(postIndex, 'follower_success');
    expect(controller.isFollowerShared('post_123', 'follower_success'), isTrue);
    expect(testPost.sharesCount, 11);

    // Trying to share with same follower again should do nothing
    await controller.shareWithFollower(postIndex, 'follower_success');
    expect(testPost.sharesCount, 11);

    // Failure Rollback Test
    expect(controller.isFollowerShared('post_123', 'follower_fail'), isFalse);

    await controller.shareWithFollower(postIndex, 'follower_fail');
    // Should rollback due to 500 error
    expect(controller.isFollowerShared('post_123', 'follower_fail'), isFalse);
    expect(testPost.sharesCount, 11);
  });
}
