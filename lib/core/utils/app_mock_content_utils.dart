import 'package:get/get.dart';
import 'package:rwnaqk/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk/models/home_category_item.dart';
import 'package:rwnaqk/models/product_review.dart';

class MockCategorySection {
  final String nameKey;
  final String imageUrl;
  final List<String> subKeys;
  final bool isSpecial;

  const MockCategorySection({
    required this.nameKey,
    required this.imageUrl,
    this.subKeys = const [],
    this.isSpecial = false,
  });
}

class AppMockContentUtils {
  AppMockContentUtils._();

  static const List<String> countryKeys = [
    Mk.countryYemen,
    Mk.countrySaudiArabia,
    Mk.countryUae,
    Mk.countryEgypt,
    Mk.countryIndia,
  ];

  static const List<String> filterCategoryKeys = [
    Mk.subcategoryDresses,
    Mk.subcategoryPants,
    Mk.subcategorySkirts,
    Mk.subcategoryShorts,
    Mk.subcategoryJackets,
    Mk.subcategoryHoodies,
    Mk.subcategoryShirts,
    Mk.subcategoryPolo,
    Mk.subcategoryTShirts,
    Mk.subcategoryTunics,
  ];

  static const List<MockCategorySection> categorySections = [
    MockCategorySection(
      nameKey: Mk.categoryClothing,
      imageUrl: 'https://picsum.photos/120?1',
      subKeys: [
        Mk.subcategoryDresses,
        Mk.subcategoryPants,
        Mk.subcategorySkirts,
        Mk.subcategoryShorts,
        Mk.subcategoryJackets,
        Mk.subcategoryHoodies,
        Mk.subcategoryShirts,
        Mk.subcategoryPolo,
        Mk.subcategoryTShirts,
        Mk.subcategoryTunics,
      ],
    ),
    MockCategorySection(
      nameKey: Mk.categoryShoes,
      imageUrl: 'https://picsum.photos/120?2',
      subKeys: [
        Mk.subcategorySneakers,
        Mk.subcategoryBoots,
      ],
    ),
    MockCategorySection(
      nameKey: Mk.categoryBags,
      imageUrl: 'https://picsum.photos/120?3',
      subKeys: [
        Mk.subcategoryHandbags,
        Mk.subcategoryBackpacks,
      ],
    ),
    MockCategorySection(
      nameKey: Mk.categoryLingerie,
      imageUrl: 'https://picsum.photos/120?4',
      subKeys: [
        Mk.subcategoryBras,
        Mk.subcategoryPanties,
      ],
    ),
    MockCategorySection(
      nameKey: Mk.categoryAccessories,
      imageUrl: 'https://picsum.photos/120?5',
      subKeys: [
        Mk.subcategoryJewelry,
        Mk.subcategoryHats,
      ],
    ),
    MockCategorySection(
      nameKey: Mk.categoryJustForYou,
      imageUrl: 'https://picsum.photos/120?6',
      isSpecial: true,
    ),
  ];

  static const List<HomeCategoryItem> homeCategories = [
    HomeCategoryItem(
      id: 'c1',
      name: Mk.categoryClothing,
      count: 109,
      imageUrls: [
        'https://picsum.photos/120?11',
        'https://picsum.photos/120?12',
        'https://picsum.photos/120?13',
        'https://picsum.photos/120?14',
      ],
    ),
    HomeCategoryItem(
      id: 'c2',
      name: Mk.categoryShoes,
      count: 530,
      imageUrls: [
        'https://picsum.photos/120?21',
        'https://picsum.photos/120?22',
        'https://picsum.photos/120?23',
        'https://picsum.photos/120?24',
      ],
    ),
    HomeCategoryItem(
      id: 'c3',
      name: Mk.categoryBags,
      count: 87,
      imageUrls: [
        'https://picsum.photos/120?31',
        'https://picsum.photos/120?32',
        'https://picsum.photos/120?33',
        'https://picsum.photos/120?34',
      ],
    ),
    HomeCategoryItem(
      id: 'c4',
      name: Mk.categoryLingerie,
      count: 218,
      imageUrls: [
        'https://picsum.photos/120?41',
        'https://picsum.photos/120?42',
        'https://picsum.photos/120?43',
        'https://picsum.photos/120?44',
      ],
    ),
  ];

  static const List<ProductReview> allReviews = [
    ProductReview(
      name: 'Anna',
      rating: 4.5,
      text: Mk.reviewAnnaText,
      dateText: Mk.reviewAnnaDate,
    ),
    ProductReview(
      name: 'John',
      rating: 5,
      text: Mk.reviewJohnText,
      dateText: Mk.reviewJohnDate,
    ),
    ProductReview(
      name: 'Sara',
      rating: 4,
      text: Mk.reviewSaraText,
      dateText: Mk.reviewSaraDate,
    ),
    ProductReview(
      name: 'Khaled',
      rating: 3.5,
      text: Mk.reviewKhaledText,
      dateText: Mk.reviewKhaledDate,
    ),
  ];

  static const List<ProductReview> previewReviews = [
    ProductReview(
      name: 'Veronika',
      rating: 4,
      text: Mk.reviewVeronikaText,
      dateText: Mk.reviewVeronikaDate,
    ),
  ];

  static List<String> localizedCountries() =>
      countryKeys.map(localizedCountryLabel).toList(growable: false);

  static String localizedCountryLabel(String value) {
    final key = resolveCountryKey(value);
    return key.startsWith('mock.') ? key.tr : value;
  }

  static String resolveCountryKey(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) {
      return Mk.countryYemen;
    }

    for (final key in countryKeys) {
      if (raw == key ||
          raw == key.tr ||
          raw.toLowerCase() == _englishCountryLabel(key).toLowerCase() ||
          raw == _arabicCountryLabel(key)) {
        return key;
      }
    }

    return raw;
  }

  static String _englishCountryLabel(String key) {
    switch (key) {
      case Mk.countrySaudiArabia:
        return 'Saudi Arabia';
      case Mk.countryUae:
        return 'United Arab Emirates';
      case Mk.countryEgypt:
        return 'Egypt';
      case Mk.countryIndia:
        return 'India';
      case Mk.countryYemen:
      default:
        return 'Yemen';
    }
  }

  static String _arabicCountryLabel(String key) {
    switch (key) {
      case Mk.countrySaudiArabia:
        return 'السعودية';
      case Mk.countryUae:
        return 'الإمارات';
      case Mk.countryEgypt:
        return 'مصر';
      case Mk.countryIndia:
        return 'الهند';
      case Mk.countryYemen:
      default:
        return 'اليمن';
    }
  }

  static String itemTitlePrefix() => Mk.productItemTitlePrefix.tr;

  static String listingTitlePrefix() => Mk.productListingTitlePrefix.tr;

  static String soldCountText(int count) =>
      Mk.productSoldCount.trParams({'count': '$count'});
}
