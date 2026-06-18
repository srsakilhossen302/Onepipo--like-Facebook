class ApiUrl {
  static const String baseUrl = 'https://onepipo.com/api/v1';

  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/user/profile';
  static const String requestOtp = '/auth/request-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String validateUsername = '/misc/validate/username';
  static const String validateReferralCode = '/misc/validate/refcode';
  static const String posts = '/posts';
  static const String countries = '/countries';
  static const String createPost = '/posts/create';
  static String comments(String postId) => '/posts/$postId/comments';
  static String savePost(String postId) => '/posts/$postId/save';
  static String reportPost(String postId) => '/posts/$postId/report';
  static String commentReplies(String commentId) =>
      '/comments/$commentId/replies';
  static String likeComment(String commentId) => '/comments/$commentId/like';
  static String unlikeComment(String commentId) =>
      '/comments/$commentId/unlike';
  static String sharePost(String postId, String userId) =>
      '/posts/$postId/share/$userId';
  static const String updateSettings = '/users/update-settings';
  static const String updateProfile = '/users/update-profile';
  static const String uploadPhoto = '/users/upload-photo';
  static const String searchUsers = '/users/search';
  static String userPosts(String userId) => '/users/$userId/posts';
  static String blockUser(String userId) => '/users/$userId/block';
  static String unblockUser(String userId) => '/users/$userId/unblock';
  static const String blockedUsersList = '/users/blocked';
  static const String changePassword = '/users/change-password';

  // Notifications endpoints
  static const String notifications = '/notifications';
  static String markNotificationRead(String id) => '/notifications/$id/read';
  static const String markAllNotificationsRead = '/notifications/read-all';
  static const String clearAllNotifications = '/notifications/clear';
  static String acceptFollowRequest(String userId) =>
      '/users/follow-requests/$userId/accept';
  static String declineFollowRequest(String userId) =>
      '/users/follow-requests/$userId/decline';
  static String sendFollowRequest(String userId) =>
      '/users/$userId/follow-request';

  // Saved Posts endpoint
  static const String savedPosts = '/users/load/saved';

  // Archive Posts endpoints
  static String archivePost(String postId) => '/posts/$postId/archive';
  static const String archivedPosts = '/users/load/archives';
}
