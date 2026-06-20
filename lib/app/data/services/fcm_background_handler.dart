import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taste_o_clock/app/data/services/local_notification_service.dart';
import 'package:taste_o_clock/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.instance.initialize();

  final notification = message.notification;
  final title = notification?.title ?? message.data['title'] ?? 'Order Update';
  final body = notification?.body ??
      message.data['body'] ??
      message.data['message'] ??
      '';

  if (body.isEmpty) return;

  await LocalNotificationService.instance.showNotification(
    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    title: title,
    body: body,
  );
}
