import 'package:taste_o_clock/app/core/config/hive_boxes.dart';
import 'package:taste_o_clock/app/core/config/product_config.dart';
import 'package:taste_o_clock/app/core/errors/app_exception.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/product_hive_model.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';
import 'package:taste_o_clock/app/data/models/product_page_result.dart';
import 'package:taste_o_clock/app/data/repositories/product_repository.dart';
import 'package:taste_o_clock/app/data/services/product_service.dart';
import 'package:taste_o_clock/app/data/services/storage_service.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    required ProductService productService,
    required StorageService storageService,
  })  : _productService = productService,
        _storageService = storageService;

  final ProductService _productService;
  final StorageService _storageService;

  static const int _maxRecentlyViewed = 10;

  @override
  Future<Result<List<String>>> fetchCategories({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cached = _readCachedCategoryNames();
      if (cached.isNotEmpty) {
        return Success(cached);
      }
    }

    final hasNetwork = await _productService.hasNetworkConnection();
    if (!hasNetwork) {
      return Success(await _resolveCategoryNames());
    }

    try {
      final categories = await _productService.fetchCategories();
      final names = categories.map((category) => category.name).toList();

      if (names.isEmpty) {
        return Success(await _resolveCategoryNames());
      }

      await _cacheCategoryNames(names);
      return Success(names);
    } on AppException catch (e) {
      final cached = _readCachedCategoryNames();
      if (cached.isNotEmpty) {
        return Success(cached);
      }
      final resolved = await _resolveCategoryNames();
      if (resolved.isNotEmpty) {
        return Success(resolved);
      }
      return Error(e.toFailure());
    } catch (_) {
      final cached = _readCachedCategoryNames();
      if (cached.isNotEmpty) {
        return Success(cached);
      }
      final resolved = await _resolveCategoryNames();
      if (resolved.isNotEmpty) {
        return Success(resolved);
      }
      return const Error(
        AppFailure(
          code: 'categories_fetch_error',
          message: 'Unable to load categories. Please try again.',
        ),
      );
    }
  }

  Future<List<String>> _resolveCategoryNames() async {
    final cached = _readCachedCategoryNames();
    if (cached.isNotEmpty) return cached;

    final derived = await _deriveCategoriesFromProducts();
    if (derived.isNotEmpty) {
      await _cacheCategoryNames(derived);
      return derived;
    }

    return _categoryFallback();
  }

  Future<List<String>> _deriveCategoriesFromProducts() async {
    try {
      final cachedProducts = await getCachedProducts();
      final products = cachedProducts.when(
        onSuccess: (items) => items,
        onFailure: (_) => const <ProductModel>[],
      );

      if (products.isNotEmpty) {
        return _uniqueCategoryNames(products);
      }

      final page = await _productService.fetchProducts(
        const ProductQuery(limit: 100),
      );
      return _uniqueCategoryNames(page.products);
    } catch (_) {
      return const [];
    }
  }

  List<String> _uniqueCategoryNames(List<ProductModel> products) {
    final names = products
        .map((product) => product.category.trim())
        .where(
          (name) => name.isNotEmpty && name.toLowerCase() != ProductCategories.all.toLowerCase(),
        )
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return names;
  }

  List<String> _categoryFallback() => List<String>.from(ProductCategories.fallback);

  Future<void> _cacheCategoryNames(List<String> names) async {
    if (names.isEmpty) return;
    await _storageService.productsCacheBox.put(
      HiveKeys.cachedCategoryNames,
      names,
    );
  }

  List<String> _readCachedCategoryNames() {
    final cached = _storageService.productsCacheBox.get(HiveKeys.cachedCategoryNames);
    if (cached is! List) return const [];

    return cached
        .whereType<String>()
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  Future<Result<ProductPageResult>> fetchProducts({
    required ProductQuery query,
    bool forceRefresh = false,
  }) async {
    final hasNetwork = await _productService.hasNetworkConnection();

    if (!hasNetwork) {
      final cached = await getCachedProducts(
        category: query.category,
        searchQuery: query.searchQuery,
      );

      return cached.when(
        onSuccess: (products) => Success(
          ProductPageResult(
            products: products,
            lastDocument: null,
            hasMore: false,
          ),
        ),
        onFailure: (failure) => Error(failure),
      );
    }

    try {
      final page = await _productService.fetchProducts(query);
      try {
        await _cacheProducts(page.products);
      } catch (_) {
        // Cache failures should not block showing freshly fetched products.
      }
      return Success(page);
    } on AppException catch (e) {
      final cached = await getCachedProducts(
        category: query.category,
        searchQuery: query.searchQuery,
      );

      return cached.when(
        onSuccess: (products) {
          if (products.isNotEmpty) {
            return Success(
              ProductPageResult(
                products: products,
                lastDocument: null,
                hasMore: false,
              ),
            );
          }
          return Error(e.toFailure());
        },
        onFailure: (_) => Error(e.toFailure()),
      );
    } catch (e) {
      return Error(
        AppFailure(
          code: 'products_fetch_error',
          message: e is AppException
              ? e.message
              : 'Unable to load products. Please try again.',
        ),
      );
    }
  }

  @override
  Future<Result<ProductModel?>> getProductById(String productId) async {
    try {
      final hasNetwork = await _productService.hasNetworkConnection();
      if (hasNetwork) {
        final product = await _productService.fetchProductById(productId);
        if (product != null) {
          await _cacheProducts([product]);
        }
        return Success(product);
      }

      final cached = _readCachedProduct(productId);
      return Success(cached?.toProduct());
    } on AppException catch (e) {
      final cached = _readCachedProduct(productId);
      if (cached != null) {
        return Success(cached.toProduct());
      }
      return Error(e.toFailure());
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'product_fetch_error',
          message: 'Unable to load product details.',
        ),
      );
    }
  }

  @override
  Future<Result<List<ProductModel>>> getCachedProducts({
    String? category,
    String? searchQuery,
  }) async {
    try {
      final box = _storageService.productsCacheBox;
      final ids = (box.get(HiveKeys.cachedProductIds) as List?)?.cast<String>() ?? [];

      final products = ids
          .map((id) => _readCachedProduct(id))
          .whereType<ProductHiveModel>()
          .map((item) => item.toProduct())
          .where((product) => _matchesFilters(product, category, searchQuery))
          .toList()
        ..sort((a, b) => a.nameLowercase.compareTo(b.nameLowercase));

      return Success(products);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'cache_read_error',
          message: 'Unable to read cached products.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> cacheRecentlyViewed(ProductModel product) async {
    try {
      final box = _storageService.recentlyViewedBox;
      final currentIds =
          (box.get(HiveKeys.recentlyViewedIds) as List?)?.cast<String>() ?? [];

      final updatedIds = [
        product.id,
        ...currentIds.where((id) => id != product.id),
      ].take(_maxRecentlyViewed).toList();

      await box.put(HiveKeys.recentlyViewedIds, updatedIds);
      await box.put(
        HiveKeys.productKey(product.id),
        ProductHiveModel.fromProduct(product).toMap(),
      );

      return const Success(null);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'recently_viewed_error',
          message: 'Unable to save recently viewed item.',
        ),
      );
    }
  }

  @override
  Future<Result<List<ProductModel>>> getRecentlyViewed() async {
    try {
      final box = _storageService.recentlyViewedBox;
      final ids =
          (box.get(HiveKeys.recentlyViewedIds) as List?)?.cast<String>() ?? [];

      final products = ids
          .map((id) {
            final map = box.get(HiveKeys.productKey(id));
            if (map is Map) {
              return ProductHiveModel.fromMap(map).toProduct();
            }
            return _readCachedProduct(id)?.toProduct();
          })
          .whereType<ProductModel>()
          .toList();

      return Success(products);
    } catch (_) {
      return const Error(
        AppFailure(
          code: 'recently_viewed_read_error',
          message: 'Unable to load recently viewed items.',
        ),
      );
    }
  }

  @override
  Future<Result<bool>> hasNetworkConnection() async {
    try {
      final isConnected = await _productService.hasNetworkConnection();
      return Success(isConnected);
    } catch (_) {
      return const Success(false);
    }
  }

  Future<void> _cacheProducts(List<ProductModel> products) async {
    if (products.isEmpty) return;

    final box = _storageService.productsCacheBox;
    final existingIds =
        (box.get(HiveKeys.cachedProductIds) as List?)?.cast<String>() ?? [];
    final mergedIds = {
      ...existingIds,
      ...products.map((product) => product.id),
    }.toList();

    for (final product in products) {
      await box.put(
        HiveKeys.productKey(product.id),
        ProductHiveModel.fromProduct(product).toMap(),
      );
    }

    await box.put(HiveKeys.cachedProductIds, mergedIds);
  }

  ProductHiveModel? _readCachedProduct(String productId) {
    final map = _storageService.productsCacheBox.get(HiveKeys.productKey(productId));
    if (map is! Map) return null;
    return ProductHiveModel.fromMap(map);
  }

  bool _matchesFilters(
    ProductModel product,
    String? category,
    String? searchQuery,
  ) {
    final matchesCategory = category == null ||
        category == ProductCategories.all ||
        product.category.toLowerCase() == category.toLowerCase();

    if (!matchesCategory) return false;

    if (searchQuery == null || searchQuery.trim().isEmpty) {
      return true;
    }

    final normalized = searchQuery.trim().toLowerCase();
    return product.nameLowercase.contains(normalized) ||
        product.description.toLowerCase().contains(normalized);
  }
}
