import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/notification_model.dart';
import 'package:taste_o_clock/app/data/models/notification_page_result.dart';

abstract class NotificationRepository {
  Future<Result<void>> initializeLocalNotifications();

  Future<Result<List<NotificationModel>>> loadLocalNotifications({
    required String userId,
  });

  Future<Result<NotificationPageResult>> fetchNotifications({
    required String userId,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  });

  Future<Result<void>> saveLocalNotification({
    required String userId,
    required NotificationModel notification,
  });

  Future<Result<void>> markAsRead({
    required String userId,
    required String notificationId,
  });

  Future<Result<void>> deleteNotification({
    required String userId,
    required String notificationId,
  });

  Future<Result<void>> showSystemNotification({
    required String title,
    required String body,
  });

  Future<Result<void>> clearLocalNotifications(String userId);

  int unreadCount(List<NotificationModel> notifications);
}
