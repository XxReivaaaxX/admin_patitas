import 'package:admin_patitas/models/notifications.dart';

class NotificationsShow {
  final Notifications notifications;
  final bool isRead;

  NotificationsShow({required this.notifications, required this.isRead});

  factory NotificationsShow.fromFirebase(
    Notifications notif,
    Map<dynamic, dynamic> userStatusMap,
  ) {
    return NotificationsShow(
      notifications: notif,
      isRead: userStatusMap['isRead'] ?? false,
    );
  }
}
