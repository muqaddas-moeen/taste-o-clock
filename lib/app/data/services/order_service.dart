import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/config/app_config.dart';
import 'package:taste_o_clock/app/core/config/firebase_collections.dart';
import 'package:taste_o_clock/app/core/errors/app_exception.dart';
import 'package:taste_o_clock/app/data/models/order_model.dart';
import 'package:taste_o_clock/app/data/models/order_page_result.dart';
import 'package:taste_o_clock/app/data/services/firebase_service.dart';

class OrderService {
  OrderService({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  final FirebaseService _firebaseService;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firebaseService.collection(FirebaseCollections.orders);

  Future<OrderModel> createOrder(OrderModel draft) async {
    try {
      final now = DateTime.now();
      final docRef = _orders.doc();
      final payload = draft.toFirestore(now: now);

      await docRef.set(payload);

      final created = OrderModel.tryFromFirestore(await docRef.get());
      if (created == null) {
        throw AppException(
          code: 'order_create_error',
          message: 'Order was created but could not be read back.',
        );
      }

      return created;
    } on FirebaseException catch (e) {
      throw AppException(
        code: e.code,
        message: _mapFirebaseMessage(e),
        cause: e,
      );
    }
  }

  Future<OrderPageResult> fetchUserOrders({
    required String userId,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
    int limit = AppConfig.defaultPageSize,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _orders
          .where(OrderFields.userId, isEqualTo: userId)
          .orderBy(OrderFields.createdAt, descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      final orders = snapshot.docs
          .map(OrderModel.tryFromFirestore)
          .whereType<OrderModel>()
          .toList();

      return OrderPageResult(
        orders: orders,
        lastDocument: snapshot.docs.isEmpty ? null : snapshot.docs.last,
        hasMore: snapshot.docs.length == limit,
      );
    } on FirebaseException catch (e) {
      throw AppException(
        code: e.code,
        message: _mapFirebaseMessage(e),
        cause: e,
      );
    }
  }

  Future<OrderModel?> fetchOrderById(String orderId) async {
    try {
      final doc = await _orders.doc(orderId).get();
      if (!doc.exists) return null;
      return OrderModel.tryFromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AppException(
        code: e.code,
        message: _mapFirebaseMessage(e),
        cause: e,
      );
    }
  }

  Stream<OrderModel?> watchOrder(String orderId) {
    return _orders.doc(orderId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return OrderModel.tryFromFirestore(doc);
    });
  }

  Stream<List<OrderModel>> watchRecentUserOrders({
    required String userId,
    int limit = AppConfig.defaultPageSize,
  }) {
    return _orders
        .where(OrderFields.userId, isEqualTo: userId)
        .orderBy(OrderFields.createdAt, descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(OrderModel.tryFromFirestore)
              .whereType<OrderModel>()
              .toList(),
        );
  }

  String _mapFirebaseMessage(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' =>
        'You do not have permission to access this order.',
      'unavailable' => 'Firestore is temporarily unavailable. Try again shortly.',
      'failed-precondition' =>
        'Orders are still syncing on the server. Pull to refresh in a moment.',
      _ => e.message ?? 'Failed to access orders in Firestore.',
    };
  }
}
