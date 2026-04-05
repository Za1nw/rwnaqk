import 'dart:async';

import 'package:get/get.dart';
import 'package:rwnaqk/controllers/home/home_service.dart';
import 'package:rwnaqk/controllers/home/home_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/models/home_banner_item.dart';
import 'package:rwnaqk/models/home_category_item.dart';
import 'package:rwnaqk/models/home_product_item.dart';

class HomeController extends GetxController {
  HomeController(this._service);

  final HomeService _service;

  late final HomeUiController ui;

  final banners = <HomeBannerItem>[].obs;
  final categories = <HomeCategoryItem>[].obs;

  final topProducts = <HomeProductItem>[].obs;
  final newItems = <HomeProductItem>[].obs;
  final flashSale = <HomeProductItem>[].obs;
  final mostPopular = <HomeProductItem>[].obs;
  final justForYou = <HomeProductItem>[].obs;

  final searchResults = <HomeProductItem>[].obs;

  Timer? _debounce;

  final hh = 0.obs;
  final mm = 36.obs;
  final ss = 58.obs;

  Timer? _timer;

  RxInt get bannerIndex => ui.bannerIndex;
  get searchC => ui.searchC;
  RxString get query => ui.query;

  @override
  void onInit() {
    super.onInit();

    ui = Get.find<HomeUiController>();

    final data = _service.getInitialData();

    banners.assignAll(data.banners);
    categories.assignAll(data.categories);
    topProducts.assignAll(data.topProducts);
    newItems.assignAll(data.newItems);
    flashSale.assignAll(data.flashSale);
    mostPopular.assignAll(data.mostPopular);
    justForYou.assignAll(data.justForYou);

    _startFlashTimer();
    searchResults.clear();
  }

  void onBannerChanged(int i) {
    ui.onBannerChanged(i);
  }

  void onSeeAllCategories() {
    Get.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': Tk.homeCategories.tr,
        'source': 'categories',
        'items': <HomeProductItem>[],
      },
    );
  }

  void onSeeAllNewItems() {
    Get.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': Tk.homeNewItems.tr,
        'source': 'new_items',
        'items': newItems.toList(),
      },
    );
  }

  void onSeeAllMostPopular() {
    Get.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': Tk.homeMostPopular.tr,
        'source': 'most_popular',
        'items': mostPopular.toList(),
      },
    );
  }

  void onSeeAllJustForYou() {
    Get.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': Tk.homeJustForYou.tr,
        'source': 'just_for_you',
        'items': justForYou.toList(),
      },
    );
  }

  void openProduct(HomeProductItem p) {
    final isSale = (p.discountPercent ?? 0) > 0;

    Get.toNamed(
      AppRoutes.product,
      arguments: {
        'item': p,
        'forceSale': isSale,
        'mostPopular': mostPopular.toList(),
        'recommended': justForYou.toList(),
      },
    );
  }

  void openFlashSaleScreen() {
    Get.toNamed(AppRoutes.flashSale);
  }

  void openCategory(HomeCategoryItem c) {
    final pool = <HomeProductItem>[
      ...topProducts,
      ...newItems,
      ...flashSale,
      ...mostPopular,
      ...justForYou,
    ];

    Get.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': c.name.tr,
        'source': 'category_${c.id}',
        'items': pool.toList(),
      },
    );
  }

  void openCamera() {}

  void onSearchChanged(String v) {
    ui.onSearchChanged(v);

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
    ui.clearSearch();
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

  @override
  void onClose() {
    _debounce?.cancel();
    _timer?.cancel();
    super.onClose();
  }
}
