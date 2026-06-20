import 'package:hive/hive.dart';
import 'package:taste_o_clock/app/core/config/hive_boxes.dart';
import 'package:taste_o_clock/app/data/models/notification_hive_model.dart';
import 'package:taste_o_clock/app/data/models/notification_model.dart';
import 'package:taste_o_clock/app/data/services/storage_service.dart';

/// Hive read/write for cached notifications.
class NotificationCacheService {
  NotificationCacheService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  final StorageService _storageService;

  Box<dynamic> get _box => _storageService.notificationsCacheBox;

  Future<List<NotificationModel>> readForUser(String userId) async {
    final rawIds = _box.get(HiveKeys.cachedNotificationIds);
    final ids = rawIds is List
        ? rawIds.map((id) => id.toString()).toList()
        : <String>[];

    final items = <NotificationModel>[];
    for (final id in ids) {
      final raw = _box.get(HiveKeys.notificationKey(id));
      if (raw is! Map) continue;

      try {
        final model = NotificationHiveModel.fromMap(
          Map<dynamic, dynamic>.from(raw),
        ).toNotification();
        if (model.userId == userId) {
          items.add(model);
        }
      } catch (_) {
        continue;
      }
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  Future<void> writeForUser(
    String userId,
    List<NotificationModel> notifications,
  ) async {
    final userNotifications =
        notifications.where((item) => item.userId == userId).toList();
    final ids = userNotifications.map((item) => item.id).toList();

    for (final notification in userNotifications) {
      await _box.put(
        HiveKeys.notificationKey(notification.id),
        NotificationHiveModel.fromNotification(notification).toMap(),
      );
    }

    final existingRaw = _box.get(HiveKeys.cachedNotificationIds);
    final existingIds = existingRaw is List
        ? existingRaw.map((id) => id.toString()).toList()
        : <String>[];
    for (final oldId in existingIds) {
      if (!ids.contains(oldId)) {
        final map = _box.get(HiveKeys.notificationKey(oldId));
        if (map is Map && map['userId'] == userId) {
          await _box.delete(HiveKeys.notificationKey(oldId));
        }
      }
    }

    final mergedIds = {
      ...existingIds.where((id) {
        final map = _box.get(HiveKeys.notificationKey(id));
        return map is Map && map['userId'] != userId;
      }),
      ...ids,
    }.toList();

    await _box.put(HiveKeys.cachedNotificationIds, mergedIds);
  }

  Future<void> upsert(NotificationModel notification) async {
    await _box.put(
      HiveKeys.notificationKey(notification.id),
      NotificationHiveModel.fromNotification(notification).toMap(),
    );

    final rawIds = _box.get(HiveKeys.cachedNotificationIds);
    final ids = rawIds is List
        ? rawIds.map((id) => id.toString()).toList()
        : <String>[];
    if (!ids.contains(notification.id)) {
      await _box.put(HiveKeys.cachedNotificationIds, [...ids, notification.id]);
    }
  }

  Future<void> clearForUser(String userId) async {
    final rawIds = _box.get(HiveKeys.cachedNotificationIds);
    final ids = rawIds is List
        ? rawIds.map((id) => id.toString()).toList()
        : <String>[];
    final remainingIds = <String>[];

    for (final id in ids) {
      final map = _box.get(HiveKeys.notificationKey(id));
      if (map is Map && map['userId']?.toString() == userId) {
        await _box.delete(HiveKeys.notificationKey(id));
      } else {
        remainingIds.add(id);
      }
    }

    await _box.put(HiveKeys.cachedNotificationIds, remainingIds);
  }
}
