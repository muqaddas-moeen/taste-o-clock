class UserLocationModel {
  const UserLocationModel({
    required this.latitude,
    required this.longitude,
    this.addressLine,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.updatedAt,
  });

  final double latitude;
  final double longitude;
  final String? addressLine;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final DateTime? updatedAt;

  String get formattedAddress {
    final parts = [
      addressLine,
      city,
      state,
      postalCode,
      country,
    ].where((part) => part != null && part.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
    }

    return parts.join(', ');
  }

  bool get hasCoordinates => latitude != 0 || longitude != 0;

  factory UserLocationModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return const UserLocationModel(latitude: 0, longitude: 0);
    }

    return UserLocationModel(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
      addressLine: map['addressLine'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      postalCode: map['postalCode'] as String?,
      country: map['country'] as String?,
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserLocationModel copyWith({
    double? latitude,
    double? longitude,
    String? addressLine,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    DateTime? updatedAt,
  }) {
    return UserLocationModel(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
