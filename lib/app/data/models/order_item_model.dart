import 'package:taste_o_clock/app/core/config/firebase_collections.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.imageUrl,
  });

  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String imageUrl;

  double get lineTotal => unitPrice * quantity;

  factory OrderItemModel.fromCartItem(CartItemModel item) {
    return OrderItemModel(
      productId: item.productId,
      name: item.name,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
      imageUrl: item.imageUrl,
    );
  }

  factory OrderItemModel.fromMap(Map<dynamic, dynamic> map) {
    return OrderItemModel(
      productId: map[OrderFields.productId] as String? ?? '',
      name: map[OrderFields.name] as String? ?? '',
      unitPrice: (map[OrderFields.unitPrice] as num?)?.toDouble() ?? 0,
      quantity: (map[OrderFields.quantity] as num?)?.toInt() ?? 0,
      imageUrl: map[OrderFields.imageUrl] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      OrderFields.productId: productId,
      OrderFields.name: name,
      OrderFields.unitPrice: unitPrice,
      OrderFields.quantity: quantity,
      OrderFields.imageUrl: imageUrl,
    };
  }
}
