class TimeConverter {
  // Simple custom date formatter (e.g. 2026-06-12)
  static String formatDate(DateTime dateTime) {
    return "${dateTime.year.toString().padLeft(4, '0')}-"
        "${dateTime.month.toString().padLeft(2, '0')}-"
        "${dateTime.day.toString().padLeft(2, '0')}";
  }

  // Simple custom time formatter (e.g. 14:30)
  static String formatTime(DateTime dateTime) {
    return "${dateTime.hour.toString().padLeft(2, '0')}:"
        "${dateTime.minute.toString().padLeft(2, '0')}";
  }

  // Time ago string generator (e.g. 5 minutes ago)
  static String timeAgo(DateTime dateTime) {
    final Duration difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 365) {
      return "${(difference.inDays / 365).floor()} years ago";
    } else if (difference.inDays > 30) {
      return "${(difference.inDays / 30).floor()} months ago";
    } else if (difference.inDays > 7) {
      return "${(difference.inDays / 7).floor()} weeks ago";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hours ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "just now";
    }
  }
}
