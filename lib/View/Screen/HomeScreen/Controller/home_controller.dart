import 'package:get/get.dart';
import '../Model/post_model.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';

class HomeController extends GetxController {
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMockPosts();
  }

  void loadMockPosts() {
    posts.assignAll([
      PostModel(
        id: '1',
        userName: 'Ahmed Wahid',
        userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        timeAgo: '1h ago',
        badgeText: StaticString.solution,
        contentText: 'Are you ready to dive into this exciting journey? Let\'s get started by exploring the fundamentals together! 🚀 We\'ll cover everything you need to know to set a solid foundation for your adventure ahead. So, buckle up and let\'s embark on this learning experience!',
        likesCount: 23,
        commentsCount: 13,
        sharesCount: 8,
        isLiked: false,
      ),
      PostModel(
        id: '2',
        userName: 'Elena Gonzalez',
        userAvatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150',
        timeAgo: '1h ago',
        badgeText: StaticString.problem,
        contentText: 'Are you ready to dive into this exciting journey? Let\'s get started by exploring the fundamentals together',
        contentImageUrl: 'https://images.unsplash.com/photo-1540039155733-5bb30b53aa14?w=800',
        likesCount: 23,
        commentsCount: 13,
        sharesCount: 8,
        isLiked: false,
      ),
      PostModel(
        id: '3',
        userName: 'Ahmed Wahid',
        userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        timeAgo: '1h ago',
        badgeText: StaticString.solution,
        contentText: 'Are you ready to dive into this exciting journey? Let\'s get started by exploring the fundamentals together',
        likesCount: 23,
        commentsCount: 13,
        sharesCount: 8,
        isLiked: false,
      ),
    ]);
  }

  void toggleLike(int index) {
    if (index < 0 || index >= posts.length) return;
    
    final post = posts[index];
    if (post.isLiked) {
      post.isLiked = false;
      post.likesCount--;
    } else {
      post.isLiked = true;
      post.likesCount++;
    }
    posts[index] = post;
    posts.refresh();
  }

  void addComment(int index, String commentText) {
    if (index < 0 || index >= posts.length || commentText.trim().isEmpty) return;
    
    final post = posts[index];
    post.commentsCount++;
    posts[index] = post;
    posts.refresh();
    
    ToastMessage.showToast(message: StaticString.commentAdded.tr);
  }

  void sharePost(int index) {
    if (index < 0 || index >= posts.length) return;
    
    final post = posts[index];
    post.sharesCount++;
    posts[index] = post;
    posts.refresh();
    
    ToastMessage.showSnackBar(
      title: StaticString.shared.tr,
      message: StaticString.sharedMsg.tr,
    );
  }

  Future<void> refreshFeed() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    loadMockPosts();
    isLoading.value = false;
  }
}
