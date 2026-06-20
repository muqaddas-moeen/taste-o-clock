enum OrderStatus {
  placed,
  preparing,
  onTheWay,
  delivered;

  String get firestoreValue => switch (this) {
        OrderStatus.placed => 'placed',
        OrderStatus.preparing => 'preparing',
        OrderStatus.onTheWay => 'on_the_way',
        OrderStatus.delivered => 'delivered',
      };

  String get label => switch (this) {
        OrderStatus.placed => 'Order Placed',
        OrderStatus.preparing => 'Preparing',
        OrderStatus.onTheWay => 'On the Way',
        OrderStatus.delivered => 'Delivered',
      };

  int get stepIndex => switch (this) {
        OrderStatus.placed => 0,
        OrderStatus.preparing => 1,
        OrderStatus.onTheWay => 2,
        OrderStatus.delivered => 3,
      };

  static OrderStatus? fromFirestore(String? value) {
    return switch (value) {
      'placed' => OrderStatus.placed,
      'preparing' => OrderStatus.preparing,
      'on_the_way' => OrderStatus.onTheWay,
      'delivered' => OrderStatus.delivered,
      _ => null,
    };
  }
}
