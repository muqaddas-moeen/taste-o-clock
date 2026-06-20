import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/data/models/order_model.dart';
import 'package:taste_o_clock/app/data/models/order_page_result.dart';
import 'package:taste_o_clock/app/data/models/user_location_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';

abstract class OrderRepository {
  Future<Result<OrderModel>> placeOrder({
    required String userId,
    required List<CartItemModel> items,
    required UserLocationModel deliveryLocation,
    required UserPaymentInfoModel paymentInfo,
    required String paymentStatus,
  });

  Future<Result<OrderPageResult>> fetchOrders({
    required String userId,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  });

  Future<Result<OrderModel>> getOrderById({
    required String userId,
    required String orderId,
  });

  Stream<Result<OrderModel>> watchOrder({
    required String userId,
    required String orderId,
  });

  Stream<Result<List<OrderModel>>> watchRecentOrders({
    required String userId,
  });
}
