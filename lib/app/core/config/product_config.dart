/// Product-related Firestore field names.
class ProductFields {
  ProductFields._();

  static const String name = 'name';
  static const String nameLowercase = 'nameLowercase';
  static const String description = 'description';
  static const String price = 'price';
  static const String imageUrl = 'imageUrl';
  static const String category = 'category';
  static const String isAvailable = 'isAvailable';
  static const String rating = 'rating';
  static const String createdAt = 'createdAt';
}

class CategoryFields {
  CategoryFields._();

  static const String name = 'name';
  static const String sortOrder = 'sortOrder';
  static const String isActive = 'isActive';
  static const String createdAt = 'createdAt';
}

/// Default menu categories shown in the filter bar.
class ProductCategories {
  ProductCategories._();

  static const String all = 'All';

  /// Used only when Firestore categories are unavailable offline.
  static const List<String> fallback = [
    'Pizza',
    'Burgers',
    'Drinks',
    'Desserts',
    'Salads',
  ];
}
