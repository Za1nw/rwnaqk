import 'package:rwnaqk/core/utils/app_mock_product_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';

class SearchService {
  List<String> initialHistory() {
    return ['Socks', 'Red Dress', 'Sunglasses', 'Mustard Pants', '80-s Skirt'];
  }

  List<String> initialRecommendations() {
    return ['Skirt', 'Accessories', 'Black T-Shirt', 'Jeans', 'White Shoes'];
  }

  List<HomeProductItem> sampleProducts(int count, {required int seed}) {
    return AppMockProductUtils.buildProducts(
      count,
      seed: seed,
      basePrice: 12,
      discountBuilder: (index) => index % 4 == 0 ? 15 : null,
    );
  }

  List<HomeProductItem> runLocalSearch({
    required List<HomeProductItem> source,
    required String rawQuery,
  }) {
    final q = rawQuery.trim().toLowerCase();

    if (q.isEmpty) {
      return <HomeProductItem>[];
    }

    return source.where((item) {
      return item.title.toLowerCase().contains(q);
    }).toList();
  }

  List<String> commitToHistory({
    required List<String> currentHistory,
    required String query,
    int maxLength = 10,
  }) {
    final text = query.trim();
    if (text.isEmpty) {
      return currentHistory;
    }

    final updated = currentHistory.toList();
    updated.removeWhere((e) => e.toLowerCase() == text.toLowerCase());
    updated.insert(0, text);

    if (updated.length > maxLength) {
      updated.removeRange(maxLength, updated.length);
    }

    return updated;
  }
}
