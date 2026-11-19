import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// خدمة العمليات المحلية الحسابية والقوائم لموديول المفضلة [WishlistService]
class WishlistService {
  /// البداية بقائمة فارغة حقيقية ونظيفة (حذف البيانات الوهمية Mock)
  List<HomeProductItem> initialWishlistItems() => const [];

  /// البداية بقائمة مشاهدات أخيرة فارغة حقيقية ونظيفة
  List<HomeProductItem> initialRecentlyViewedItems() => const [];

  List<HomeProductItem> toggleItem({
    required List<HomeProductItem> currentList,
    required HomeProductItem item,
  }) {
    final exists = currentList.any((e) => e.id == item.id);
    if (exists) {
      return currentList.where((e) => e.id != item.id).toList();
    } else {
      return [item, ...currentList];
    }
  }

  List<HomeProductItem> removeItem({
    required List<HomeProductItem> currentList,
    required HomeProductItem item,
  }) {
    return currentList.where((e) => e.id != item.id).toList();
  }

  List<HomeProductItem> addRecent({
    required List<HomeProductItem> currentList,
    required HomeProductItem item,
  }) {
    final filtered = currentList.where((e) => e.id != item.id).toList();
    return [item, ...filtered];
  }
}
