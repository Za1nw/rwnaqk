import 'package:rwnaqk/models/home_banner_item.dart';
import 'package:rwnaqk/models/home_category_item.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/product_color_option.dart';

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
          titleKey: 'home.banner.big_sale',
          subtitleKey: 'home.banner.up_to_50',
          badgeKey: 'home.banner.happening_now',
          imageUrl: 'https://picsum.photos/600/300?1',
        ),
        HomeBannerItem(
          id: 'b2',
          titleKey: 'home.banner.new_collection',
          subtitleKey: 'home.banner.trending',
          badgeKey: 'home.banner.happening_now',
          imageUrl: 'https://picsum.photos/600/300?2',
        ),
      ],
      categories: const [
        HomeCategoryItem(
          id: 'c1',
          name: 'Clothing',
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
          name: 'Shoes',
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
          name: 'Bags',
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
          name: 'Lingerie',
          count: 218,
          imageUrls: [
            'https://picsum.photos/120?41',
            'https://picsum.photos/120?42',
            'https://picsum.photos/120?43',
            'https://picsum.photos/120?44',
          ],
        ),
      ],
      topProducts: sampleProducts(6, seed: 100),
      newItems: sampleProducts(6, seed: 200),
      flashSale: sampleProducts(6, seed: 300, discount: 20),
      mostPopular: sampleProducts(
        6,
        seed: 400,
        tagKey: 'home.tags.hot',
      ),
      justForYou: sampleProducts(8, seed: 500),
    );
  }

  List<HomeProductItem> sampleProducts(
    int n, {
    required int seed,
    int? discount,
    String tagKey = '',
  }) {
    return List.generate(n, (i) {
      final id = '${seed}_$i';

      return HomeProductItem(
        id: id,
        title: 'Item $id',
        imageUrl: 'https://picsum.photos/400/500?$id',
        price: 17 + (i * 5).toDouble(),
        discountPercent: discount,
        isNew: i % 3 == 0,
        tagKey: tagKey,
        description:
            'Premium product with modern style and comfortable daily use.',
        brand: 'Rwnaq',
        sku: 'SKU-$id',
        stockText: 'In Stock',
        soldText: '${20 + i * 7} sold',
        images: [
          'https://picsum.photos/500/650?${id}a',
          'https://picsum.photos/500/650?${id}b',
          'https://picsum.photos/500/650?${id}c',
          'https://picsum.photos/500/650?${id}d',
        ],
        availableColors: [
          ProductColorOption(
            id: 'black_$id',
            name: 'Black',
            imageUrl: 'https://picsum.photos/120/120?${id}black',
          ),
          ProductColorOption(
            id: 'white_$id',
            name: 'White',
            imageUrl: 'https://picsum.photos/120/120?${id}white',
          ),
          ProductColorOption(
            id: 'beige_$id',
            name: 'Beige',
            imageUrl: 'https://picsum.photos/120/120?${id}beige',
          ),
        ],
        availableSizes: const ['S', 'M', 'L', 'XL'],
      );
    });
  }
}