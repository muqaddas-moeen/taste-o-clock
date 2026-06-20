enum PaymentMethod {
  card,
  cashOnDelivery;

  String get label => switch (this) {
        PaymentMethod.card => 'Card',
        PaymentMethod.cashOnDelivery => 'Cash on Delivery',
      };

  String get firestoreValue => switch (this) {
        PaymentMethod.card => 'card',
        PaymentMethod.cashOnDelivery => 'cash_on_delivery',
      };

  static PaymentMethod? fromFirestore(String? value) {
    return switch (value) {
      'card' => PaymentMethod.card,
      'cash_on_delivery' => PaymentMethod.cashOnDelivery,
      _ => null,
    };
  }
}

class UserPaymentInfoModel {
  const UserPaymentInfoModel({
    required this.paymentMethod,
    this.cardHolderName,
    this.cardLast4,
    this.cardBrand,
    this.updatedAt,
  });

  final PaymentMethod paymentMethod;
  final String? cardHolderName;
  final String? cardLast4;
  final String? cardBrand;
  final DateTime? updatedAt;

  bool get isComplete {
    if (paymentMethod == PaymentMethod.cashOnDelivery) return true;

    final last4 = cardLast4?.trim();
    return (cardHolderName?.trim().isNotEmpty ?? false) &&
        last4 != null &&
        last4.length == 4 &&
        RegExp(r'^\d{4}$').hasMatch(last4);
  }

  String get displayLabel {
    if (paymentMethod == PaymentMethod.cashOnDelivery) {
      return PaymentMethod.cashOnDelivery.label;
    }

    final brand = cardBrand?.trim();
    final last4 = cardLast4?.trim();
    if (brand != null && brand.isNotEmpty && last4 != null && last4.isNotEmpty) {
      return '$brand •••• $last4';
    }
    if (last4 != null && last4.isNotEmpty) {
      return 'Card •••• $last4';
    }
    return PaymentMethod.card.label;
  }

  factory UserPaymentInfoModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const UserPaymentInfoModel(
        paymentMethod: PaymentMethod.cashOnDelivery,
      );
    }

    return UserPaymentInfoModel(
      paymentMethod:
          PaymentMethod.fromFirestore(map['paymentMethod'] as String?) ??
              PaymentMethod.cashOnDelivery,
      cardHolderName: map['cardHolderName'] as String?,
      cardLast4: map['cardLast4'] as String?,
      cardBrand: map['cardBrand'] as String?,
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'paymentMethod': paymentMethod.firestoreValue,
      'cardHolderName': cardHolderName,
      'cardLast4': cardLast4,
      'cardBrand': cardBrand,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserPaymentInfoModel copyWith({
    PaymentMethod? paymentMethod,
    String? cardHolderName,
    String? cardLast4,
    String? cardBrand,
    DateTime? updatedAt,
  }) {
    return UserPaymentInfoModel(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      cardLast4: cardLast4 ?? this.cardLast4,
      cardBrand: cardBrand ?? this.cardBrand,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
