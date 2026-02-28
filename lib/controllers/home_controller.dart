import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/routes/app_routes.dart';
import '../models/home_banner_item.dart';
import '../models/home_category_item.dart';
import '../models/home_product_item.dart';

class HomeController extends GetxController {
  final bannerIndex = 0.obs;

  final banners = <HomeBannerItem>[].obs;
  final categories = <HomeCategoryItem>[].obs;

  final topProducts = <HomeProductItem>[].obs;
  final newItems = <HomeProductItem>[].obs;
  final flashSale = <HomeProductItem>[].obs;
  final mostPopular = <HomeProductItem>[].obs;
  final justForYou = <HomeProductItem>[].obs;

  final searchC = TextEditingController();
  final query = ''.obs;
  final searchResults = <HomeProductItem>[].obs;

  Timer? _debounce;

  final hh = 0.obs;
  final mm = 36.obs;
  final ss = 58.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    banners.assignAll([
      const HomeBannerItem(
        id: 'b1',
        titleKey: 'home.banner.big_sale',
        subtitleKey: 'home.banner.up_to_50',
        badgeKey: 'home.banner.happening_now',
        imageUrl: 'https://picsum.photos/600/300?1',
      ),
      const HomeBannerItem(
        id: 'b2',
        titleKey: 'home.banner.new_collection',
        subtitleKey: 'home.banner.trending',
        badgeKey: 'home.banner.happening_now',
        imageUrl: 'https://picsum.photos/600/300?2',
      ),
    ]);

    categories.assignAll([
      const HomeCategoryItem(
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
      const HomeCategoryItem(
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
      const HomeCategoryItem(
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
      const HomeCategoryItem(
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
    ]);

    topProducts.assignAll(_sampleProducts(6, seed: 100));
    newItems.assignAll(_sampleProducts(6, seed: 200));
    flashSale.assignAll(_sampleProducts(6, seed: 300, discount: 20));
    mostPopular
        .assignAll(_sampleProducts(6, seed: 400, tagKey: 'home.tags.hot'));
    justForYou.assignAll(_sampleProducts(8, seed: 500));

    _startFlashTimer();
    searchResults.clear();
  }

  void onBannerChanged(int i) => bannerIndex.value = i;

  void onSeeAllCategories() {}
  void onSeeAllNewItems() {}
  void onSeeAllMostPopular() {}

  void openProduct(HomeProductItem p) {
    final isSale = (p.discountPercent ?? 0) > 0;
    Get.toNamed(
      AppRoutes.product,
      arguments: {'item': p, 'forceSale': isSale},
    );
  }

  void openFlashSaleScreen() {
    Get.toNamed(AppRoutes.flashSale);
  }

  void openCategory(HomeCategoryItem c) {}

  void openCamera() {}

  void onSearchChanged(String v) {
    query.value = v;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _runLocalSearch(v);
    });
  }

  void onSearchSubmitted(String v) {
    final q = v.trim();
    if (q.isEmpty) return;
    _runLocalSearch(q);
  }

  void clearSearch() {
    searchC.clear();
    query.value = '';
    searchResults.clear();
  }

  void _runLocalSearch(String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) {
      searchResults.clear();
      return;
    }

    final pool = <HomeProductItem>[
      ...topProducts,
      ...newItems,
      ...flashSale,
      ...mostPopular,
      ...justForYou,
    ];

    final map = <String, HomeProductItem>{};
    for (final p in pool) {
      map[p.id] = p;
    }

    final results = map.values.where((p) {
      final title = p.title.toLowerCase();
      return title.contains(q);
    }).toList();

    searchResults.assignAll(results);
  }

  void _startFlashTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      int total = (hh.value * 3600) + (mm.value * 60) + ss.value;
      if (total <= 0) return;
      total -= 1;
      hh.value = total ~/ 3600;
      mm.value = (total % 3600) ~/ 60;
      ss.value = total % 60;
    });
  }

  List<HomeProductItem> _sampleProducts(
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
      );
    });
  }

  @override
  void onClose() {
    _debounce?.cancel();
    _timer?.cancel();
    searchC.dispose();
    super.onClose();
  }
}
