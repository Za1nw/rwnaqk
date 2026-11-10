import 'package:rwnaqk_frontend/core/utils/app_mock_product_utils.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

class WishlistService {
  List<HomeProductItem> seedWishlist() {
    return sampleProducts(4, seed: 900, discount: 20, tagKey: 'Pink');
  }

  List<HomeProductItem> seedRecentlyViewed() {
    return sampleProducts(6, seed: 800);
  }

  List<HomeProductItem> initialWishlistItems() => seedWishlist();

  List<HomeProductItem> initialRecentlyViewedItems() => seedRecentlyViewed();

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

  List<HomeProductItem> sampleProducts(
    int count, {
    required int seed,
    int? discount,
    String tagKey = '',
  }) {
    return AppMockProductUtils.buildProducts(
      count,
      seed: seed,
      discount: discount,
      tagKey: tagKey,
    );
  }
}
