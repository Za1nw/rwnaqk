import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// خدمة حسابات ومطابقة خصومات التخفيضات الكبرى [FlashSaleService]
class FlashSaleService {
  List<int> get discounts => const [0, 10, 20, 30, 40, 50];

  List<HomeProductItem> filterByDiscount(
    List<HomeProductItem> items,
    int selectedDiscount,
  ) {
    if (selectedDiscount <= 0) return items;
    return items
        .where((p) => (p.discountPercent ?? 0) >= selectedDiscount)
        .toList();
  }
}
