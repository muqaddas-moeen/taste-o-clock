enum NotificationType {
  general,
  orderStatus,
  promotion;

  String get firestoreValue => switch (this) {
        NotificationType.general => 'general',
        NotificationType.orderStatus => 'order_status',
        NotificationType.promotion => 'promotion',
      };

  String get label => switch (this) {
        NotificationType.general => 'General',
        NotificationType.orderStatus => 'Order Update',
        NotificationType.promotion => 'Promotion',
      };

  static NotificationType fromFirestore(String? value) {
    return switch (value) {
      'order_status' => NotificationType.orderStatus,
      'promotion' => NotificationType.promotion,
      _ => NotificationType.general,
    };
  }
}
