import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';

class ProductPageResult {
  const ProductPageResult({
    required this.products,
    required this.lastDocument,
    required this.hasMore,
  });

  final List<ProductModel> products;
  final DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  final bool hasMore;
}

class ProductQuery {
  const ProductQuery({
    this.category,
    this.searchQuery,
    this.startAfter,
    this.limit = 10,
  });

  final String? category;
  final String? searchQuery;
  final DocumentSnapshot<Map<String, dynamic>>? startAfter;
  final int limit;

  bool get hasCategoryFilter =>
      category != null && category!.isNotEmpty && category != 'All';

  bool get hasSearch => searchQuery != null && searchQuery!.trim().isNotEmpty;
}
