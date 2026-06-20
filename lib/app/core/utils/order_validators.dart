import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/core/utils/input_validators.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';

class OrderValidators {
  OrderValidators._();

  static const _allowedPaymentStatuses = {
    'cash_on_delivery',
    'paid',
  };

  static Result<void> validateCartForOrder({
    required List<CartItemModel> items,
    required String paymentStatus,
    required PaymentMethod paymentMethod,
  }) {
    final itemsResult = validateCartItems(items);
    if (itemsResult case Error(:final failure)) {
      return Error(failure);
    }

    if (!_allowedPaymentStatuses.contains(paymentStatus)) {
      return const Error(
        AppFailure(
          code: 'invalid_payment_status',
          message: 'Invalid payment status for this order.',
        ),
      );
    }

    if (paymentMethod == PaymentMethod.cashOnDelivery &&
        paymentStatus != 'cash_on_delivery') {
      return const Error(
        AppFailure(
          code: 'invalid_payment_status',
          message: 'Cash orders must use cash on delivery status.',
        ),
      );
    }

    if (paymentMethod == PaymentMethod.card && paymentStatus != 'paid') {
      return const Error(
        AppFailure(
          code: 'invalid_payment_status',
          message: 'Card orders must be marked paid after successful payment.',
        ),
      );
    }

    return const Success(null);
  }

  static Result<void> validateCartItems(List<CartItemModel> items) {
    if (items.isEmpty) {
      return const Error(
        AppFailure(code: 'empty_cart', message: 'Your cart is empty.'),
      );
    }

    if (items.length > InputValidators.maxCartItems) {
      return const Error(
        AppFailure(
          code: 'cart_too_large',
          message: 'Cart exceeds the maximum number of items.',
        ),
      );
    }

    for (final item in items) {
      if (item.quantity <= 0 ||
          item.quantity > InputValidators.maxItemQuantity) {
        return const Error(
          AppFailure(
            code: 'invalid_quantity',
            message: 'One or more items has an invalid quantity.',
          ),
        );
      }
      if (item.unitPrice <= 0 || item.name.trim().isEmpty) {
        return const Error(
          AppFailure(
            code: 'invalid_item',
            message: 'One or more cart items is invalid.',
          ),
        );
      }
    }

    final summary = CartSummary.fromItems(items);
    if (summary.subtotal <= 0) {
      return const Error(
        AppFailure(
          code: 'invalid_subtotal',
          message: 'Order total must be greater than zero.',
        ),
      );
    }

    return const Success(null);
  }
}
