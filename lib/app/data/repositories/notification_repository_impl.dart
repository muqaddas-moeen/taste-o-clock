import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/notification_model.dart';
import 'package:taste_o_clock/app/data/models/notification_page_result.dart';
import 'package:taste_o_clock/app/data/repositories/notification_repository.dart';
import 'package:taste_o_clock/app/data/services/notification_cache_service.dart';
import 'package:taste_o_clock/app/data/services/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl({
    required NotificationService notificationService,
    required NotificationCacheService notificationCacheService,
  })  : _notificationService = notificationService,
        _notificationCacheService = notificationCacheService;

  final NotificationService _notificationService;
  final NotificationCacheService _notificationCacheService;

  @override
  Future<Result<void>> initializeLocalNotifications() async {
    try {
      await _notificationService.initialize();
      return const Success(null);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'notification_init_error',
          message: 'Unable to initialize notifications.',
        ),
      );
    }
  }

  @override
  Future<Result<List<NotificationModel>>> loadLocalNotifications({
    required String userId,
  }) async {
    if (userId.isEmpty) {
      return const Error(
        AppFailure(
          code: 'missing_user',
          message: 'You must be signed in to load notifications.',
        ),
      );
    }

    try {
      final items = await _notificationCacheService.readForUser(userId);
      return Success(items);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'notifications_load_error',
          message: 'Unable to load notifications.',
        ),
      );
    }
  }

  @override
  Future<Result<NotificationPageResult>> fetchNotifications({
    required String userId,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    final result = await loadLocalNotifications(userId: userId);
    return result.when(
      onSuccess: (items) => Success(
        NotificationPageResult(
          notifications: items,
          lastDocument: null,
          hasMore: false,
        ),
      ),
      onFailure: (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void>> saveLocalNotification({
    required String userId,
    required NotificationModel notification,
  }) async {
    try {
      await _notificationCacheService.upsert(notification);
      return const Success(null);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'notification_save_error',
          message: 'Unable to save notification.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    try {
      final cached = await _notificationCacheService.readForUser(userId);
      final updated = cached
          .map(
            (item) => item.id == notificationId
                ? item.copyWith(isRead: true)
                : item,
          )
          .toList();
      await _notificationCacheService.writeForUser(userId, updated);
      return const Success(null);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'notification_read_error',
          message: 'Unable to mark notification as read.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> deleteNotification({
    required String userId,
    required String notificationId,
  }) async {
    try {
      final cached = await _notificationCacheService.readForUser(userId);
      await _notificationCacheService.writeForUser(
        userId,
        cached.where((item) => item.id != notificationId).toList(),
      );
      return const Success(null);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'notification_delete_error',
          message: 'Unable to delete notification.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> showSystemNotification({
    required String title,
    required String body,
  }) async {
    try {
      await _notificationService.showSystemNotification(
        title: title,
        body: body,
      );
      return const Success(null);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'local_notification_error',
          message: 'Unable to display notification.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> clearLocalNotifications(String userId) async {
    try {
      await _notificationCacheService.clearForUser(userId);
      return const Success(null);
    } catch (_) {
      return const Success(null);
    }
  }

  @override
  int unreadCount(List<NotificationModel> notifications) {
    return notifications.where((item) => !item.isRead).length;
  }
}
