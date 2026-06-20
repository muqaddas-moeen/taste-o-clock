import 'package:hive_flutter/hive_flutter.dart';
import 'package:taste_o_clock/app/core/config/hive_boxes.dart';

class StorageService {
  StorageService();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox(HiveBoxes.cart),
      Hive.openBox(HiveBoxes.productsCache),
      Hive.openBox(HiveBoxes.recentlyViewed),
      Hive.openBox(HiveBoxes.notificationsCache),
      Hive.openBox(HiveBoxes.session),
    ]);

    _initialized = true;
  }

  Box<dynamic> box(String name) {
    if (!_initialized) {
      throw StateError('StorageService.init() must be called before accessing boxes.');
    }
    return Hive.box(name);
  }

  Box<dynamic> get sessionBox => box(HiveBoxes.session);
  Box<dynamic> get cartBox => box(HiveBoxes.cart);
  Box<dynamic> get productsCacheBox => box(HiveBoxes.productsCache);
  Box<dynamic> get recentlyViewedBox => box(HiveBoxes.recentlyViewed);
  Box<dynamic> get notificationsCacheBox => box(HiveBoxes.notificationsCache);
}
