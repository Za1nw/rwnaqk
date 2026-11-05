import 'package:rwnaqk_frontend/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';

typedef MockProductIdBuilder = String Function(int seed, int index);
typedef MockProductImageBuilder = String Function(String id);
typedef MockProductDiscountBuilder = int? Function(int index);

class AppMockProductUtils {
  AppMockProductUtils._();

  static const List<String> _productTitles = [
    'فستان سهرة مخملي راقي',
    'عطر العود والمسك الملكي',
    'حقيبة يد جلدية كلاسيك',
    'ساعة يد أنالوج بريميوم',
    'طقم مجوهرات بتصميم ماسي',
    'حذاء كاجوال مريح ومرن',
    'عباية خليجية مطرزة',
    'نظارة شمسية بإطار عصري',
    'قميص كتان صيفي فاخر',
    'محفظة جلدية مميزة',
    'عطر الفانيليا والزهور',
    'سوار ذهبي عيار 18',
  ];

  static const List<String> _brandNames = [
    'رَوْنَقُك',
    'شانيل',
    'ديور',
    'زارا بريميوم',
    'مانغو',
    'غوتشي',
  ];

  static List<HomeProductItem> buildProducts(
    int count, {
    required int seed,
    int? discount,
    MockProductDiscountBuilder? discountBuilder,
    MockProductIdBuilder? idBuilder,
    MockProductImageBuilder? imageBuilder,
    String? titlePrefix,
    double basePrice = 25,
    double priceStep = 10,
    String tagKey = '',
    bool includeDetails = false,
  }) {
    return List.generate(count, (index) {
      final id = idBuilder?.call(seed, index) ?? '${seed}_$index';
      final resolvedDiscount = discountBuilder?.call(index) ?? discount;

      final title = _productTitles[(seed + index) % _productTitles.length];
      final brand = _brandNames[(seed + index) % _brandNames.length];

      return HomeProductItem(
        id: id,
        title: title,
        imageUrl: imageBuilder?.call(id) ?? 'https://picsum.photos/400/500?$id',
        price: basePrice + (index * priceStep).toDouble(),
        discountPercent: resolvedDiscount,
        isNew: index % 3 == 0,
        tagKey: tagKey,
        description: includeDetails ? Mk.productDefaultDescription : '',
        brand: brand,
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
