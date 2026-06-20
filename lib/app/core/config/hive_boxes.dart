/// Hive box names and storage keys.
class HiveBoxes {
  HiveBoxes._();

  static const String cart = 'cart_box';
  static const String productsCache = 'products_cache_box';
  static const String recentlyViewed = 'recently_viewed_box';
  static const String notificationsCache = 'notifications_cache_box';
  static const String session = 'session_box';
}

class HiveKeys {
  HiveKeys._();

  static const String currentUserId = 'current_user_id';
  static const String cachedProductIds = 'cached_product_ids';
  static const String cachedCategoryNames = 'cached_category_names';
  static const String recentlyViewedIds = 'recently_viewed_ids';

  static const String cartItemIds = 'cart_item_ids';
  static const String cachedNotificationIds = 'cached_notification_ids';

  static String productKey(String productId) => 'product_$productId';
  static String cartItemKey(String productId) => 'cart_item_$productId';
  static String notificationKey(String notificationId) =>
      'notification_$notificationId';
}

