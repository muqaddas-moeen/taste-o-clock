import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/config/app_config.dart';
import 'package:taste_o_clock/app/core/controllers/base_controller.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/utils/order_validators.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';
import 'package:taste_o_clock/app/data/services/payment_service.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/modules/cart/controllers/cart_controller.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';
import 'package:taste_o_clock/app/theme/app_colors.dart';
import 'package:taste_o_clock/app/theme/app_font_style.dart';

class CheckoutController extends BaseController {
  CheckoutController({
    CartController? cartController,
    OrderController? orderController,
    AuthController? authController,
  })  : _cartController = cartController ?? Get.find<CartController>(),
        _orderController = orderController ?? Get.find<OrderController>(),
        _authController = authController ?? Get.find<AuthController>();

  final CartController _cartController;
  final OrderController _orderController;
  final AuthController _authController;

  final Rx<PaymentMethod> selectedPaymentMethod =
      PaymentMethod.cashOnDelivery.obs;
  final RxBool isProcessingPayment = false.obs;

  List<CartItemModel> get items => _cartController.items;
  double get subtotal => _cartController.subtotal.value;
  int get totalItems => _cartController.totalItems.value;

  String get deliveryAddressLabel =>
      _authController.user.value?.location?.formattedAddress ??
      'No delivery address saved';

  void selectPaymentMethod(PaymentMethod method) {
    selectedPaymentMethod.value = method;
  }

  bool get isStripeReady =>
      AppConfig.hasValidStripePublishableKey &&
      PaymentService.instance.isStripeReady;

  @override
  void onInit() {
    super.onInit();
    if (items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleFailure(
          const AppFailure(
            code: 'empty_cart',
            message: 'Your cart is empty.',
          ),
        );
        Get.back();
      });
    }
  }

  Future<void> confirmAndPay() async {
    if (isProcessingPayment.value || _orderController.isPlacingOrder.value) {
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
          message: 'Add your delivery location in Profile before checkout.',
        ),
      );
      Get.toNamed(AppRoutes.profile);
      return;
    }

    if (items.isEmpty) {
      handleFailure(
        const AppFailure(
          code: 'empty_cart',
          message: 'Your cart is empty.',
        ),
      );
      return;
    }

    final cartValidation = OrderValidators.validateCartItems(items);
    final validationFailed = cartValidation.when(
      onSuccess: (_) => false,
      onFailure: (failure) {
        handleFailure(failure);
        return true;
      },
    );
    if (validationFailed) return;

    final method = selectedPaymentMethod.value;

    if (method == PaymentMethod.cashOnDelivery) {
      final confirmed = await _confirmCashPayment();
      if (confirmed != true) return;

      await _placeOrder(
        paymentInfo: UserPaymentInfoModel(
          paymentMethod: PaymentMethod.cashOnDelivery,
          updatedAt: DateTime.now(),
        ),
        paymentStatus: 'cash_on_delivery',
      );
      return;
    }

    if (method == PaymentMethod.card) {
      if (!AppConfig.hasValidStripePublishableKey) {
        handleFailure(
          const AppFailure(
            code: 'stripe_not_configured',
            message: 'Card payments are not available right now.',
          ),
        );
        return;
      }

      final healthResult =
          await PaymentService.instance.checkPaymentServerHealth();
      final healthOk = healthResult.when(
        onSuccess: (_) => true,
        onFailure: (failure) {
          handleFailure(failure);
          return false;
        },
      );
      if (!healthOk) return;
    }

    isProcessingPayment.value = true;

    final paymentResult = await PaymentService.instance.payWithCard(
      amount: subtotal,
    );

    isProcessingPayment.value = false;

    paymentResult.when(
      onSuccess: (_) async {
        await _placeOrder(
          paymentInfo: UserPaymentInfoModel(
            paymentMethod: PaymentMethod.card,
            updatedAt: DateTime.now(),
          ),
          paymentStatus: 'paid',
        );
      },
      onFailure: (failure) {
        if (failure.code != 'payment_cancelled') {
          handleFailure(failure);
        }
      },
    );
  }

  Future<bool?> _confirmCashPayment() {
    return Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Confirm Cash Payment',
          style: AppFontStyle.kMulishTextStyle(
            fontSize: 18,
            c: AppColors.kTextPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'You will pay $totalItems item${totalItems == 1 ? '' : 's'} '
          'in cash when your order is delivered.',
          style: AppFontStyle.kMulishTextStyle(
            fontSize: 14,
            c: AppColors.kTextSecondary,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                child: const Text('Confirm & Place Order'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _placeOrder({
    required UserPaymentInfoModel paymentInfo,
    required String paymentStatus,
  }) async {
    await _orderController.placeOrderAfterPayment(
      paymentInfo: paymentInfo,
      paymentStatus: paymentStatus,
    );
  }
}
