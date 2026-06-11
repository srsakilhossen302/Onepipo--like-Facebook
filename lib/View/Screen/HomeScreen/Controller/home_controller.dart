import 'package:get/get.dart';
import '../Model/post_model.dart';
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
        userName: 'Owolabi Ridwan',
        userAvatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
        timeAgo: '6h',
        badgeText: 'Problem',
        contentText: 'Insecurity',
        likesCount: 1,
        commentsCount: 1,
        sharesCount: 0,
        isLiked: false,
      ),
      PostModel(
        id: '2',
        userName: 'Africa',
        userAvatarUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=150',
        timeAgo: '10h',
        badgeText: 'Problem',
        contentText: 'Le Nigeria en tête, la RD Congo juste derrière. Les origines Africaines seront largement représentées parmi les mondialistes non Africains lors du mondial 2026. Source: @sportnewsafrica',
        contentImageUrl: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?w=800',
        likesCount: 5,
        commentsCount: 5,
        sharesCount: 2,
        isLiked: true,
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
    
    ToastMessage.showToast(message: "Comment added!");
  }

  void sharePost(int index) {
    if (index < 0 || index >= posts.length) return;
    
    final post = posts[index];
    post.sharesCount++;
    posts[index] = post;
    posts.refresh();
    
    ToastMessage.showSnackBar(
      title: "Shared!",
      message: "Post shared successfully to your feed.",
    );
  }

  Future<void> refreshFeed() async {
    isLoading.value = true;
    await Future.delayed(const Duration(seconds: 1));
    loadMockPosts();
    isLoading.value = false;
  }
}
