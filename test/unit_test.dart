import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taste_o_clock/app/core/config/product_config.dart';
import 'package:taste_o_clock/app/core/enums/notification_type.dart';
import 'package:taste_o_clock/app/core/enums/order_status.dart';
import 'package:taste_o_clock/app/core/utils/auth_failure_mapper.dart';
import 'package:taste_o_clock/app/core/utils/input_validators.dart';
import 'package:taste_o_clock/app/core/utils/order_validators.dart';
import 'package:taste_o_clock/app/data/models/category_model.dart';
import 'package:taste_o_clock/app/data/models/cart_hive_model.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/data/models/notification_hive_model.dart';
import 'package:taste_o_clock/app/data/models/notification_model.dart';
import 'package:taste_o_clock/app/data/models/order_model.dart';
import 'package:taste_o_clock/app/data/models/order_item_model.dart';
import 'package:taste_o_clock/app/data/models/product_hive_model.dart';
import 'package:taste_o_clock/app/data/models/product_model.dart';
import 'package:taste_o_clock/app/data/models/user_model.dart';
import 'package:taste_o_clock/app/data/models/user_location_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';
import 'package:taste_o_clock/app/routes/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('exposes core navigation paths', () {
      expect(AppRoutes.splash, '/splash');
      expect(AppRoutes.login, '/login');
      expect(AppRoutes.productList, '/products');
      expect(AppRoutes.productDetail, '/product-detail');
      expect(AppRoutes.cart, '/cart');
      expect(AppRoutes.checkout, '/checkout');
      expect(AppRoutes.orders, '/orders');
      expect(AppRoutes.orderTracking, '/order-tracking');
      expect(AppRoutes.notifications, '/notifications');
      expect(AppRoutes.profile, '/profile');
    });
  });

  group('UserLocationModel', () {
    test('formats address parts into readable string', () {
      const location = UserLocationModel(
        latitude: 12.34,
        longitude: 56.78,
        addressLine: '221B Baker Street',
        city: 'London',
      );

      expect(location.formattedAddress, contains('Baker Street'));
      expect(location.formattedAddress, contains('London'));
    });
  });

  group('UserPaymentInfoModel', () {
    test('cash on delivery is complete without card details', () {
      const payment = UserPaymentInfoModel(
        paymentMethod: PaymentMethod.cashOnDelivery,
      );

      expect(payment.isComplete, isTrue);
    });
  });

  group('OrderModel payment labels', () {
    test('shows cash on delivery on order detail', () {
      final order = OrderModel(
        id: 'o1',
        userId: 'u1',
        items: const [],
        subtotal: 10,
        totalItems: 1,
        status: OrderStatus.placed,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        paymentMethod: 'cash_on_delivery',
        paymentStatus: 'cash_on_delivery',
      );

      expect(order.paymentSummaryLabel, 'Cash on Delivery');
      expect(order.paymentStatusLabel, 'Pay on delivery');
    });

    test('shows paid card on order detail', () {
      final order = OrderModel(
        id: 'o2',
        userId: 'u1',
        items: const [],
        subtotal: 25,
        totalItems: 2,
        status: OrderStatus.placed,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
        paymentMethod: 'card',
        paymentStatus: 'paid',
      );

      expect(order.paymentSummaryLabel, 'Card (Paid)');
      expect(order.paymentStatusLabel, 'Paid');
    });
  });

  group('NotificationType', () {
    test('maps firestore values', () {
      expect(
        NotificationType.fromFirestore('order_status'),
        NotificationType.orderStatus,
      );
      expect(
        NotificationType.orderStatus.firestoreValue,
        'order_status',
      );
    });
  });

  group('NotificationHiveModel', () {
    test('round trips through map serialization', () {
      final notification = NotificationModel(
        id: 'n1',
        userId: 'u1',
        title: 'Order update',
        body: 'Your order is preparing',
        type: NotificationType.orderStatus,
        isRead: false,
        createdAt: DateTime(2026, 6, 20),
        orderId: 'o1',
      );

      final hiveModel = NotificationHiveModel.fromNotification(notification);
      final restored =
          NotificationHiveModel.fromMap(hiveModel.toMap()).toNotification();

      expect(restored.id, notification.id);
      expect(restored.title, notification.title);
      expect(restored.orderId, notification.orderId);
    });
  });

  group('OrderStatus', () {
    test('maps firestore values', () {
      expect(OrderStatus.fromFirestore('placed'), OrderStatus.placed);
      expect(OrderStatus.fromFirestore('on_the_way'), OrderStatus.onTheWay);
      expect(OrderStatus.placed.firestoreValue, 'placed');
    });
  });

  group('OrderItemModel', () {
    test('round trips through map serialization', () {
      final cartItem = CartItemModel(
        productId: 'p1',
        name: 'Burger',
        unitPrice: 8.5,
        imageUrl: 'https://example.com/burger.jpg',
        quantity: 2,
        addedAt: DateTime(2026, 1, 1),
      );

      final orderItem = OrderItemModel.fromCartItem(cartItem);
      final restored = OrderItemModel.fromMap(orderItem.toMap());

      expect(restored.productId, cartItem.productId);
      expect(restored.quantity, cartItem.quantity);
      expect(restored.lineTotal, 17);
    });
  });

  group('CartItemModel', () {
    test('calculates line total from quantity and unit price', () {
      final item = CartItemModel(
        productId: 'p1',
        name: 'Burger',
        unitPrice: 9.5,
        imageUrl: 'https://example.com/burger.jpg',
        quantity: 3,
        addedAt: DateTime(2026, 1, 1),
      );

      expect(item.lineTotal, 28.5);
    });
  });

  group('CartSummary', () {
    test('aggregates item count and subtotal', () {
      final items = [
        CartItemModel(
          productId: 'p1',
          name: 'Burger',
          unitPrice: 10,
          imageUrl: '',
          quantity: 2,
          addedAt: DateTime(2026, 1, 1),
        ),
        CartItemModel(
          productId: 'p2',
          name: 'Fries',
          unitPrice: 4.5,
          imageUrl: '',
          quantity: 1,
          addedAt: DateTime(2026, 1, 1),
        ),
      ];

      final summary = CartSummary.fromItems(items);

      expect(summary.totalItems, 3);
      expect(summary.subtotal, 24.5);
    });
  });

  group('CartHiveModel', () {
    test('round trips through map serialization', () {
      final item = CartItemModel(
        productId: 'p1',
        name: 'Burger',
        unitPrice: 12.5,
        imageUrl: 'https://example.com/burger.jpg',
        quantity: 2,
        addedAt: DateTime(2026, 6, 20),
      );

      final hiveModel = CartHiveModel.fromCartItem(item);
      final restored = CartHiveModel.fromMap(hiveModel.toMap()).toCartItem();

      expect(restored.productId, item.productId);
      expect(restored.quantity, item.quantity);
      expect(restored.unitPrice, item.unitPrice);
    });
  });

  group('ProductHiveModel', () {
    test('round trips through map serialization', () {
      final product = ProductModel(
        id: 'p1',
        name: 'Margherita Pizza',
        description: 'Classic cheese pizza',
        price: 12.99,
        imageUrl: 'https://example.com/pizza.jpg',
        category: 'Pizza',
        isAvailable: true,
        rating: 4.5,
        createdAt: DateTime(2026, 1, 1),
      );

      final hiveModel = ProductHiveModel.fromProduct(product);
      final restored = ProductHiveModel.fromMap(hiveModel.toMap()).toProduct();

      expect(restored.id, product.id);
      expect(restored.name, product.name);
      expect(restored.price, product.price);
      expect(restored.category, product.category);
    });
  });

  group('CategoryModel', () {
    test('reads alternate firestore field names', () {
      final category = CategoryModel.tryFromFirestore(
        _FakeCategoryDoc(
          id: 'burgers',
          data: const {'title': 'Burgers', 'sortOrder': 2, 'isActive': true},
        ),
      );

      expect(category?.name, 'Burgers');
    });

    test('falls back to document id when name field is missing', () {
      final category = CategoryModel.tryFromFirestore(
        _FakeCategoryDoc(
          id: 'ice_cream',
          data: const {'sortOrder': 3, 'isActive': true},
        ),
      );

      expect(category?.name, 'Ice Cream');
    });
  });

  group('ProductCategories', () {
    test('fallback list excludes All', () {
      expect(ProductCategories.fallback, isNot(contains(ProductCategories.all)));
      expect(ProductCategories.fallback, isNotEmpty);
    });
  });

  group('AuthFailureMapper', () {
    test('maps known firebase auth codes', () {
      final failure = AuthFailureMapper.fromCode('user-disabled');
      expect(failure.message, contains('disabled'));
    });
  });

  group('UserModel', () {
    test('builds initials from display name', () {
      final user = UserModel(
        id: '1',
        email: 'test@example.com',
        displayName: 'John Doe',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(user.initials, 'JD');
    });
  });

  group('InputValidators', () {
    test('sanitizes search query length', () {
      final query = InputValidators.sanitizeSearchQuery('  burger  ');
      expect(query, 'burger');
    });

    test('rejects invalid card last4', () {
      expect(InputValidators.validateCardLast4('12ab'), isNotNull);
      expect(InputValidators.validateCardLast4('1234'), isNull);
    });

    test('accepts optional phone when empty', () {
      expect(InputValidators.validatePhone(''), isNull);
      expect(InputValidators.validatePhone('+1 555 123 4567'), isNull);
    });
  });

  group('OrderValidators', () {
    test('rejects paid status for cash on delivery', () {
      final result = OrderValidators.validateCartForOrder(
        items: [
          CartItemModel(
            productId: '1',
            name: 'Burger',
            imageUrl: '',
            unitPrice: 10,
            quantity: 1,
            addedAt: DateTime(2026, 1, 1),
          ),
        ],
        paymentStatus: 'paid',
        paymentMethod: PaymentMethod.cashOnDelivery,
      );

      expect(result.isFailure, isTrue);
    });
  });
}

// ignore: subtype_of_sealed_class
class _FakeCategoryDoc implements DocumentSnapshot<Map<String, dynamic>> {
  _FakeCategoryDoc({required this.id, required Map<String, dynamic> data})
      : _data = data;

  @override
  final String id;

  final Map<String, dynamic> _data;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
