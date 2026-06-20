import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/utils/app_log.dart';
import 'package:taste_o_clock/app/core/controllers/base_controller.dart';
import 'package:taste_o_clock/app/core/enums/notification_type.dart';
import 'package:taste_o_clock/app/core/enums/order_status.dart';
import 'package:taste_o_clock/app/data/models/notification_model.dart';
import 'package:taste_o_clock/app/data/models/order_model.dart';
import 'package:taste_o_clock/app/data/repositories/notification_repository.dart';
import 'package:taste_o_clock/app/data/repositories/order_repository.dart';
import 'package:taste_o_clock/app/data/services/push_notification_service.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';

class NotificationController extends BaseController {
  NotificationController({
    NotificationRepository? notificationRepository,
    OrderRepository? orderRepository,
    AuthController? authController,
  })  : _notificationRepository =
            notificationRepository ?? Get.find<NotificationRepository>(),
        _orderRepository = orderRepository ?? Get.find<OrderRepository>(),
        _authController = authController ?? Get.find<AuthController>();

  final NotificationRepository _notificationRepository;
  final OrderRepository _orderRepository;
  final AuthController _authController;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  String? _boundUserId;
  bool _initialized = false;

  @override
  void onInit() {
    super.onInit();
    _initializeLocalNotifications();

    ever(_authController.user, (user) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (user != null) {
          _bindUser(user.id);
        } else {
          _clearUser();
        }
      });
    });

    final currentUser = _authController.user.value;
    if (currentUser != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        _bindUser(currentUser.id);
      });
    }
  }

  Future<void> refreshNotifications() async {
    final userId = _resolveUserId();
    if (userId == null) return;

    _boundUserId ??= userId;

    final result = await _notificationRepository.loadLocalNotifications(
      userId: userId,
    );

    result.when(
      onSuccess: _applyNotifications,
      onFailure: handleFailure,
    );
  }

  Future<void> notifyOrderStatusChange({
    required OrderModel order,
    required OrderStatus previousStatus,
  }) async {
    if (order.status == previousStatus) return;

    final userId = _resolveUserId();
    if (userId == null) return;

    final shortId = order.id.length > 8 ? order.id.substring(0, 8) : order.id;
    const title = 'Order Update';
    final body = 'Your order is now: ${order.status.label} (#$shortId)';

    AppLog.d('[Notification] Showing local alert: $title — $body');

    final notification = NotificationModel(
      id: 'order_${order.id}_${order.status.firestoreValue}',
      userId: userId,
      title: title,
      body: body,
      type: NotificationType.orderStatus,
      isRead: false,
      createdAt: DateTime.now(),
      orderId: order.id,
    );

    final saveResult = await _notificationRepository.saveLocalNotification(
      userId: userId,
      notification: notification,
    );
    saveResult.when(
      onSuccess: (_) => _upsertInMemory(notification),
      onFailure: handleFailure,
    );
    await _notificationRepository.showSystemNotification(
      title: title,
      body: body,
    );
    await refreshNotifications();
  }

  Future<void> persistIncomingNotification(NotificationModel notification) async {
    final userId = _resolveUserId();
    if (userId == null || notification.userId != userId) return;

    final saveResult = await _notificationRepository.saveLocalNotification(
      userId: userId,
      notification: notification,
    );
    saveResult.when(
      onSuccess: (_) {
        _upsertInMemory(notification);
        _updateUnreadCount();
      },
      onFailure: (_) {},
    );
  }

  Future<void> clearPersistedOnSignOut(String userId) async {
    await _notificationRepository.clearLocalNotifications(userId);
    notifications.clear();
    unreadCount.value = 0;
    _boundUserId = null;
  }

  Future<void> markAllAsRead() async {
    final userId = _resolveUserId();
    if (userId == null || notifications.isEmpty) return;

    _boundUserId ??= userId;

    for (final notification in notifications.where((item) => !item.isRead)) {
      await markAsRead(notification.id);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = _resolveUserId();
    if (userId == null) return;

    _boundUserId ??= userId;

    final result = await _notificationRepository.markAsRead(
      userId: userId,
      notificationId: notificationId,
    );

    result.when(
      onSuccess: (_) {
        final index =
            notifications.indexWhere((item) => item.id == notificationId);
        if (index >= 0) {
          notifications[index] = notifications[index].copyWith(isRead: true);
          notifications.refresh();
          _updateUnreadCount();
        }
      },
      onFailure: handleFailure,
    );
  }

  Future<void> deleteNotification(String notificationId) async {
    final userId = _resolveUserId();
    if (userId == null) return;

    _boundUserId ??= userId;

    final result = await _notificationRepository.deleteNotification(
      userId: userId,
      notificationId: notificationId,
    );

    result.when(
      onSuccess: (_) {
        notifications.removeWhere((item) => item.id == notificationId);
        _updateUnreadCount();
      },
      onFailure: handleFailure,
    );
  }

  Future<void> openNotification(NotificationModel notification) async {
    if (!notification.isRead) {
      await markAsRead(notification.id);
    }

    if (notification.orderId != null && notification.orderId!.isNotEmpty) {
      await _openOrderTracking(notification.orderId!);
      return;
    }

    openNotifications();
  }

  void openNotifications() {
    Get.toNamed(AppRoutes.notifications);
  }

  Future<void> _initializeLocalNotifications() async {
    if (_initialized) return;

    final result = await _notificationRepository.initializeLocalNotifications();
    result.when(
      onSuccess: (_) => _initialized = true,
      onFailure: (_) {},
    );
  }

  Future<void> _bindUser(String userId) async {
    _boundUserId = userId;
    await PushNotificationService.instance.syncFcmToken();
    await refreshNotifications();
  }

  void _clearUser() {
    _boundUserId = null;
    notifications.clear();
    unreadCount.value = 0;
  }

  String? _resolveUserId() => _boundUserId ?? _authController.user.value?.id;

  void _upsertInMemory(NotificationModel notification) {
    final index =
        notifications.indexWhere((item) => item.id == notification.id);
    if (index >= 0) {
      notifications[index] = notification;
    } else {
      notifications.insert(0, notification);
    }
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _updateUnreadCount();
  }

  Future<void> _openOrderTracking(String orderId) async {
    final userId = _resolveUserId();
    if (userId == null) return;

    final result = await _orderRepository.getOrderById(
      userId: userId,
      orderId: orderId,
    );

    result.when(
      onSuccess: (order) {
        Get.toNamed(AppRoutes.orderTracking, arguments: order);
      },
      onFailure: (_) => Get.toNamed(AppRoutes.orders),
    );
  }

  void _applyNotifications(List<NotificationModel> items) {
    notifications.assignAll(items);
    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = _notificationRepository.unreadCount(notifications);
  }
}
