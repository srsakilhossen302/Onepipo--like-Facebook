class PostModel {
  final String id;
  final String userName;
  final String userAvatarUrl;
  final String timeAgo;
  final String badgeText;
  final String contentText;
  final String? contentImageUrl;
  int likesCount;
  int commentsCount;
  int sharesCount;
  bool isLiked;

  PostModel({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.timeAgo,
    required this.badgeText,
    required this.contentText,
    this.contentImageUrl,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
  });
}
