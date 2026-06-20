/// Firestore collection and field name constants.
class FirebaseCollections {
  FirebaseCollections._();

  static const String users = 'users';
  static const String products = 'products';
  static const String categories = 'categories';
  static const String orders = 'orders';
  static const String notifications = 'notifications';
}

class FirebaseFields {
  FirebaseFields._();

  static const String email = 'email';
  static const String displayName = 'displayName';
  static const String photoUrl = 'photoUrl';
  static const String lastLoginAt = 'lastLoginAt';
  static const String authProvider = 'authProvider';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String userId = 'userId';
  static const String status = 'status';
}

class OrderFields {
  OrderFields._();

  static const String userId = 'userId';
  static const String status = 'status';
  static const String items = 'items';
  static const String subtotal = 'subtotal';
  static const String totalItems = 'totalItems';
  static const String createdAt = 'createdAt';
  static const String updatedAt = 'updatedAt';
  static const String deliveryAddress = 'deliveryAddress';
  static const String paymentMethod = 'paymentMethod';
  static const String paymentStatus = 'paymentStatus';
  static const String productId = 'productId';
  static const String name = 'name';
  static const String unitPrice = 'unitPrice';
  static const String quantity = 'quantity';
  static const String imageUrl = 'imageUrl';
}

class NotificationFields {
  NotificationFields._();

  static const String userId = 'userId';
  static const String title = 'title';
  static const String body = 'body';
  static const String type = 'type';
  static const String orderId = 'orderId';
  static const String isRead = 'isRead';
  static const String createdAt = 'createdAt';
  static const String fcmToken = 'fcmToken';
  static const String fcmTokenUpdatedAt = 'fcmTokenUpdatedAt';
}

class UserFields {
  UserFields._();

  static const String phone = 'phone';
  static const String location = 'location';
  static const String paymentInfo = 'paymentInfo';
}
