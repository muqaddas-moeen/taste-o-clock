import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';

abstract class CartRepository {
  Future<Result<List<CartItemModel>>> getItems();

  Future<Result<List<CartItemModel>>> addProduct(
    ProductModel product, {
    int quantity = 1,
  });

  Future<Result<List<CartItemModel>>> incrementQuantity(String productId);

  Future<Result<List<CartItemModel>>> decrementQuantity(String productId);

  Future<Result<List<CartItemModel>>> removeItem(String productId);

  Future<Result<List<CartItemModel>>> clearCart();

  CartSummary summarize(List<CartItemModel> items);
}
