import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:taste_o_clock/app/core/config/firebase_collections.dart';
import 'package:taste_o_clock/app/core/errors/app_exception.dart';
import 'package:taste_o_clock/app/data/models/category_model.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';
import 'package:taste_o_clock/app/data/models/product_page_result.dart';
import 'package:taste_o_clock/app/data/services/firebase_service.dart';

class ProductService {
  ProductService({
    FirebaseService? firebaseService,
    Connectivity? connectivity,
  })  : _firebaseService = firebaseService ?? FirebaseService(),
        _connectivity = connectivity ?? Connectivity();

  final FirebaseService _firebaseService;
  final Connectivity _connectivity;

  static const int _scanBatchSize = 24;

  CollectionReference<Map<String, dynamic>> get _products =>
      _firebaseService.collection(FirebaseCollections.products);

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firebaseService.collection(FirebaseCollections.categories);

  Future<List<CategoryModel>> fetchCategories() async {
    try {
      final snapshot = await _categories.get();
      final categories = snapshot.docs
          .map(CategoryModel.tryFromFirestore)
          .whereType<CategoryModel>()
          .where((category) => category.isActive)
          .toList()
        ..sort((a, b) {
          final orderCompare = a.sortOrder.compareTo(b.sortOrder);
          if (orderCompare != 0) return orderCompare;
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });

      return categories;
    } on FirebaseException catch (e) {
      throw AppException(
        code: e.code,
        message: _mapFirebaseMessage(e),
        cause: e,
      );
    } catch (e) {
      throw AppException(
        code: 'categories_parse_error',
        message: 'Failed to read categories: $e',
        cause: e,
      );
    }
  }

  Future<bool> hasNetworkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  Future<ProductPageResult> fetchProducts(ProductQuery query) async {
    try {
      final matched = <ProductModel>[];
      DocumentSnapshot<Map<String, dynamic>>? cursor = query.startAfter;
      DocumentSnapshot<Map<String, dynamic>>? lastScanned;
      var hasMoreInFirestore = true;

      while (matched.length < query.limit && hasMoreInFirestore) {
        Query<Map<String, dynamic>> firestoreQuery =
            _products.limit(_scanBatchSize);

        if (cursor != null) {
          firestoreQuery = firestoreQuery.startAfterDocument(cursor);
        }

        final snapshot = await firestoreQuery.get();
        if (snapshot.docs.isEmpty) {
          hasMoreInFirestore = false;
          break;
        }

        lastScanned = snapshot.docs.last;
        cursor = snapshot.docs.last;
        hasMoreInFirestore = snapshot.docs.length == _scanBatchSize;

        final batch = snapshot.docs
            .map(ProductModel.tryFromFirestore)
            .whereType<ProductModel>()
            .toList()
          ..sort((a, b) => a.nameLowercase.compareTo(b.nameLowercase));

        for (final product in batch) {
          if (!_matchesQuery(product, query)) continue;

          matched.add(product);
          if (matched.length >= query.limit) break;
        }
      }

      return ProductPageResult(
        products: matched,
        lastDocument: lastScanned,
        hasMore: hasMoreInFirestore,
      );
    } on FirebaseException catch (e) {
      throw AppException(
        code: e.code,
        message: _mapFirebaseMessage(e),
        cause: e,
      );
    } catch (e) {
      throw AppException(
        code: 'products_parse_error',
        message: 'Failed to read products: $e',
        cause: e,
      );
    }
  }

  bool _matchesQuery(ProductModel product, ProductQuery query) {
    if (!product.isAvailable) return false;

    if (query.hasCategoryFilter &&
        product.category.toLowerCase() != query.category!.toLowerCase()) {
      return false;
    }

    if (query.hasSearch) {
      final normalized = query.searchQuery!.trim().toLowerCase();
      final matchesName = product.nameLowercase.contains(normalized);
      final matchesDescription =
          product.description.toLowerCase().contains(normalized);
      if (!matchesName && !matchesDescription) return false;
    }

    return true;
  }

  String _mapFirebaseMessage(FirebaseException e) {
    return switch (e.code) {
      'permission-denied' =>
        'You do not have permission to read products. Please sign in again.',
      'unavailable' => 'Firestore is temporarily unavailable. Try again shortly.',
      'failed-precondition' =>
        'Products are still syncing on the server. Pull to refresh in a moment.',
      _ => e.message ?? 'Failed to load products from Firestore.',
    };
  }

  Future<ProductModel?> fetchProductById(String productId) async {
    try {
      final doc = await _products.doc(productId).get();
      if (!doc.exists) return null;
      return ProductModel.tryFromFirestore(doc);
    } on FirebaseException catch (e) {
      throw AppException(
        code: e.code,
        message: _mapFirebaseMessage(e),
        cause: e,
      );
    }
  }
}
