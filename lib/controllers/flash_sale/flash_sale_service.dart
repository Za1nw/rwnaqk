import 'package:rwnaqk/core/utils/app_mock_product_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';

class FlashSaleService {
  List<int> get discounts => const [0, 10, 20, 30, 40, 50];

  List<HomeProductItem> loadFlashSaleProducts({
    required int selectedDiscount,
  }) {
    return sampleProducts(
      10,
      seed: 1000,
      discount: selectedDiscount,
    );
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
