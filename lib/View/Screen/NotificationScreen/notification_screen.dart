import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/StaticString/static_string.dart';
import '../../../helper/network_img/network_img.dart';
import '../../Widgegt/ShimmerLoading/shimmer_loading.dart';
import '../HomeScreen/Controller/home_controller.dart';
import 'Controller/notification_controller.dart';


class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late final NotificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(NotificationController());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textLight,
              size: 20,
            ),
            onPressed: () {
              if (Get.isRegistered<HomeController>() &&
                  Get.find<HomeController>().selectedIndex.value != 0) {
                Get.find<HomeController>().changeIndex(0);
              } else {
                Get.back();
              }
            },
          ),
          centerTitle: true,
          title: Text(
            StaticString.notifications.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: AppColors.textLight,
              ),
              color: Colors.white,
              surfaceTintColor: Colors.white,
              onSelected: (value) {
                if (value == 'mark_all_read') {
                  controller.markAllAsRead();
                } else if (value == 'clear_all') {
                  controller.clearAll();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'mark_all_read',
                  child: Text(
                    'Mark all as read',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'clear_all',
                  child: Text(
                    'Clear all',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            indicatorColor: const Color(0xFF1877F2),
            labelColor: const Color(0xFF1877F2),
            unselectedLabelColor: const Color(0xFF65676B),
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: const Color(0xFFEEEEEE),
            tabs: [
              Tab(text: StaticString.all.tr),
              Tab(text: StaticString.follows.tr),
              Tab(text: StaticString.mentions.tr),
            ],
          ),
        ),
        body: Obx(() {
          return TabBarView(
            children: [
              _buildNotificationList(controller.notifications),
              _buildNotificationList(
                controller.notifications.where((n) => n.type == NotificationType.followRequest).toList(),
              ),
              _buildNotificationList(
                controller.notifications.where((n) => n.type == NotificationType.comment).toList(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> items) {
    if (controller.isLoading.value) {
      return ListView.separated(
        itemCount: 6,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 0.5,
          color: Color(0xFFEEEEEE),
        ),
        itemBuilder: (context, index) => const NotificationShimmer(),
      );
    }

    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.fetchNotifications,
        color: Colors.blueAccent,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 72,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    StaticString.noNotificationsFound.tr,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchNotifications,
      color: Colors.blueAccent,
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 0.5,
          color: Color(0xFFEEEEEE),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildNotificationTile(item);
        },
      ),
    );
  }

  String _getLocalizedMessage(String msg) {
    if (msg == 'liked your comment') return StaticString.likedYourComment.tr;
    if (msg == 'sent request to follow') return StaticString.sentRequestToFollow.tr;
    if (msg == 'replied to your comment') return StaticString.repliedToYourComment.tr;
    return msg;
  }

  Widget _buildNotificationTile(NotificationItem item) {
    final isLoading = controller.loadingActions.contains(item.id);
    // Unread background color tint
    final tileBgColor = item.isUnread ? const Color(0xFFF4F8FC) : Colors.white;

    return InkWell(
      onTap: () {
        if (item.isUnread) {
          controller.markAsRead(item.id);
        }
      },
      child: Container(
        color: tileBgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with Overlay Badge
            Stack(
              children: [
                NetworkImg(
                  imageUrl: item.avatarUrl,
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(24),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: _buildBadge(item.type),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // Content Area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textLight,
                        height: 1.3,
                      ),
                      children: [
                        TextSpan(
                          text: item.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(text: _getLocalizedMessage(item.message)),
                      ],
                    ),
                  ),
                  
                  // If it's a follow request and no action has been taken yet
                  if (item.type == NotificationType.followRequest && item.actionStatus == null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: isLoading ? null : () => controller.acceptFollowRequest(item),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1877F2),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            minimumSize: const Size(80, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  StaticString.accept.tr,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: isLoading ? null : () => controller.declineFollowRequest(item),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF65676B),
                            side: const BorderSide(color: Color(0xFFDCDFE4), width: 1),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            minimumSize: const Size(80, 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF65676B),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  StaticString.decline.tr,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
                    ),
                  ] else if (item.actionStatus != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      item.actionStatus == 'accepted' 
                          ? StaticString.requestAcceptedStatus.tr 
                          : StaticString.requestDeclinedStatus.tr,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: item.actionStatus == 'accepted' ? Colors.green[700] : Colors.grey[600],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(NotificationType type) {
    IconData badgeIcon;
    switch (type) {
      case NotificationType.like:
        badgeIcon = Icons.thumb_up_rounded;
        break;
      case NotificationType.followRequest:
        badgeIcon = Icons.person_add_alt_1_rounded;
        break;
      case NotificationType.comment:
        badgeIcon = Icons.chat_bubble_rounded;
        break;
    }

    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: const Color(0xFF1877F2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Center(
        child: Icon(
          badgeIcon,
          color: Colors.white,
          size: 10,
        ),
      ),
    );
  }
}
