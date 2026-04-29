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
        purchaseLimit: includeDetails ? _purchaseLimitFor(index) : null,
        sizeGuide: includeDetails ? _sizeGuideRows(index) : const [],
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

  static ProductPurchaseLimit? _purchaseLimitFor(int index) {
    if (index.isOdd) return null;

    return ProductPurchaseLimit(
      minQty: 1,
      maxQty: index % 3 == 0 ? 3 : 5,
      stepQty: index % 4 == 0 ? 2 : 1,
    );
  }

  static List<ProductSizeGuideRow> _sizeGuideRows(int index) {
    final offset = index % 3;

    return [
      ProductSizeGuideRow(
        size: 'S',
        chest: '${84 + offset}',
        waist: '${66 + offset}',
        hips: '${92 + offset}',
        length: '${58 + offset}',
      ),
      ProductSizeGuideRow(
        size: 'M',
        chest: '${88 + offset}',
        waist: '${70 + offset}',
        hips: '${96 + offset}',
        length: '${60 + offset}',
      ),
      ProductSizeGuideRow(
        size: 'L',
        chest: '${92 + offset}',
        waist: '${74 + offset}',
        hips: '${100 + offset}',
        length: '${62 + offset}',
      ),
      ProductSizeGuideRow(
        size: 'XL',
        chest: '${96 + offset}',
        waist: '${78 + offset}',
        hips: '${104 + offset}',
        length: '${64 + offset}',
      ),
    ];
  }
}
