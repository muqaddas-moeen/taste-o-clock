import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/config/firebase_collections.dart';
import 'package:taste_o_clock/app/core/enums/notification_type.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.orderId,
  });

  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? orderId;

  NotificationModel copyWith({
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    String? orderId,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
      orderId: orderId ?? this.orderId,
    );
  }

  static NotificationModel? tryFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) return null;

    final title = data[NotificationFields.title] as String? ?? '';
    if (title.isEmpty) return null;

    return NotificationModel(
      id: doc.id,
      userId: data[NotificationFields.userId] as String? ?? '',
      title: title,
      body: data[NotificationFields.body] as String? ?? '',
      type: NotificationType.fromFirestore(
        data[NotificationFields.type] as String?,
      ),
      isRead: data[NotificationFields.isRead] as bool? ?? false,
      createdAt: _readTimestamp(data[NotificationFields.createdAt]) ??
          DateTime.now(),
      orderId: data[NotificationFields.orderId] as String?,
    );
  }

  static NotificationModel fromMessageData({
    required String id,
    required String userId,
    required Map<String, dynamic> data,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: data['title'] as String? ?? 'Notification',
      body: data['body'] as String? ?? '',
      type: NotificationType.fromFirestore(data['type'] as String?),
      isRead: false,
      createdAt: DateTime.now(),
      orderId: data['orderId'] as String?,
    );
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
