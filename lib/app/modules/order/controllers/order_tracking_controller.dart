import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/controllers/base_controller.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/order_model.dart';
import 'package:taste_o_clock/app/data/repositories/order_repository.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';

class OrderTrackingController extends BaseController {
  static const trackingUiId = 'tracking';

  OrderTrackingController({
    OrderRepository? orderRepository,
    AuthController? authController,
  })  : _orderRepository = orderRepository ?? Get.find<OrderRepository>(),
        _authController = authController ?? Get.find<AuthController>();

  final OrderRepository _orderRepository;
  final AuthController _authController;

  final Rxn<OrderModel> order = Rxn<OrderModel>();

  StreamSubscription<dynamic>? _subscription;
  Worker? _orderSyncWorker;
  String? _trackedOrderId;

  @override
  void onInit() {
    super.onInit();
    final argumentOrder = Get.arguments;
    if (argumentOrder is! OrderModel) {
      handleFailure(
        const AppFailure(
          code: 'missing_order',
          message: 'Order not found.',
        ),
      );
      return;
    }

    _trackedOrderId = argumentOrder.id;
    order.value = argumentOrder;
    update([trackingUiId]);

    if (Get.isRegistered<OrderController>()) {
      final orderController = Get.find<OrderController>();
      orderController.ensureRealtimeSync();
      _orderSyncWorker = ever<int>(orderController.liveUpdateTick, (_) {
        _syncFromOrderController();
      });
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _listenToOrder(argumentOrder.id);
    });
  }

  @override
  void onClose() {
    _subscription?.cancel();
    _orderSyncWorker?.dispose();
    super.onClose();
  }

  void _syncFromOrderController() {
    final orderId = _trackedOrderId;
    if (orderId == null || !Get.isRegistered<OrderController>()) return;

    final updated = Get.find<OrderController>()
        .orders
        .firstWhereOrNull((item) => item.id == orderId);

    if (updated == null || updated.status == order.value?.status) return;

    order.value = updated;
    update([trackingUiId]);
  }

  void _listenToOrder(String orderId) {
    final userId = _authController.user.value?.id;
    if (userId == null) {
      handleFailure(
        const AppFailure(
          code: 'missing_user',
          message: 'You must be signed in to track this order.',
        ),
      );
      return;
    }

    _subscription?.cancel();
    _subscription = _orderRepository
        .watchOrder(userId: userId, orderId: orderId)
        .listen(_handleOrderUpdate);
  }

  void _handleOrderUpdate(Result<OrderModel> result) {
    result.when(
      onSuccess: (updatedOrder) {
        order.value = updatedOrder;
        update([trackingUiId]);

        if (Get.isRegistered<OrderController>()) {
          Get.find<OrderController>().updateOrderInList(updatedOrder);
        }
      },
      onFailure: handleFailure,
    );
  }

  void continueShopping() {
    Get.until((route) => route.settings.name == AppRoutes.productList);
    if (Get.currentRoute != AppRoutes.productList) {
      Get.offAllNamed(AppRoutes.productList);
    }
  }
}
