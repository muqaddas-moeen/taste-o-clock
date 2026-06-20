import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/data/models/order_model.dart';

class OrderPageResult {
  const OrderPageResult({
    required this.orders,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<OrderModel> orders;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}
