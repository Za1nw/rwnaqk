import 'package:rwnaqk/core/utils/app_mock_product_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';

class WishlistService {
  List<HomeProductItem> seedWishlist() {
    return sampleProducts(
      4,
      seed: 900,
      discount: 20,
      tagKey: 'Pink',
    );
  }

  List<HomeProductItem> seedRecentlyViewed() {
    return sampleProducts(6, seed: 800);
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
