import 'package:get/get.dart';
import 'package:taste_o_clock/app/core/middleware/auth_middleware.dart';
import 'package:taste_o_clock/app/core/middleware/guest_middleware.dart';
import 'package:taste_o_clock/app/core/animations/app_animations.dart';
import 'package:taste_o_clock/app/modules/auth/bindings/auth_binding.dart';
import 'package:taste_o_clock/app/modules/auth/views/auth_view.dart';
import 'package:taste_o_clock/app/modules/cart/bindings/cart_binding.dart';
import 'package:taste_o_clock/app/modules/cart/views/cart_view.dart';
import 'package:taste_o_clock/app/modules/checkout/bindings/checkout_binding.dart';
import 'package:taste_o_clock/app/modules/checkout/views/checkout_view.dart';
import 'package:taste_o_clock/app/modules/notification/bindings/notification_binding.dart';
import 'package:taste_o_clock/app/modules/notification/views/notification_view.dart';
import 'package:taste_o_clock/app/modules/order/bindings/order_binding.dart';
import 'package:taste_o_clock/app/modules/order/views/order_list_view.dart';
import 'package:taste_o_clock/app/modules/order/views/order_tracking_view.dart';
import 'package:taste_o_clock/app/modules/profile/bindings/profile_binding.dart';
import 'package:taste_o_clock/app/modules/profile/views/profile_view.dart';
import 'package:taste_o_clock/app/modules/main_shell/bindings/main_shell_binding.dart';
import 'package:taste_o_clock/app/modules/main_shell/views/main_shell_view.dart';
import 'package:taste_o_clock/app/modules/product/bindings/product_binding.dart';
import 'package:taste_o_clock/app/modules/product/views/product_detail_view.dart';
import 'package:taste_o_clock/app/modules/splash/bindings/splash_binding.dart';
import 'package:taste_o_clock/app/modules/splash/views/splash_view.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: AppPageTransitions.fade,
      transitionDuration: AppPageTransitions.duration,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const AuthView(),
      binding: AuthBinding(),
      middlewares: [GuestMiddleware()],
      transition: AppPageTransitions.fade,
      transitionDuration: AppPageTransitions.duration,
    ),
    GetPage(
      name: AppRoutes.productList,
      page: () => const MainShellView(),
      binding: MainShellBinding(),
      middlewares: [AuthMiddleware()],
      transition: AppPageTransitions.fade,
      transitionDuration: AppPageTransitions.duration,
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductBinding(),
      middlewares: [AuthMiddleware()],
      transition: AppPageTransitions.detail,
      transitionDuration: AppPageTransitions.duration,
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
      middlewares: [AuthMiddleware()],
      transition: AppPageTransitions.modal,
      transitionDuration: AppPageTransitions.duration,
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
      middlewares: [AuthMiddleware()],
      transition: AppPageTransitions.detail,
      transitionDuration: AppPageTransitions.duration,
    ),
    GetPage(
      name: AppRoutes.orders,
      page: () => const OrderListView(),
      binding: OrderListBinding(),
      middlewares: [AuthMiddleware()],
      transition: AppPageTransitions.standard,
      transitionDuration: AppPageTransitions.duration,
    ),
    GetPage(
      name: AppRoutes.orderTracking,
      page: () => const OrderTrackingView(),
      binding: OrderTrackingBinding(),
      middlewares: [AuthMiddleware()],
      transition: AppPageTransitions.detail,
      transitionDuration: AppPageTransitions.duration,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
      middlewares: [AuthMiddleware()],
      transition: AppPageTransitions.standard,
      transitionDuration: AppPageTransitions.duration,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()],
      transition: AppPageTransitions.standard,
      transitionDuration: AppPageTransitions.duration,
    ),
  ];
}
