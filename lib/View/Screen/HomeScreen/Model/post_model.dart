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

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return CommentModel(
      id: (json['id'] ?? '').toString(),
      userName: (author != null ? author['name'] : null) ?? 'Anonymous',
      userAvatarUrl: (author != null ? author['photo'] : null) ?? '',
      timeAgo: json['time_ago'] ?? 'Just now',
      text: json['content'] ?? json['comment'] ?? json['text'] ?? '',
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isDisliked: json['is_disliked'] ?? false,
      replies: json['replies'] != null
          ? (json['replies'] as List).map((r) => CommentModel.fromJson(r)).toList()
          : [],
    );
  }
}

class PostModel {
  final String id;
  final String userName;
  final String userAvatarUrl;
  final String timeAgo;
  String badgeText;
  String contentText;
  String? contentImageUrl;
  String? groupName;
  List<String>? taggedFriends;
  int likesCount;
  int commentsCount;
  int sharesCount;
  bool isLiked;
  bool isSaved;
  final List<CommentModel> comments;

  PostModel({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.timeAgo,
    required this.badgeText,
    required this.contentText,
    this.contentImageUrl,
    this.groupName,
    this.taggedFriends,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.isLiked = false,
    this.isSaved = false,
    required this.comments,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>?;
    return PostModel(
      id: (json['id'] ?? '').toString(),
      userName: (author != null ? author['name'] : null) ?? 'Anonymous',
      userAvatarUrl: (author != null ? author['photo'] : null) ?? '',
      timeAgo: json['time_ago'] ?? 'Just now',
      badgeText: json['type'] ?? '',
      contentText: json['description'] ?? '',
      contentImageUrl: json['image'],
      groupName: json['group_name'],
      taggedFriends: json['tagged_friends'] != null
          ? List<String>.from(json['tagged_friends'])
          : null,
      likesCount: json['likes'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      sharesCount: json['shares_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isSaved: json['is_saved'] ?? false,
      comments: json['comments'] != null
          ? (json['comments'] as List).map((c) => CommentModel.fromJson(c)).toList()
          : [],
    );
  }
}
