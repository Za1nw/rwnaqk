import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk/core/utils/app_mock_product_utils.dart';
import 'package:rwnaqk/models/home_banner_item.dart';
import 'package:rwnaqk/models/home_category_item.dart';
import 'package:rwnaqk/models/home_product_item.dart';

class HomeDataResult {
  final List<HomeBannerItem> banners;
  final List<HomeCategoryItem> categories;
  final List<HomeProductItem> topProducts;
  final List<HomeProductItem> newItems;
  final List<HomeProductItem> flashSale;
  final List<HomeProductItem> mostPopular;
  final List<HomeProductItem> justForYou;

  const HomeDataResult({
    required this.banners,
    required this.categories,
    required this.topProducts,
    required this.newItems,
    required this.flashSale,
    required this.mostPopular,
    required this.justForYou,
  });
}

class HomeService {
  HomeDataResult getInitialData() {
    return HomeDataResult(
      banners: const [
        HomeBannerItem(
          id: 'b1',
          titleKey: Tk.homeBannerBigSale,
          subtitleKey: Tk.homeBannerUpTo50,
          badgeKey: Tk.homeBannerHappeningNow,
          imageUrl: 'https://picsum.photos/600/300?1',
        ),
        HomeBannerItem(
          id: 'b2',
          titleKey: Tk.homeBannerNewCollection,
          subtitleKey: Tk.homeBannerTrending,
          badgeKey: Tk.homeBannerHappeningNow,
          imageUrl: 'https://picsum.photos/600/300?2',
        ),
      ],
      categories: AppMockContentUtils.homeCategories,
      topProducts: sampleProducts(6, seed: 100),
      newItems: sampleProducts(6, seed: 200),
      flashSale: sampleProducts(6, seed: 300, discount: 20),
      mostPopular: sampleProducts(6, seed: 400, tagKey: Tk.homeTagsHot),
      justForYou: sampleProducts(8, seed: 500),
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
      includeDetails: true,
    );
  }
}
