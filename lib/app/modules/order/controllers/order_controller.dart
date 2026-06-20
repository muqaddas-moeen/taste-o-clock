import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/controllers/base_controller.dart';
import 'package:taste_o_clock/app/core/enums/order_status.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/order_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';
import 'package:taste_o_clock/app/data/repositories/cart_repository.dart';
import 'package:taste_o_clock/app/data/repositories/order_repository.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/modules/cart/controllers/cart_controller.dart';
import 'package:taste_o_clock/app/modules/main_shell/controllers/main_shell_controller.dart';
import 'package:taste_o_clock/app/modules/notification/controllers/notification_controller.dart';
import 'package:taste_o_clock/app/core/utils/app_log.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class OrderController extends BaseController {
  static const activeOrderUiId = 'activeOrder';
  static const ordersUiId = 'orders';

  OrderController({
    OrderRepository? orderRepository,
    CartRepository? cartRepository,
    AuthController? authController,
  })  : _orderRepository = orderRepository ?? Get.find<OrderRepository>(),
        _cartRepository = cartRepository ?? Get.find<CartRepository>(),
        _authController = authController ?? Get.find<AuthController>();

  final OrderRepository _orderRepository;
  final CartRepository _cartRepository;
  final AuthController _authController;

  final ScrollController scrollController = ScrollController();
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final Rxn<OrderModel> activeOrderState = Rxn<OrderModel>();
  final RxInt liveUpdateTick = 0.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool isPlacingOrder = false.obs;

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  StreamSubscription<dynamic>? _recentOrdersSubscription;
  String? _streamUserId;

  OrderModel? get activeOrder => activeOrderState.value;

  List<OrderModel> get activeOrders =>
      orders.where((order) => order.isActive).toList();

  List<OrderModel> get pastOrders =>
      orders.where((order) => !order.isActive).toList();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);

    ever(_authController.isSessionReady, (ready) {
      if (ready == true && _authController.user.value != null) {
        bootstrapAfterLogin();
      }
    });

    ever(_authController.user, (user) {
      if (user != null) {
        bootstrapAfterLogin();
      } else {
        _stopRealtimeSync();
        orders.clear();
        activeOrderState.value = null;
        _bumpLiveUpdate();
      }
    });

    if (_authController.user.value != null &&
        _authController.isSessionReady.value) {
      bootstrapAfterLogin();
    }
  }

  @override
  void onClose() {
    _stopRealtimeSync();
    scrollController.dispose();
    super.onClose();
  }

  void ensureRealtimeSync() {
    final userId = _authController.user.value?.id;
    if (userId == null) return;
    _startRealtimeSync(userId);
  }

  void bootstrapAfterLogin() {
    ensureRealtimeSync();
    if (orders.isEmpty && !isLoading.value) {
      loadInitialOrders(forceRefresh: true);
    }
  }

  Future<void> loadInitialOrders({bool forceRefresh = false}) async {
    if (isLoading.value && !forceRefresh) return;

    isLoading.value = true;
    _lastDocument = null;
    hasMore.value = true;

    final userId = _authController.user.value?.id;
    if (userId == null) {
      isLoading.value = false;
      return;
    }

    ensureRealtimeSync();

    final result = await _orderRepository.fetchOrders(userId: userId);
    isLoading.value = false;

    result.when(
      onSuccess: (page) {
        _mergeFetchedOrders(page.orders);
        _lastDocument = page.lastDocument;
        hasMore.value = page.hasMore;
        _refreshActiveOrderState();
        _bumpLiveUpdate();
      },
      onFailure: handleFailure,
    );
  }

  Future<void> loadMoreOrders() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    final userId = _authController.user.value?.id;
    if (userId == null) return;

    isLoadingMore.value = true;

    final result = await _orderRepository.fetchOrders(
      userId: userId,
      startAfter: _lastDocument,
    );

    isLoadingMore.value = false;

    result.when(
      onSuccess: (page) {
        final existingIds = orders.map((order) => order.id).toSet();
        final newOrders =
            page.orders.where((order) => !existingIds.contains(order.id));
        orders.addAll(newOrders);
        _lastDocument = page.lastDocument;
        hasMore.value = page.hasMore;
        _refreshActiveOrderState();
        _bumpLiveUpdate();
      },
      onFailure: handleFailure,
    );
  }

  Future<void> proceedToCheckout() async {
    final userId = _authController.user.value?.id;
    if (userId == null) {
      handleFailure(
        const AppFailure(
          code: 'missing_user',
          message: 'You must be signed in to place an order.',
        ),
      );
      return;
    }

    final cartResult = await _cartRepository.getItems();
    final items = cartResult.when(
      onSuccess: (value) => value,
      onFailure: (failure) {
        handleFailure(failure);
        return null;
      },
    );

    if (items == null || items.isEmpty) {
      handleFailure(
        const AppFailure(
          code: 'empty_cart',
          message: 'Your cart is empty.',
        ),
      );
      return;
    }

    final profile = _authController.user.value;
    if (profile == null) {
      handleFailure(
        const AppFailure(
          code: 'missing_user',
          message: 'You must be signed in to place an order.',
        ),
      );
      return;
    }

    if (!profile.hasDeliveryLocation) {
      handleFailure(
        const AppFailure(
          code: 'missing_location',
          message: 'Add your delivery location in Profile before placing an order.',
        ),
      );
      Get.toNamed(AppRoutes.profile);
      return;
    }

    Get.toNamed(AppRoutes.checkout);
  }

  Future<void> placeOrderAfterPayment({
    required UserPaymentInfoModel paymentInfo,
    required String paymentStatus,
  }) async {
    if (isPlacingOrder.value) return;

    final userId = _authController.user.value?.id;
    if (userId == null) {
      handleFailure(
        const AppFailure(
          code: 'missing_user',
          message: 'You must be signed in to place an order.',
        ),
      );
      return;
    }

    final cartResult = await _cartRepository.getItems();
    final items = cartResult.when(
      onSuccess: (value) => value,
      onFailure: (failure) {
        handleFailure(failure);
        return null;
      },
    );

    if (items == null || items.isEmpty) {
      handleFailure(
        const AppFailure(
          code: 'empty_cart',
          message: 'Your cart is empty.',
        ),
      );
      return;
    }

    final profile = _authController.user.value;
    if (profile == null || !profile.hasDeliveryLocation) {
      handleFailure(
        const AppFailure(
          code: 'missing_location',
          message: 'Add your delivery location in Profile before placing an order.',
        ),
      );
      return;
    }

    isPlacingOrder.value = true;

    final result = await _orderRepository.placeOrder(
      userId: userId,
      items: items,
      deliveryLocation: profile.location!,
      paymentInfo: paymentInfo,
      paymentStatus: paymentStatus,
    );

    isPlacingOrder.value = false;

    switch (result) {
      case Success(:final data):
        final clearResult = await _cartRepository.clearCart();
        clearResult.when(
          onSuccess: (_) {
            if (Get.isRegistered<CartController>()) {
              Get.find<CartController>().loadCart();
            }
          },
          onFailure: handleFailure,
        );

        Helpers.showSuccess('Order placed successfully!');
        _upsertOrder(data);
        ensureRealtimeSync();
        Get.offAllNamed(AppRoutes.productList);
        Get.toNamed(AppRoutes.orderTracking, arguments: data);
      case Error(:final failure):
        handleFailure(failure);
    }
  }

  void openOrders() {
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().switchTo(MainShellTab.orders);
      return;
    }
    Get.toNamed(AppRoutes.orders);
  }

  void openActiveOrderTracking() {
    final active = activeOrder;
    if (active == null) {
      openOrders();
      return;
    }

    openOrderTracking(active);
  }

  void updateOrderInList(OrderModel updatedOrder) {
    final index = orders.indexWhere((order) => order.id == updatedOrder.id);
    OrderModel? previous;

    if (index >= 0) {
      previous = orders[index];
      final nextOrders = List<OrderModel>.from(orders);
      nextOrders[index] = updatedOrder;
      orders.assignAll(nextOrders);
    } else {
      orders.insert(0, updatedOrder);
    }

    _syncActiveOrderState(updatedOrder);
    _bumpLiveUpdate();

    if (previous != null && previous.status != updatedOrder.status) {
      _handleStatusChange(updatedOrder, previous.status);
    }
  }

  void _upsertOrder(OrderModel order) {
    updateOrderInList(order);
  }

  void _startRealtimeSync(String userId) {
    if (_streamUserId == userId && _recentOrdersSubscription != null) {
      return;
    }

    _stopRealtimeSync();
    _streamUserId = userId;

    AppLog.d('[Order] Starting realtime sync for user $userId');

    _recentOrdersSubscription = _orderRepository
        .watchRecentOrders(userId: userId)
        .listen(_handleRealtimeOrders);
  }

  void _handleRealtimeOrders(Result<List<OrderModel>> result) {
    result.when(
      onSuccess: (streamOrders) {
        AppLog.d('[Order] Realtime snapshot: ${streamOrders.length} orders');
        _applyRealtimeOrders(streamOrders);
      },
      onFailure: (failure) {
        AppLog.d('[Order] Realtime sync error: ${failure.message}');
      },
    );
  }

  void _applyRealtimeOrders(List<OrderModel> streamOrders) {
    final previousById = {for (final order in orders) order.id: order};
    final streamIds = streamOrders.map((order) => order.id).toSet();
    final olderOrders =
        orders.where((order) => !streamIds.contains(order.id)).toList();

    orders.assignAll([...streamOrders, ...olderOrders]);

    for (final updated in streamOrders) {
      final previous = previousById[updated.id];
      if (previous != null && previous.status != updated.status) {
        _handleStatusChange(updated, previous.status);
      }
    }

    _refreshActiveOrderState();
    _bumpLiveUpdate();
  }

  void _mergeFetchedOrders(List<OrderModel> fetchedOrders) {
    if (orders.isEmpty) {
      orders.assignAll(fetchedOrders);
      return;
    }

    final mergedIds = fetchedOrders.map((order) => order.id).toSet();
    final tail = orders.where((order) => !mergedIds.contains(order.id)).toList();
    orders.assignAll([...fetchedOrders, ...tail]);
  }

  void _handleStatusChange(OrderModel updatedOrder, OrderStatus previousStatus) {
    AppLog.d(
      '[Order] Status changed: ${previousStatus.firestoreValue} -> '
      '${updatedOrder.status.firestoreValue} (${updatedOrder.id})',
    );

    if (Get.isRegistered<NotificationController>()) {
      Get.find<NotificationController>().notifyOrderStatusChange(
        order: updatedOrder,
        previousStatus: previousStatus,
      );
    }
  }

  void _syncActiveOrderState(OrderModel updatedOrder) {
    final currentActive = activeOrderState.value;

    if (updatedOrder.isActive) {
      if (currentActive == null || currentActive.id == updatedOrder.id) {
        activeOrderState.value = updatedOrder;
        return;
      }
    } else if (currentActive?.id == updatedOrder.id) {
      activeOrderState.value = null;
      return;
    }

    _refreshActiveOrderState();
  }

  void _refreshActiveOrderState() {
    OrderModel? active;
    for (final order in orders) {
      if (order.isActive) {
        active = order;
        break;
      }
    }
    activeOrderState.value = active;
  }

  void _bumpLiveUpdate() {
    liveUpdateTick.value++;
    update([activeOrderUiId, ordersUiId]);
  }

  void _stopRealtimeSync() {
    _recentOrdersSubscription?.cancel();
    _recentOrdersSubscription = null;
    _streamUserId = null;
  }

  void openOrderTracking(OrderModel order) {
    Get.toNamed(AppRoutes.orderTracking, arguments: order);
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final threshold = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= threshold) {
      loadMoreOrders();
    }
  }
}
