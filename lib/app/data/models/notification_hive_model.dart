import 'package:taste_o_clock/app/core/enums/notification_type.dart';
import 'package:taste_o_clock/app/data/models/notification_model.dart';

class NotificationHiveModel {
  const NotificationHiveModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAtMillis,
    this.orderId,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final int createdAtMillis;
  final String? orderId;

  factory NotificationHiveModel.fromNotification(NotificationModel notification) {
    return NotificationHiveModel(
      id: notification.id,
      userId: notification.userId,
      title: notification.title,
      body: notification.body,
      type: notification.type.firestoreValue,
      isRead: notification.isRead,
      createdAtMillis: notification.createdAt.millisecondsSinceEpoch,
      orderId: notification.orderId,
    );
  }

  factory NotificationHiveModel.fromMap(Map<dynamic, dynamic> map) {
    return NotificationHiveModel(
      id: map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      type: map['type']?.toString() ??
          NotificationType.general.firestoreValue,
      isRead: _readBool(map['isRead']),
      createdAtMillis: _readMillis(map['createdAtMillis']),
      orderId: map['orderId']?.toString(),
    );
  }

  static bool _readBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    return false;
  }

  static int _readMillis(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'isRead': isRead,
      'createdAtMillis': createdAtMillis,
      'orderId': orderId,
    };
  }

  NotificationModel toNotification() {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.fromFirestore(type),
      isRead: isRead,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      orderId: orderId,
    );
  }
}
