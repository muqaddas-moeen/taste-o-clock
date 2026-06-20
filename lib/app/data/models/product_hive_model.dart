import 'package:taste_o_clock/app/data/models/product_model.dart';

/// Hive-specific product representation. Kept separate from [ProductModel].
class ProductHiveModel {
  const ProductHiveModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
    required this.rating,
    required this.createdAtMillis,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final double rating;
  final int createdAtMillis;

  factory ProductHiveModel.fromProduct(ProductModel product) {
    return ProductHiveModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      isAvailable: product.isAvailable,
      rating: product.rating,
      createdAtMillis: product.createdAt.millisecondsSinceEpoch,
    );
  }

  factory ProductHiveModel.fromMap(Map<dynamic, dynamic> map) {
    return ProductHiveModel(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      category: map['category'] as String? ?? '',
      isAvailable: map['isAvailable'] as bool? ?? true,
      rating: (map['rating'] as num?)?.toDouble() ?? 0,
      createdAtMillis: map['createdAtMillis'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isAvailable': isAvailable,
      'rating': rating,
      'createdAtMillis': createdAtMillis,
    };
  }

  ProductModel toProduct() {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      imageUrl: imageUrl,
      category: category,
      isAvailable: isAvailable,
      rating: rating,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
    );
  }
}
