import 'package:rwnaqk/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/product_color_option.dart';

typedef MockProductIdBuilder = String Function(int seed, int index);
typedef MockProductImageBuilder = String Function(String id);
typedef MockProductDiscountBuilder = int? Function(int index);

class AppMockProductUtils {
  AppMockProductUtils._();

  static List<HomeProductItem> buildProducts(
    int count, {
    required int seed,
    int? discount,
    MockProductDiscountBuilder? discountBuilder,
    MockProductIdBuilder? idBuilder,
    MockProductImageBuilder? imageBuilder,
    String? titlePrefix,
    double basePrice = 17,
    double priceStep = 5,
    String tagKey = '',
    bool includeDetails = false,
  }) {
    final resolvedTitlePrefix =
        titlePrefix ?? AppMockContentUtils.itemTitlePrefix();

    return List.generate(count, (index) {
      final id = idBuilder?.call(seed, index) ?? '${seed}_$index';
      final resolvedDiscount = discountBuilder?.call(index) ?? discount;

      return HomeProductItem(
        id: id,
        title: '$resolvedTitlePrefix $id',
        imageUrl: imageBuilder?.call(id) ?? 'https://picsum.photos/400/500?$id',
        price: basePrice + (index * priceStep).toDouble(),
        discountPercent: resolvedDiscount,
        isNew: index % 3 == 0,
        tagKey: tagKey,
        description: includeDetails ? Mk.productDefaultDescription : '',
        brand: includeDetails ? Mk.productBrand : '',
        sku: includeDetails ? 'SKU-$id' : '',
        stockText: includeDetails ? Mk.productInStock : '',
        soldText: includeDetails
            ? AppMockContentUtils.soldCountText(20 + index * 7)
            : '',
        images: includeDetails ? _detailImages(id) : const [],
        availableColors: includeDetails ? _defaultColors(id) : const [],
        availableSizes: includeDetails ? _defaultSizes : const [],
      );
    });
  }

  static List<String> _detailImages(String id) => [
        'https://picsum.photos/500/650?${id}a',
        'https://picsum.photos/500/650?${id}b',
        'https://picsum.photos/500/650?${id}c',
        'https://picsum.photos/500/650?${id}d',
      ];

  static List<ProductColorOption> _defaultColors(String id) => [
        ProductColorOption(
          id: 'black_$id',
          name: Mk.productColorBlack,
          imageUrl: 'https://picsum.photos/120/120?${id}black',
        ),
        ProductColorOption(
          id: 'white_$id',
          name: Mk.productColorWhite,
          imageUrl: 'https://picsum.photos/120/120?${id}white',
        ),
        ProductColorOption(
          id: 'beige_$id',
          name: Mk.productColorBeige,
          imageUrl: 'https://picsum.photos/120/120?${id}beige',
        ),
      ];

  static const List<String> _defaultSizes = ['S', 'M', 'L', 'XL'];
}
