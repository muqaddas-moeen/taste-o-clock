import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/config/app_config.dart';
import 'package:taste_o_clock/app/core/config/product_config.dart';
import 'package:taste_o_clock/app/core/controllers/base_controller.dart';
import 'package:taste_o_clock/app/core/network/result.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';
import 'package:taste_o_clock/app/data/models/product_page_result.dart';
import 'package:taste_o_clock/app/core/utils/input_validators.dart';
import 'package:taste_o_clock/app/data/repositories/product_repository.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';

class ProductController extends BaseController {
  ProductController({ProductRepository? productRepository})
      : _productRepository = productRepository ?? Get.find<ProductRepository>();

  final ProductRepository _productRepository;

  final ScrollController scrollController = ScrollController();

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxString selectedCategory = ProductCategories.all.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool isOffline = false.obs;
  final RxBool isRefreshing = false.obs;

  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  Timer? _searchDebounce;

  @override
  void onInit() {
    super.onInit();
    categories.assignAll([ProductCategories.all]);
    loadCategories();
    scrollController.addListener(_onScroll);
    loadInitialProducts();
    _ensureOrdersLoaded();
  }

  Future<void> loadCategories({bool forceRefresh = false}) async {
    final result = await _productRepository.fetchCategories(
      forceRefresh: forceRefresh,
    );

    result.when(
      onSuccess: (names) {
        final resolved = names.isEmpty ? ProductCategories.fallback : names;
        categories.assignAll([ProductCategories.all, ...resolved]);
        categories.refresh();
        if (!categories.contains(selectedCategory.value)) {
          selectedCategory.value = ProductCategories.all;
        }
      },
      onFailure: (_) {
        if (categories.length <= 1) {
          categories.assignAll([
            ProductCategories.all,
            ...ProductCategories.fallback,
          ]);
          categories.refresh();
        }
      },
    );
  }

  void _ensureOrdersLoaded() {
    if (!Get.isRegistered<OrderController>()) return;

    final orderController = Get.find<OrderController>();
    orderController.bootstrapAfterLogin();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> refreshProducts() async {
    await Future.wait([
      loadCategories(forceRefresh: true),
      loadInitialProducts(forceRefresh: true),
    ]);
  }

  Future<void> loadInitialProducts({bool forceRefresh = false}) async {
    if (isLoading.value && !forceRefresh) return;

    isLoading.value = true;
    isRefreshing.value = forceRefresh;
    _lastDocument = null;
    hasMore.value = true;

    final result = await _productRepository.fetchProducts(
      query: _buildQuery(),
      forceRefresh: forceRefresh,
    );

    await _handlePageResult(result, reset: true);
    isLoading.value = false;
    isRefreshing.value = false;
  }

  Future<void> loadMoreProducts() async {
    if (isLoadingMore.value || !hasMore.value || isLoading.value) return;

    isLoadingMore.value = true;

    final result = await _productRepository.fetchProducts(
      query: _buildQuery(startAfter: _lastDocument),
    );

    await _handlePageResult(result, reset: false);
    isLoadingMore.value = false;
  }

  void onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(AppConfig.searchDebounce, () {
      searchQuery.value = InputValidators.sanitizeSearchQuery(value);
      loadInitialProducts(forceRefresh: true);
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    loadInitialProducts(forceRefresh: true);
  }

  void selectCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    loadInitialProducts(forceRefresh: true);
  }

  void openProductDetail(ProductModel product) {
    Get.toNamed(
      AppRoutes.productDetail,
      arguments: product,
    );
  }

  ProductQuery _buildQuery({
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) {
    return ProductQuery(
      category: selectedCategory.value,
      searchQuery: searchQuery.value,
      startAfter: startAfter,
      limit: AppConfig.defaultPageSize,
    );
  }

  Future<void> _handlePageResult(
    Result<ProductPageResult> result, {
    required bool reset,
  }) async {
    final networkResult = await _productRepository.hasNetworkConnection();

    result.when(
      onSuccess: (page) {
        networkResult.when(
          onSuccess: (isConnected) => isOffline.value = !isConnected,
          onFailure: (_) => isOffline.value = true,
        );

        if (reset) {
          products.assignAll(page.products);
        } else {
          products.addAll(page.products);
        }

        _lastDocument = page.lastDocument;
        hasMore.value = page.hasMore;
      },
      onFailure: (failure) {
        isOffline.value = failure.code != 'permission-denied';
        handleFailure(failure);
      },
    );
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final threshold = scrollController.position.maxScrollExtent - 200;
    if (scrollController.position.pixels >= threshold) {
      loadMoreProducts();
    }
  }
}
