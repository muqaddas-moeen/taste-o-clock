import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/config/firebase_collections.dart';
import 'package:taste_o_clock/app/core/enums/order_status.dart';
import 'package:taste_o_clock/app/data/models/order_item_model.dart';
import 'package:taste_o_clock/app/data/models/user_payment_info_model.dart';
class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.totalItems,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.deliveryAddress,
    this.paymentMethod,
    this.paymentStatus,
  });

  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final int totalItems;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? deliveryAddress;
  final String? paymentMethod;
  final String? paymentStatus;

  String get paymentMethodLabel {
    final method = PaymentMethod.fromFirestore(paymentMethod);
    return method?.label ?? paymentMethod ?? 'Unknown';
  }

  String get paymentStatusLabel {
    return switch (paymentStatus) {
      'paid' => 'Paid',
      'cash_on_delivery' => 'Pay on delivery',
      'pending' => 'Payment pending',
      null || '' => 'Unknown',
      _ => paymentStatus!,
    };
  }

  String get paymentSummaryLabel {
    final method = PaymentMethod.fromFirestore(paymentMethod);
    if (method == PaymentMethod.cashOnDelivery) {
      return 'Cash on Delivery';
    }
    if (method == PaymentMethod.card) {
      return paymentStatus == 'paid' ? 'Card (Paid)' : 'Card';
    }
    return paymentMethodLabel;
  }

  bool get isActive => status != OrderStatus.delivered;

  String get deliveryAddressLabel {
    final address = deliveryAddress;
    if (address == null) return 'No delivery address';

    final parts = [
      address['addressLine'],
      address['city'],
      address['state'],
      address['postalCode'],
      address['country'],
    ]
        .whereType<String>()
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return 'Delivery address saved';
    return parts.join(', ');
  }

  static OrderModel? tryFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null) return null;

    final status = OrderStatus.fromFirestore(data[OrderFields.status] as String?);
    if (status == null) return null;

    final rawItems = data[OrderFields.items];
    if (rawItems is! List || rawItems.isEmpty) return null;

    final items = rawItems
        .whereType<Map>()
        .map(OrderItemModel.fromMap)
        .where((item) => item.productId.isNotEmpty && item.quantity > 0)
        .toList();

    if (items.isEmpty) return null;

    final createdAt = _readTimestamp(data[OrderFields.createdAt]);
    final updatedAt = _readTimestamp(data[OrderFields.updatedAt]);
    final deliveryAddress = data[OrderFields.deliveryAddress];
    Map<String, dynamic>? parsedAddress;
    if (deliveryAddress is Map) {
      parsedAddress = Map<String, dynamic>.from(deliveryAddress);
    }

    return OrderModel(
      id: doc.id,
      userId: data[OrderFields.userId] as String? ?? '',
      items: items,
      subtotal: (data[OrderFields.subtotal] as num?)?.toDouble() ?? 0,
      totalItems: (data[OrderFields.totalItems] as num?)?.toInt() ?? 0,
      status: status,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
      deliveryAddress: parsedAddress,
      paymentMethod: data[OrderFields.paymentMethod] as String?,
      paymentStatus: data[OrderFields.paymentStatus] as String?,
    );
  }

  Map<String, dynamic> toFirestore({required DateTime now}) {
    return {
      OrderFields.userId: userId,
      OrderFields.status: OrderStatus.placed.firestoreValue,
      OrderFields.items: items.map((item) => item.toMap()).toList(),
      OrderFields.subtotal: subtotal,
      OrderFields.totalItems: totalItems,
      OrderFields.deliveryAddress: deliveryAddress,
      OrderFields.paymentMethod: paymentMethod,
      OrderFields.paymentStatus: paymentStatus,
      OrderFields.createdAt: Timestamp.fromDate(now),
      OrderFields.updatedAt: Timestamp.fromDate(now),
    };
  }

  static DateTime? _readTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }
}
