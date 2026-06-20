import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';

class OrdersIconButton extends StatelessWidget {
  const OrdersIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final orderController = Get.find<OrderController>();

    return IconButton(
      onPressed: orderController.openOrders,
      icon: const Icon(Icons.receipt_long_outlined),
      tooltip: 'My Orders',
    );
  }
}
