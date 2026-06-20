import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:get/get.dart';

import 'package:taste_o_clock/app/core/enums/notification_type.dart';

import 'package:taste_o_clock/app/core/utils/app_log.dart';

import 'package:taste_o_clock/app/core/utils/input_validators.dart';

import 'package:taste_o_clock/app/data/models/notification_model.dart';

import 'package:taste_o_clock/app/data/repositories/user_repository.dart';

import 'package:taste_o_clock/app/data/services/local_notification_service.dart';

import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';

import 'package:taste_o_clock/app/modules/notification/controllers/notification_controller.dart';



/// FCM token + foreground/background push handling.

class PushNotificationService {

  PushNotificationService._();



  static final PushNotificationService instance = PushNotificationService._();



  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  bool _initialized = false;



  Future<void> initialize() async {

    if (_initialized) return;



    await _messaging.setForegroundNotificationPresentationOptions(

      alert: true,

      badge: true,

      sound: true,

    );



    await _messaging.requestPermission(

      alert: true,

      badge: true,

      sound: true,

    );



    await LocalNotificationService.instance.ensureNotificationsEnabled();



    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.instance.onTokenRefresh.listen((_) => syncFcmToken());



    _initialized = true;

    await syncFcmToken();

  }



  Future<void> syncFcmToken() async {

    try {

      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {

        AppLog.d('[FCM] Token unavailable. Check Google Play Services / network.');

        return;

      }



      if (!Get.isRegistered<AuthController>() ||

          !Get.isRegistered<UserRepository>()) {

        AppLog.d('[FCM] FCM ready');

        return;

      }



      final userId = Get.find<AuthController>().user.value?.id;

      if (userId == null) {

        AppLog.d('[FCM] FCM ready');

        return;

      }



      final result = await Get.find<UserRepository>().syncFcmToken(

        userId: userId,

        token: token,

      );



      result.when(

        onSuccess: (_) => AppLog.d('[FCM] Token synced to profile'),

        onFailure: (failure) =>

            AppLog.d('[FCM] Token sync failed: ${failure.message}'),

      );

    } catch (error, stackTrace) {

      AppLog.d('[FCM] Failed to get token: $error');

      AppLog.d('$stackTrace');

    }

  }



  Future<void> _handleForegroundMessage(RemoteMessage message) async {

    final notification = message.notification;

    final title = InputValidators.sanitizeText(

      notification?.title ?? message.data['title'] ?? 'Order Update',

      maxLength: 120,

    );

    final body = InputValidators.sanitizeText(

      notification?.body ??

          message.data['body'] ??

          message.data['message'] ??

          'You have a new update.',

      maxLength: 240,

    );



    AppLog.d('[FCM] Foreground message received');



    await LocalNotificationService.instance.showNotification(

      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),

      title: title,

      body: body,

    );



    await _persistMessage(message, title: title, body: body);

  }



  Future<void> _persistMessage(

    RemoteMessage message, {

    required String title,

    required String body,

  }) async {

    if (!Get.isRegistered<AuthController>() ||

        !Get.isRegistered<NotificationController>()) {

      return;

    }



    final authUser = Get.find<AuthController>().user.value;

    if (authUser == null) return;



    final data = message.data;

    final userId = data['userId'] as String? ?? authUser.id;

    if (userId != authUser.id) return;



    final orderId = data['orderId'] as String?;

    final type = NotificationType.fromFirestore(data['type'] as String?);

    final messageId = message.messageId;

    final id = messageId != null && messageId.isNotEmpty

        ? 'fcm_$messageId'

        : 'fcm_${DateTime.now().millisecondsSinceEpoch}';



    final notification = NotificationModel(

      id: id,

      userId: userId,

      title: title,

      body: body,

      type: type,

      isRead: false,

      createdAt: DateTime.now(),

      orderId: orderId,

    );



    await Get.find<NotificationController>()

        .persistIncomingNotification(notification);

  }

}


