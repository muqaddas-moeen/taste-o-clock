import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/config/product_config.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isAvailable,
    required this.rating,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isAvailable;
  final double rating;
  final DateTime createdAt;

  String get nameLowercase => name.toLowerCase();

  /// Returns null when the document cannot be parsed safely.
  static ProductModel? tryFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    try {
      final data = doc.data();
      if (data == null || data.isEmpty) return null;

      final name = _readString(data[ProductFields.name]);
      if (name.isEmpty) return null;

      return ProductModel(
        id: doc.id,
        name: name,
        description: _readString(data[ProductFields.description]),
        price: _readDouble(data[ProductFields.price]),
        imageUrl: _readString(data[ProductFields.imageUrl]),
        category: _readString(data[ProductFields.category]).isEmpty
            ? ProductCategories.all
            : _readString(data[ProductFields.category]),
        isAvailable: _readBool(data[ProductFields.isAvailable], defaultValue: true),
        rating: _readDouble(data[ProductFields.rating]),
        createdAt: _parseTimestamp(data[ProductFields.createdAt]) ?? DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }

  factory ProductModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return tryFromFirestore(doc) ??
        ProductModel(
          id: doc.id,
          name: 'Unknown item',
          description: '',
          price: 0,
          imageUrl: '',
          category: ProductCategories.all,
          isAvailable: true,
          rating: 0,
          createdAt: DateTime.now(),
        );
  }

  Map<String, dynamic> toFirestore() {
    return {
      ProductFields.name: name,
      ProductFields.nameLowercase: nameLowercase,
      ProductFields.description: description,
      ProductFields.price: price,
      ProductFields.imageUrl: imageUrl,
      ProductFields.category: category,
      ProductFields.isAvailable: isAvailable,
      ProductFields.rating: rating,
      ProductFields.createdAt: Timestamp.fromDate(createdAt),
    };
  }

  static String _readString(Object? value) {
    if (value == null) return '';
    return value.toString();
  }

  static double _readDouble(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static bool _readBool(Object? value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return defaultValue;
  }

  static DateTime? _parseTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
