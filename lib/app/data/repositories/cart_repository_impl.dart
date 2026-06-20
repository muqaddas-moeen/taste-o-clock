import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';
import 'package:taste_o_clock/app/data/repositories/cart_repository.dart';
import 'package:taste_o_clock/app/data/services/cart_service.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required CartService cartService})
      : _cartService = cartService;

  final CartService _cartService;

  static const int _maxQuantity = 99;

  @override
  Future<Result<List<CartItemModel>>> getItems() async {
    try {
      final items = await _cartService.readItems();
      return Success(items);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'cart_read_error',
          message: 'Unable to load cart items.',
        ),
      );
    }
  }

  @override
  Future<Result<List<CartItemModel>>> addProduct(
    ProductModel product, {
    int quantity = 1,
  }) async {
    if (!product.isAvailable) {
      return const Error(
        AppFailure(
          code: 'product_unavailable',
          message: 'This item is currently unavailable.',
        ),
      );
    }

    if (quantity < 1) {
      return const Error(
        AppFailure(
          code: 'invalid_quantity',
          message: 'Quantity must be at least 1.',
        ),
      );
    }

    try {
      final items = await _cartService.readItems();
      final index = items.indexWhere((item) => item.productId == product.id);

      if (index >= 0) {
        final current = items[index];
        final nextQuantity =
            (current.quantity + quantity).clamp(1, _maxQuantity).toInt();
        items[index] = current.copyWith(
          name: product.name,
          unitPrice: product.price,
          imageUrl: product.imageUrl,
          quantity: nextQuantity,
        );
      } else {
        items.add(
          CartItemModel.fromProduct(
            product,
            quantity: quantity.clamp(1, _maxQuantity).toInt(),
          ),
        );
      }

      await _cartService.writeItems(items);
      return Success(items);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'cart_add_error',
          message: 'Unable to add item to cart.',
        ),
      );
    }
  }

  @override
  Future<Result<List<CartItemModel>>> incrementQuantity(String productId) {
    return _updateQuantity(productId, 1);
  }

  @override
  Future<Result<List<CartItemModel>>> decrementQuantity(String productId) {
    return _updateQuantity(productId, -1);
  }

  @override
  Future<Result<List<CartItemModel>>> removeItem(String productId) async {
    try {
      final items = await _cartService.readItems();
      items.removeWhere((item) => item.productId == productId);
      await _cartService.writeItems(items);
      return Success(items);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'cart_remove_error',
          message: 'Unable to remove cart item.',
        ),
      );
    }
  }

  @override
  Future<Result<List<CartItemModel>>> clearCart() async {
    try {
      await _cartService.clear();
      return const Success([]);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'cart_clear_error',
          message: 'Unable to clear cart.',
        ),
      );
    }
  }

  @override
  CartSummary summarize(List<CartItemModel> items) {
    return CartSummary.fromItems(items);
  }

  Future<Result<List<CartItemModel>>> _updateQuantity(
    String productId,
    int delta,
  ) async {
    try {
      final items = await _cartService.readItems();
      final index = items.indexWhere((item) => item.productId == productId);

      if (index < 0) {
        return const Error(
          AppFailure(
            code: 'cart_item_missing',
            message: 'Item not found in cart.',
          ),
        );
      }

      final current = items[index];
      final nextQuantity = current.quantity + delta;

      if (nextQuantity <= 0) {
        items.removeAt(index);
      } else if (nextQuantity > _maxQuantity) {
        return const Error(
          AppFailure(
            code: 'invalid_quantity',
            message: 'Maximum quantity reached for this item.',
          ),
        );
      } else {
        items[index] = current.copyWith(quantity: nextQuantity);
      }

      await _cartService.writeItems(items);
      return Success(items);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'cart_update_error',
          message: 'Unable to update cart item.',
        ),
      );
    }
  }
}
