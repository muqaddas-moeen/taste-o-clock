import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/data/models/notification_model.dart';

class NotificationPageResult {
  const NotificationPageResult({
    required this.notifications,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<NotificationModel> notifications;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}
