import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_service.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_banner_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

// ==========================================
// 1. MAIN NAVIGATION TAB PROVIDER
// ==========================================

final mainNavigationProvider =
    NotifierProvider<MainNavigationNotifier, int>(MainNavigationNotifier.new);

class MainNavigationNotifier extends Notifier<int> {
  static const int tabsCount = 5;

  @override
  int build() => 0;

  void changeTab(int index) {
    if (index >= 0 && index < tabsCount) {
      state = index;
    }
  }
}

// ==========================================
// 2. HOME CONTENT STATE & NOTIFIER
// ==========================================

class HomeContentState {
  const HomeContentState({
    this.banners = const [],
    this.categories = const [],
    this.topProducts = const [],
    this.newItems = const [],
    this.flashSale = const [],
    this.mostPopular = const [],
    this.justForYou = const [],
    this.searchResults = const [],
    this.bannerIndex = 0,
    this.hh = 0,
    this.mm = 36,
    this.ss = 58,
    this.isLoading = false,
  });

  final List<HomeBannerItem> banners;
  final List<HomeCategoryItem> categories;
  final List<HomeProductItem> topProducts;
  final List<HomeProductItem> newItems;
  final List<HomeProductItem> flashSale;
  final List<HomeProductItem> mostPopular;
  final List<HomeProductItem> justForYou;
  final List<HomeProductItem> searchResults;
  final int bannerIndex;
  final int hh;
  final int mm;
  final int ss;
  final bool isLoading;

  HomeContentState copyWith({
    List<HomeBannerItem>? banners,
    List<HomeCategoryItem>? categories,
    List<HomeProductItem>? topProducts,
    List<HomeProductItem>? newItems,
    List<HomeProductItem>? flashSale,
    List<HomeProductItem>? mostPopular,
    List<HomeProductItem>? justForYou,
    List<HomeProductItem>? searchResults,
    int? bannerIndex,
    int? hh,
    int? mm,
    int? ss,
    bool? isLoading,
  }) {
    return HomeContentState(
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      topProducts: topProducts ?? this.topProducts,
      newItems: newItems ?? this.newItems,
      flashSale: flashSale ?? this.flashSale,
      mostPopular: mostPopular ?? this.mostPopular,
      justForYou: justForYou ?? this.justForYou,
      searchResults: searchResults ?? this.searchResults,
      bannerIndex: bannerIndex ?? this.bannerIndex,
      hh: hh ?? this.hh,
      mm: mm ?? this.mm,
      ss: ss ?? this.ss,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final homeServiceProvider = Provider<HomeService>((ref) => HomeService());

final homeContentProvider =
    NotifierProvider<HomeContentNotifier, HomeContentState>(
  HomeContentNotifier.new,
);

class HomeContentNotifier extends Notifier<HomeContentState> {
  Timer? _timer;
  final searchController = TextEditingController();

  @override
  HomeContentState build() {
    ref.onDispose(() {
      _timer?.cancel();
      searchController.dispose();
    });

    final service = ref.read(homeServiceProvider);
    final data = service.getInitialData();

    _startFlashTimer();

    return HomeContentState(
      banners: data.banners,
      categories: data.categories,
      topProducts: data.topProducts,
      newItems: data.newItems,
      flashSale: data.flashSale,
      mostPopular: data.mostPopular,
      justForYou: data.justForYou,
    );
  }

  void _startFlashTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      int total = (state.hh * 3600) + (state.mm * 60) + state.ss;
      if (total <= 0) return;
      total -= 1;
      state = state.copyWith(
        hh: total ~/ 3600,
        mm: (total % 3600) ~/ 60,
        ss: total % 60,
      );
    });
  }

  void onBannerChanged(int index) {
    state = state.copyWith(bannerIndex: index);
  }

  void refreshHome() {
    final service = ref.read(homeServiceProvider);
    final data = service.getInitialData();
    state = state.copyWith(
      banners: data.banners,
      categories: data.categories,
      topProducts: data.topProducts,
      newItems: data.newItems,
      flashSale: data.flashSale,
      mostPopular: data.mostPopular,
      justForYou: data.justForYou,
    );
  }

  void onSeeAllCategories() {
    AppNav.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': Tk.homeCategories.tr,
        'source': 'categories',
        'items': <HomeProductItem>[],
      },
    );
  }

  void onSeeAllNewItems() {
    AppNav.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': Tk.homeNewItems.tr,
        'source': 'new_items',
        'items': state.newItems,
      },
    );
  }

  void onSeeAllMostPopular() {
    AppNav.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': Tk.homeMostPopular.tr,
        'source': 'most_popular',
        'items': state.mostPopular,
      },
    );
  }

  void onSeeAllJustForYou() {
    AppNav.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': Tk.homeJustForYou.tr,
        'source': 'just_for_you',
        'items': state.justForYou,
      },
    );
  }

  void openProduct(HomeProductItem p) {
    final isSale = (p.discountPercent ?? 0) > 0;
    AppNav.toNamed(
      AppRoutes.product,
      arguments: {
        'item': p,
        'forceSale': isSale,
        'mostPopular': state.mostPopular,
        'recommended': state.justForYou,
      },
    );
  }

  void openFlashSaleScreen() {
    AppNav.toNamed(AppRoutes.flashSale);
  }

  void openCategory(HomeCategoryItem c) {
    final pool = <HomeProductItem>[
      ...state.topProducts,
      ...state.newItems,
      ...state.flashSale,
      ...state.mostPopular,
      ...state.justForYou,
    ];

    AppNav.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': c.name.tr,
        'source': 'category_${c.id}',
        'items': pool,
      },
    );
  }

  void openCamera() {}
}

