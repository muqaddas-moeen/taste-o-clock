import 'package:taste_o_clock/app/data/models/cart_hive_model.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';

class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.imageUrl,
    required this.quantity,
    required this.addedAt,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final String imageUrl;
  final int quantity;
  final DateTime addedAt;

  double get lineTotal => unitPrice * quantity;

  factory CartItemModel.fromProduct(
    ProductModel product, {
    int quantity = 1,
  }) {
    return CartItemModel(
      productId: product.id,
      name: product.name,
      unitPrice: product.price,
      imageUrl: product.imageUrl,
      quantity: quantity,
      addedAt: DateTime.now(),
    );
  }

  factory CartItemModel.fromHive(CartHiveModel model) => model.toCartItem();

  CartItemModel copyWith({
    String? name,
    double? unitPrice,
    String? imageUrl,
    int? quantity,
    DateTime? addedAt,
  }) {
    return CartItemModel(
      productId: productId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
    );
  }
}

class CartSummary {
  const CartSummary({
    required this.totalItems,
    required this.subtotal,
  });

  final int totalItems;
  final double subtotal;

  static CartSummary fromItems(List<CartItemModel> items) {
    final totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.lineTotal);
    return CartSummary(totalItems: totalItems, subtotal: subtotal);
  }
}
