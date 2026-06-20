import 'package:taste_o_clock/app/core/config/hive_boxes.dart';
import 'package:taste_o_clock/app/data/models/cart_hive_model.dart';
import 'package:taste_o_clock/app/data/models/cart_item_model.dart';
import 'package:taste_o_clock/app/data/services/storage_service.dart';

class CartService {
  CartService({StorageService? storageService})
      : _storageService = storageService ?? StorageService();

  final StorageService _storageService;

  Future<List<CartItemModel>> readItems() async {
    final box = _storageService.cartBox;
    final ids = (box.get(HiveKeys.cartItemIds) as List?)?.cast<String>() ?? [];

    return ids
        .map((id) {
          final map = box.get(HiveKeys.cartItemKey(id));
          if (map is! Map) return null;
          return CartHiveModel.fromMap(map).toCartItem();
        })
        .whereType<CartItemModel>()
        .toList();
  }

  Future<void> writeItems(List<CartItemModel> items) async {
    final box = _storageService.cartBox;
    final ids = items.map((item) => item.productId).toList();

    for (final item in items) {
      await box.put(
        HiveKeys.cartItemKey(item.productId),
        CartHiveModel.fromCartItem(item).toMap(),
      );
    }

    final existingIds =
        (box.get(HiveKeys.cartItemIds) as List?)?.cast<String>() ?? [];
    for (final oldId in existingIds) {
      if (!ids.contains(oldId)) {
        await box.delete(HiveKeys.cartItemKey(oldId));
      }
    }

    await box.put(HiveKeys.cartItemIds, ids);
  }

  Future<void> clear() async {
    final box = _storageService.cartBox;
    final ids = (box.get(HiveKeys.cartItemIds) as List?)?.cast<String>() ?? [];

    for (final id in ids) {
      await box.delete(HiveKeys.cartItemKey(id));
    }

    await box.delete(HiveKeys.cartItemIds);
  }
}
