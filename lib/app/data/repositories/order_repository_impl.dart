import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/enums/order_status.dart';
import 'package:taste_o_clock/app/core/errors/app_exception.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/data/models/order_item_model.dart';
import 'package:taste_o_clock/app/data/models/order_model.dart';
import 'package:taste_o_clock/app/data/models/order_page_result.dart';
import 'package:taste_o_clock/app/data/models/user_location_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';
import 'package:taste_o_clock/app/core/utils/order_validators.dart';
import 'package:taste_o_clock/app/data/repositories/order_repository.dart';
import 'package:taste_o_clock/app/data/services/order_service.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl({required OrderService orderService})
      : _orderService = orderService;

  final OrderService _orderService;

  @override
  Future<Result<OrderModel>> placeOrder({
    required String userId,
    required List<CartItemModel> items,
    required UserLocationModel deliveryLocation,
    required UserPaymentInfoModel paymentInfo,
    required String paymentStatus,
  }) async {
    if (userId.isEmpty) {
      return const Error(
        AppFailure(
          code: 'missing_user',
          message: 'You must be signed in to place an order.',
        ),
      );
    }

    if (items.isEmpty) {
      return const Error(
        AppFailure(
          code: 'empty_cart',
          message: 'Your cart is empty.',
        ),
      );
    }

    final validation = OrderValidators.validateCartForOrder(
      items: items,
      paymentStatus: paymentStatus,
      paymentMethod: paymentInfo.paymentMethod,
    );
    if (!validation.isSuccess) {
      return Error((validation as Error<void>).failure);
    }

    final summary = CartSummary.fromItems(items);
    final orderItems = items.map(OrderItemModel.fromCartItem).toList();

    final draft = OrderModel(
      id: '',
      userId: userId,
      items: orderItems,
      subtotal: summary.subtotal,
      totalItems: summary.totalItems,
      status: OrderStatus.placed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deliveryAddress: deliveryLocation.toMap(),
      paymentMethod: paymentInfo.paymentMethod.firestoreValue,
      paymentStatus: paymentStatus,
    );

    try {
      final created = await _orderService.createOrder(draft);
      return Success(created);
    } on AppException catch (e) {
      return Error(e.toFailure());
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'order_create_error',
          message: 'Unable to place your order. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Result<OrderPageResult>> fetchOrders({
    required String userId,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    if (userId.isEmpty) {
      return const Error(
        AppFailure(
          code: 'missing_user',
          message: 'You must be signed in to view orders.',
        ),
      );
    }

    try {
      final page = await _orderService.fetchUserOrders(
        userId: userId,
        startAfter: startAfter,
      );
      return Success(page);
    } on AppException catch (e) {
      return Error(e.toFailure());
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'orders_fetch_error',
          message: 'Unable to load orders.',
        ),
      );
    }
  }

  @override
  Future<Result<OrderModel>> getOrderById({
    required String userId,
    required String orderId,
  }) async {
    try {
      final order = await _orderService.fetchOrderById(orderId);
      if (order == null) {
        return const Error(
          AppFailure(
            code: 'order_not_found',
            message: 'Order not found.',
          ),
        );
      }

      if (order.userId != userId) {
        return const Error(
          AppFailure(
            code: 'order_forbidden',
            message: 'You do not have access to this order.',
          ),
        );
      }

      return Success(order);
    } on AppException catch (e) {
      return Error(e.toFailure());
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'order_fetch_error',
          message: 'Unable to load order details.',
        ),
      );
    }
  }

  @override
  Stream<Result<OrderModel>> watchOrder({
    required String userId,
    required String orderId,
  }) {
    if (userId.isEmpty || orderId.isEmpty) {
      return Stream.value(
        const Error(
          AppFailure(
            code: 'missing_order',
            message: 'Order not found.',
          ),
        ),
      );
    }

    return _orderService.watchOrder(orderId).map((order) {
      if (order == null) {
        return const Error(
          AppFailure(
            code: 'order_not_found',
            message: 'Order not found.',
          ),
        );
      }

      if (order.userId != userId) {
        return const Error(
          AppFailure(
            code: 'order_forbidden',
            message: 'You do not have access to this order.',
          ),
        );
      }

      return Success(order);
    });
  }

  @override
  Stream<Result<List<OrderModel>>> watchRecentOrders({
    required String userId,
  }) {
    if (userId.isEmpty) {
      return Stream.value(
        const Error(
          AppFailure(
            code: 'missing_user',
            message: 'You must be signed in to view orders.',
          ),
        ),
      );
    }

    return _orderService.watchRecentUserOrders(userId: userId).map(Success.new);
  }
}
