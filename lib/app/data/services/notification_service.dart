import 'package:taste_o_clock/app/data/services/local_notification_service.dart';

/// Local system notification access.
class NotificationService {
  NotificationService();

  Future<void> initialize() async {
    await LocalNotificationService.instance.initialize();
  }

  Future<void> showSystemNotification({
    required String title,
    required String body,
  }) async {
    await LocalNotificationService.instance.showNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
    );
  }
}
