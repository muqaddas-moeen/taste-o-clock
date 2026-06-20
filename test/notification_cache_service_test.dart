import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:taste_o_clock/app/core/config/hive_boxes.dart';
import 'package:taste_o_clock/app/core/enums/notification_type.dart';
import 'package:taste_o_clock/app/data/models/notification_model.dart';
import 'package:taste_o_clock/app/data/services/notification_cache_service.dart';
import 'package:taste_o_clock/app/data/services/storage_service.dart';

class _TestStorageService extends StorageService {
  @override
  Box<dynamic> box(String name) => Hive.box(name);
}

void main() {
  group('NotificationCacheService', () {
    late Directory tempDir;
    late NotificationCacheService cacheService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('toc_notification_test');
      Hive.init(tempDir.path);
      await Hive.openBox(HiveBoxes.notificationsCache);
      cacheService = NotificationCacheService(
        storageService: _TestStorageService(),
      );
    });

    tearDown(() async {
      await Hive.close();
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('persists and reloads notifications for a user', () async {
      const userId = 'user_123';
      final notification = NotificationModel(
        id: 'order_o1_preparing',
        userId: userId,
        title: 'Order Update',
        body: 'Your order is now: Preparing (#o1)',
        type: NotificationType.orderStatus,
        isRead: false,
        createdAt: DateTime(2026, 6, 20, 12, 30),
        orderId: 'o1',
      );

      await cacheService.upsert(notification);

      final loaded = await cacheService.readForUser(userId);
      expect(loaded, hasLength(1));
      expect(loaded.first.id, notification.id);
      expect(loaded.first.title, notification.title);
      expect(loaded.first.orderId, notification.orderId);
    });

    test('keeps notifications after clearing another user session state', () async {
      const userId = 'user_123';
      final notification = NotificationModel(
        id: 'order_o2_delivered',
        userId: userId,
        title: 'Order Update',
        body: 'Delivered',
        type: NotificationType.orderStatus,
        isRead: false,
        createdAt: DateTime(2026, 6, 20, 13, 0),
        orderId: 'o2',
      );

      await cacheService.upsert(notification);
      await cacheService.clearForUser('other_user');

      final loaded = await cacheService.readForUser(userId);
      expect(loaded, hasLength(1));
      expect(loaded.first.id, notification.id);
    });
  });
}
