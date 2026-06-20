import 'package:taste_o_clock/app/data/models/cart_item_model.dart';

/// Hive-specific cart item representation.
class CartHiveModel {
  const CartHiveModel({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.imageUrl,
    required this.quantity,
    required this.addedAtMillis,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final String imageUrl;
  final int quantity;
  final int addedAtMillis;

  factory CartHiveModel.fromCartItem(CartItemModel item) {
    return CartHiveModel(
      productId: item.productId,
      name: item.name,
      unitPrice: item.unitPrice,
      imageUrl: item.imageUrl,
      quantity: item.quantity,
      addedAtMillis: item.addedAt.millisecondsSinceEpoch,
    );
  }

  factory CartHiveModel.fromMap(Map<dynamic, dynamic> map) {
    return CartHiveModel(
      productId: map['productId'] as String,
      name: map['name'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      addedAtMillis: map['addedAtMillis'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'unitPrice': unitPrice,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'addedAtMillis': addedAtMillis,
    };
  }

  CartItemModel toCartItem() {
    return CartItemModel(
      productId: productId,
      name: name,
      unitPrice: unitPrice,
      imageUrl: imageUrl,
      quantity: quantity,
      addedAt: DateTime.fromMillisecondsSinceEpoch(addedAtMillis),
    );
  }
}
