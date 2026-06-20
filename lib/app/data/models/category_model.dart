import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taste_o_clock/app/core/config/product_config.dart';

class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
  });

  final String id;
  final String name;
  final int sortOrder;
  final bool isActive;

  static CategoryModel? tryFromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    if (data == null || data.isEmpty) return null;

    final name = _readName(data, doc.id);
    if (name.isEmpty) return null;

    return CategoryModel(
      id: doc.id,
      name: name,
      sortOrder: _readInt(data[CategoryFields.sortOrder]),
      isActive: _readBool(data[CategoryFields.isActive], defaultValue: true),
    );
  }

  static String _readName(Map<String, dynamic> data, String docId) {
    for (final key in const [
      CategoryFields.name,
      'title',
      'categoryName',
      'label',
      'category',
    ]) {
      final value = _readString(data[key]);
      if (value.isNotEmpty) return value;
    }

    return _formatDocId(docId);
  }

  static String _formatDocId(String docId) {
    final normalized = docId.trim().replaceAll('_', ' ').replaceAll('-', ' ');
    if (normalized.isEmpty) return '';

    return normalized
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              part[0].toUpperCase() + (part.length > 1 ? part.substring(1) : ''),
        )
        .join(' ');
  }

  Map<String, dynamic> toFirestore() {
    return {
      CategoryFields.name: name,
      CategoryFields.sortOrder: sortOrder,
      CategoryFields.isActive: isActive,
    };
  }

  static String _readString(Object? value) {
    if (value == null) return '';
    return value.toString().trim();
  }

  static int _readInt(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static bool _readBool(Object? value, {required bool defaultValue}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return defaultValue;
  }
}
