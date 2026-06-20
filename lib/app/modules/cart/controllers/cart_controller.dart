import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/controllers/base_controller.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';
import 'package:taste_o_clock/app/data/repositories/cart_repository.dart';
import 'package:taste_o_clock/app/modules/main_shell/controllers/main_shell_controller.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';
import 'package:taste_o_clock/app/utils/helpers.dart';

class CartController extends BaseController {
  CartController({CartRepository? cartRepository})
      : _cartRepository = cartRepository ?? Get.find<CartRepository>();

  final CartRepository _cartRepository;

  final RxList<CartItemModel> items = <CartItemModel>[].obs;
  final RxInt totalItems = 0.obs;
  final RxDouble subtotal = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  Future<void> loadCart() async {
    final result = await _cartRepository.getItems();
    result.when(
      onSuccess: _applyItems,
      onFailure: handleFailure,
    );
  }

  Future<void> addProduct(ProductModel product, {int quantity = 1}) async {
    final result = await _cartRepository.addProduct(
      product,
      quantity: quantity,
    );

    result.when(
      onSuccess: (updatedItems) {
        _applyItems(updatedItems);
        Helpers.showSuccess('${product.name} added to cart');
      },
      onFailure: handleFailure,
    );
  }

  Future<void> incrementItem(String productId) async {
    final result = await _cartRepository.incrementQuantity(productId);
    result.when(
      onSuccess: _applyItems,
      onFailure: handleFailure,
    );
  }

  Future<void> decrementItem(String productId) async {
    final result = await _cartRepository.decrementQuantity(productId);
    result.when(
      onSuccess: _applyItems,
      onFailure: handleFailure,
    );
  }

  Future<void> removeItem(String productId) async {
    final result = await _cartRepository.removeItem(productId);
    result.when(
      onSuccess: _applyItems,
      onFailure: handleFailure,
    );
  }

  Future<void> clearCart() async {
    if (items.isEmpty) return;

    final result = await _cartRepository.clearCart();
    result.when(
      onSuccess: _applyItems,
      onFailure: handleFailure,
    );
  }

  void openCart() {
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().switchTo(MainShellTab.cart);
      return;
    }
    Get.toNamed(AppRoutes.cart);
  }

  int quantityForProduct(String productId) {
    return items
            .firstWhereOrNull((item) => item.productId == productId)
            ?.quantity ??
        0;
  }

  void _applyItems(List<CartItemModel> updatedItems) {
    items.assignAll(updatedItems);
    final summary = _cartRepository.summarize(updatedItems);
    totalItems.value = summary.totalItems;
    subtotal.value = summary.subtotal;
  }
}
