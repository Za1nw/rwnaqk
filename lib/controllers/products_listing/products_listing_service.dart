import 'package:rwnaqk/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk/core/utils/app_mock_product_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';

class ProductsListingService {
  List<HomeProductItem> resolveItems(dynamic raw) {
    if (raw is List<HomeProductItem>) {
      return raw;
    }
    if (raw is List) {
      return raw.whereType<HomeProductItem>().toList();
    }
    return [];
  }

  List<HomeProductItem> mockProducts({int seed = 1}) {
    return AppMockProductUtils.buildProducts(
      10,
      seed: seed,
      idBuilder: (value, index) => (value * 1000 + index).toString(),
      imageBuilder: (id) => 'https://picsum.photos/400/520?listing=$id',
      titlePrefix: AppMockContentUtils.listingTitlePrefix(),
      basePrice: 12,
      priceStep: 4,
      discountBuilder: (index) {
        final discount = (index % 4 == 0) ? 20 : (index % 7 == 0 ? 35 : 0);
        return discount == 0 ? null : discount;
      },
    );
  }

  List<HomeProductItem> applySort({
    required List<HomeProductItem> list,
    required ListingSort sort,
  }) {
    final out = list.toList();

    switch (sort) {
      case ListingSort.newest:
        return out;
      case ListingSort.priceLow:
        out.sort((a, b) => a.price.compareTo(b.price));
        return out;
      case ListingSort.priceHigh:
        out.sort((a, b) => b.price.compareTo(a.price));
        return out;
      case ListingSort.discountHigh:
        out.sort(
          (a, b) => (b.discountPercent ?? 0).compareTo(a.discountPercent ?? 0),
        );
        return out;
    }
  }

  List<HomeProductItem> applyFilters({
    required List<HomeProductItem> list,
    required dynamic filterResult,
  }) {
    final f = filterResult;

    if (f == null) {
      return list;
    }

    final min = f.priceRange.start;
    final max = f.priceRange.end;

    return list.where((p) {
      if (p.price < min) return false;
      if (p.price > max) return false;
      return true;
    }).toList();
  }
}

enum ListingSort { newest, priceLow, priceHigh, discountHigh }
