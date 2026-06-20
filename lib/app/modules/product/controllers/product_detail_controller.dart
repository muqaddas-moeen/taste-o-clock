import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/controllers/base_controller.dart';
import 'package:taste_o_clock/app/core/errors/failure.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';
import 'package:taste_o_clock/app/data/repositories/product_repository.dart';
import 'package:taste_o_clock/app/modules/cart/controllers/cart_controller.dart';

class ProductDetailController extends BaseController {
  ProductDetailController({ProductRepository? productRepository})
      : _productRepository = productRepository ?? Get.find<ProductRepository>();

  final ProductRepository _productRepository;
  late final CartController _cartController;

  final Rxn<ProductModel> product = Rxn<ProductModel>();
  final RxInt quantity = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _cartController = Get.find<CartController>();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final argumentProduct = Get.arguments;
    if (argumentProduct is ProductModel) {
      product.value = argumentProduct;
      await _productRepository.cacheRecentlyViewed(argumentProduct);
      return;
    }

    final productId = Get.parameters['id'];
    if (productId == null || productId.isEmpty) {
      handleFailure(
        const AppFailure(
          code: 'missing_product',
          message: 'Product not found.',
        ),
      );
      return;
    }

    isLoading.value = true;
    final result = await _productRepository.getProductById(productId);
    isLoading.value = false;

    result.when(
      onSuccess: (loadedProduct) {
        if (loadedProduct == null) {
          handleFailure(
            const AppFailure(
              code: 'missing_product',
              message: 'Product not found.',
            ),
          );
          return;
        }

        product.value = loadedProduct;
        _productRepository.cacheRecentlyViewed(loadedProduct);
      },
      onFailure: handleFailure,
    );
  }

  void incrementQuantity() {
    if (quantity.value < 99) {
      quantity.value++;
    }
  }

  void decrementQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
    }
  }

  Future<void> addToCart() async {
    final currentProduct = product.value;
    if (currentProduct == null || !currentProduct.isAvailable) {
      return;
    }

    await _cartController.addProduct(currentProduct, quantity: quantity.value);
  }
}
