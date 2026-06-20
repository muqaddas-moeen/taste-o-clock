import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';
import 'package:taste_o_clock/app/data/models/product_page_result.dart';

abstract class ProductRepository {
  Future<Result<List<String>>> fetchCategories({bool forceRefresh = false});

  Future<Result<ProductPageResult>> fetchProducts({
    required ProductQuery query,
    bool forceRefresh = false,
  });

  Future<Result<ProductModel?>> getProductById(String productId);

  Future<Result<List<ProductModel>>> getCachedProducts({
    String? category,
    String? searchQuery,
  });

  Future<Result<void>> cacheRecentlyViewed(ProductModel product);

  Future<Result<List<ProductModel>>> getRecentlyViewed();

  Future<Result<bool>> hasNetworkConnection();
}
