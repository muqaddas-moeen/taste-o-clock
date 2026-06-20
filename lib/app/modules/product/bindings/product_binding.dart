import 'package:get/get.dart';
import 'package:taste_o_clock/app/data/repositories/product_repository.dart';
import 'package:taste_o_clock/app/data/repositories/product_repository_impl.dart';
import 'package:taste_o_clock/app/data/services/product_service.dart';
import 'package:taste_o_clock/app/data/services/storage_service.dart';
import 'package:taste_o_clock/app/modules/product/controllers/product_detail_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProductService>()) {
      Get.lazyPut<ProductService>(() => ProductService(), fenix: true);
    }

    if (!Get.isRegistered<ProductRepository>()) {
      Get.lazyPut<ProductRepository>(
        () => ProductRepositoryImpl(
          productService: Get.find<ProductService>(),
          storageService: Get.find<StorageService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProductDetailController>()) {
      Get.lazyPut<ProductDetailController>(
        () => ProductDetailController(),
        fenix: true,
      );
    }
  }
}
