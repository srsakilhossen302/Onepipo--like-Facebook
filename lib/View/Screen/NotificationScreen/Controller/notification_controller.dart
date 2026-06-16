import 'dart:convert';
import 'package:get/get.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../service/api_check.dart';
import '../../../../Utils/ToastMessage/toast_message.dart';
import '../../../../Utils/StaticString/static_string.dart';
import '../../HomeScreen/Controller/home_controller.dart';

enum NotificationType { like, followRequest, comment }

class NotificationItem {
  final String id;
  final String userName;
  final String avatarUrl;
  final String message;
  final String time;
  final NotificationType type;
  bool isUnread;
  String? actionStatus; // null, 'accepted', 'declined'
  final String? followRequestId;

  NotificationItem({
    required this.id,
    required this.userName,
    required this.avatarUrl,
    required this.message,
    required this.time,
    required this.type,
    this.isUnread = false,
    this.actionStatus,
    this.followRequestId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    print('=== Notification JSON Keys: $json');
    print('=== Notification JSON All Keys: ${json.keys}');
    NotificationType type;
    switch (json['type']) {
      case 'like':
        type = NotificationType.like;
        break;
      case 'follow_request':
        type = NotificationType.followRequest;
        break;
      case 'comment':
      default:
        type = NotificationType.comment;
        break;
    }

    // Get user data - check 'author' first like PostModel, then 'user'
    Map<String, dynamic>? userJson =
        (json['author'] as Map<String, dynamic>?) ??
        (json['user'] as Map<String, dynamic>?);
    print('=== User JSON: $userJson');
    if (userJson != null) {
      print('=== User JSON Keys: ${userJson.keys}');
    }

    // Try to get name from multiple possible fields
    String? name;
    if (userJson != null) {
      name = userJson['name'];
      if (name == null &&
          userJson['first_name'] != null &&
          userJson['last_name'] != null) {
        name = '${userJson['first_name']} ${userJson['last_name']}';
      }
      name ??= userJson['first_name'];
      name ??= userJson['user_name'];
      name ??= userJson['userName'];
      name ??= userJson['username'];
    }
    // If still no name, try top-level fields
    name ??= json['name'];
    name ??= json['user_name'];
    name ??= json['userName'];
    name ??= json['username'];
    name ??= 'Unknown';

    // Try to get avatar
    String? avatar;
    if (userJson != null) {
      avatar = userJson['photo'];
      avatar ??= userJson['avatar'];
      avatar ??= userJson['avatar_url'];
      avatar ??= userJson['avatarUrl'];
      avatar ??= userJson['profile_image'];
    }
    avatar ??= json['photo'];
    avatar ??= json['avatar'];
    avatar ??= json['avatar_url'];
    avatar ??= json['avatarUrl'];
    avatar ??= json['profile_image'];
    avatar ??=
        'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150';

    return NotificationItem(
      id: json['id']?.toString() ?? '',
      userName: name,
      avatarUrl: avatar,
      message:
          json['message'] ??
          json['body'] ??
          json['description'] ??
          json['text'] ??
          '',
      time:
          json['time'] ?? json['time_ago'] ?? json['created_at'] ?? 'Just now',
      type: type,
      isUnread:
          json['is_unread'] ??
          json['isUnread'] ??
          json['read'] == false ??
          false,
      followRequestId: json['follow_request_id']?.toString(),
    );
  }
}

class NotificationController extends GetxController {
  final HomeController homeController = Get.find<HomeController>();

  var notifications = <NotificationItem>[].obs;
  var isLoading = false.obs;
  var loadingActions = <String>{}
      .obs; // For tracking individual notification actions (accept/decline)

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await Get.find<ApiClient>().get(ApiUrl.notifications);
      print('Notifications API Response: ${response.body}'); // Debug print
      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          notifications.value = data
              .map((json) => NotificationItem.fromJson(json))
              .toList();
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.markNotificationRead(id),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          notifications[index].isUnread = false;
          notifications.refresh();
        }
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.markAllNotificationsRead,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        for (int i = 0; i < notifications.length; i++) {
          notifications[i].isUnread = false;
        }
        notifications.refresh();
        ToastMessage.showToast(message: "All notifications marked as read");
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.clearAllNotifications,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        notifications.clear();
        notifications.refresh();
        ToastMessage.showToast(message: "All notifications cleared");
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    }
  }

  Future<void> acceptFollowRequest(NotificationItem item) async {
    if (item.followRequestId == null) return;

    loadingActions.add(item.id);
    loadingActions.refresh();

    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.acceptFollowRequest(item.followRequestId!),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = notifications.indexWhere((n) => n.id == item.id);
        if (index != -1) {
          notifications[index].actionStatus = 'accepted';
          notifications[index].isUnread = false;
          notifications.refresh();
        }
        ToastMessage.showToast(message: StaticString.requestAccepted.tr);
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    } finally {
      loadingActions.remove(item.id);
      loadingActions.refresh();
    }
  }

  Future<void> declineFollowRequest(NotificationItem item) async {
    if (item.followRequestId == null) return;

    loadingActions.add(item.id);
    loadingActions.refresh();

    try {
      final response = await Get.find<ApiClient>().post(
        ApiUrl.declineFollowRequest(item.followRequestId!),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = notifications.indexWhere((n) => n.id == item.id);
        if (index != -1) {
          notifications[index].actionStatus = 'declined';
          notifications[index].isUnread = false;
          notifications.refresh();
        }
        ToastMessage.showToast(message: StaticString.requestDeclined.tr);
      } else {
        ApiCheck.checkApi(response);
      }
    } catch (e) {
      ToastMessage.showToast(message: 'Connection error: $e');
    } finally {
      loadingActions.remove(item.id);
      loadingActions.refresh();
    }
  }
}
