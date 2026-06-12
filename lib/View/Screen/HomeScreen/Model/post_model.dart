class CommentModel {
  final String id;
  final String userName;
  final String userAvatarUrl;
  final String timeAgo;
  final String text;
  int likesCount;
  bool isLiked;
  bool isDisliked;
  final List<CommentModel> replies;

  CommentModel({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.timeAgo,
    required this.text,
    this.likesCount = 0,
    this.isLiked = false,
    this.isDisliked = false,
    List<CommentModel>? replies,
  }) : replies = replies ?? [];
}

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
  final List<CommentModel> comments;

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
    required this.comments,
  });
}
