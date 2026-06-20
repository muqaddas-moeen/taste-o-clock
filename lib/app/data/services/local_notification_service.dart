import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taste_o_clock/app/core/utils/app_log.dart';

/// Android notification channel + system tray display.
class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  static const String channelId = 'taste_o_clock_updates';
  static const String channelName = 'Order Updates';
  static const String notificationIcon = '@drawable/ic_notification';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  AndroidFlutterLocalNotificationsPlugin? get _androidPlugin =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings(notificationIcon);
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (_) {},
    );

    const channel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: 'Order status and delivery alerts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _androidPlugin?.createNotificationChannel(channel);
    await ensureNotificationsEnabled();

    _initialized = true;
    AppLog.d('[Notifications] Local notifications initialized.');
  }

  /// Request POST_NOTIFICATIONS on Android 13+ before showing alerts.
  Future<bool> ensureNotificationsEnabled() async {
    final android = _androidPlugin;
    if (android == null) return true;

    try {
      final enabled = await android.areNotificationsEnabled();
      if (enabled == true) {
        AppLog.d('[Notifications] Permission already granted.');
        return true;
      }

      final granted = await android.requestNotificationsPermission();
      final isGranted = granted == true;
      AppLog.d(
        '[Notifications] Permission request result: ${isGranted ? 'granted' : 'denied'}',
      );
      return isGranted;
    } catch (error) {
      AppLog.d('[Notifications] Permission check failed: $error');
      return false;
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final permitted = await ensureNotificationsEnabled();
    if (!permitted) {
      AppLog.d('[Notifications] Skipped — notification permission denied.');
      return;
    }

    const details = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: 'Order status and delivery alerts',
      importance: Importance.max,
      priority: Priority.high,
      icon: notificationIcon,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
      ticker: 'Order Update',
    );

    try {
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(android: details),
      );
      AppLog.d('[Notifications] Shown: $title — $body');
    } catch (error) {
      AppLog.d('[Notifications] Failed to show: $error');
    }
  }
}
