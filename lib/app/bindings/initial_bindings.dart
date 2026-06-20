import 'package:get/get.dart';
import 'package:taste_o_clock/app/data/repositories/auth_repository.dart';
import 'package:taste_o_clock/app/data/repositories/auth_repository_impl.dart';
import 'package:taste_o_clock/app/data/repositories/cart_repository.dart';
import 'package:taste_o_clock/app/data/repositories/cart_repository_impl.dart';
import 'package:taste_o_clock/app/data/repositories/notification_repository.dart';
import 'package:taste_o_clock/app/data/repositories/notification_repository_impl.dart';
import 'package:taste_o_clock/app/data/repositories/order_repository.dart';
import 'package:taste_o_clock/app/data/repositories/order_repository_impl.dart';
import 'package:taste_o_clock/app/data/services/auth_service.dart';
import 'package:taste_o_clock/app/data/services/cart_service.dart';
import 'package:taste_o_clock/app/data/services/firebase_service.dart';
import 'package:taste_o_clock/app/data/repositories/user_repository.dart';
import 'package:taste_o_clock/app/data/repositories/user_repository_impl.dart';
import 'package:taste_o_clock/app/data/services/location_service.dart';
import 'package:taste_o_clock/app/data/services/notification_cache_service.dart';
import 'package:taste_o_clock/app/data/services/notification_service.dart';
import 'package:taste_o_clock/app/data/services/order_service.dart';
import 'package:taste_o_clock/app/data/services/storage_service.dart';
import 'package:taste_o_clock/app/modules/auth/controllers/auth_controller.dart';
import 'package:taste_o_clock/app/modules/cart/controllers/cart_controller.dart';
import 'package:taste_o_clock/app/modules/notification/controllers/notification_controller.dart';
import 'package:taste_o_clock/app/modules/order/controllers/order_controller.dart';

/// Global dependency graph for the application.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    _registerCoreServices();
    _registerRepositories();
    _registerGlobalControllers();
  }

  void _registerCoreServices() {
    Get.lazyPut<FirebaseService>(() => FirebaseService(), fenix: true);
    Get.lazyPut<StorageService>(() => StorageService(), fenix: true);
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<CartService>(
      () => CartService(storageService: Get.find<StorageService>()),
      fenix: true,
    );
    Get.lazyPut<LocationService>(() => LocationService(), fenix: true);
    Get.lazyPut<OrderService>(
      () => OrderService(firebaseService: Get.find<FirebaseService>()),
      fenix: true,
    );
    Get.lazyPut<NotificationCacheService>(
      () => NotificationCacheService(
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<NotificationService>(
      () => NotificationService(),
      fenix: true,
    );
  }

  void _registerRepositories() {
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(
        authService: Get.find<AuthService>(),
        firebaseService: Get.find<FirebaseService>(),
        storageService: Get.find<StorageService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<CartRepository>(
      () => CartRepositoryImpl(cartService: Get.find<CartService>()),
      fenix: true,
    );
    Get.lazyPut<OrderRepository>(
      () => OrderRepositoryImpl(orderService: Get.find<OrderService>()),
      fenix: true,
    );
    Get.lazyPut<UserRepository>(
      () => UserRepositoryImpl(
        firebaseService: Get.find<FirebaseService>(),
        locationService: Get.find<LocationService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<NotificationRepository>(
      () => NotificationRepositoryImpl(
        notificationService: Get.find<NotificationService>(),
        notificationCacheService: Get.find<NotificationCacheService>(),
      ),
      fenix: true,
    );
  }

  void _registerGlobalControllers() {
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<CartController>(CartController(), permanent: true);
    Get.put<OrderController>(OrderController(), permanent: true);
    Get.put<NotificationController>(NotificationController(), permanent: true);
  }
}
