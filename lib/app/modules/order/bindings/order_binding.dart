import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_tracking_controller.dart';

class OrderListBinding extends Bindings {
  @override
  void dependencies() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<OrderController>()) {
        Get.find<OrderController>().loadInitialOrders(forceRefresh: true);
      }
    });
  }
}

class OrderTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderTrackingController>(
      () => OrderTrackingController(),
      fenix: true,
    );
  }
}
