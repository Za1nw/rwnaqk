import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_service.dart';
import 'package:rwnaqk_frontend/modules/home/data/home_local_cache.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_banner_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

// ==========================================
// 1. MAIN NAVIGATION TAB PROVIDER
// ==========================================

final mainNavigationProvider = NotifierProvider<MainNavigationNotifier, int>(
  MainNavigationNotifier.new,
);

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

enum HomeSection {
  banners,
  categories,
  flashSale,
  topProducts,
  newItems,
  mostPopular,
  justForYou,
}

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
    this.isRefreshing = false,
    this.hasLoaded = false,
    this.hasError = false,
    this.errorMessage,
    this.loadingSections = const {},
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
  final bool isRefreshing;
  final bool hasLoaded;
  final bool hasError;
  final String? errorMessage;
  final Set<HomeSection> loadingSections;

  bool isSectionLoading(HomeSection section) =>
      loadingSections.contains(section) || (!hasLoaded && !isRefreshing);

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
    bool? isRefreshing,
    bool? hasLoaded,
    bool? hasError,
    String? errorMessage,
    Set<HomeSection>? loadingSections,
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
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      loadingSections: loadingSections ?? this.loadingSections,
    );
  }
}

final homeLocalCacheProvider = Provider<HomeLocalCache>((ref) {
  final prefs = ref.watch(sharedPreferencesInstanceProvider);
  return HomeLocalCache(prefs);
});

final homeServiceProvider = Provider<HomeService>((ref) {
  final localCache = ref.watch(homeLocalCacheProvider);
  return HomeService(localCache: localCache);
});

final homeContentProvider =
    NotifierProvider<HomeContentNotifier, HomeContentState>(
      HomeContentNotifier.new,
    );

class HomeContentNotifier extends Notifier<HomeContentState> {
  Timer? _timer;
  bool _disposed = false;
  CancelToken? _cancelToken;
  final searchController = TextEditingController();

  @override
  HomeContentState build() {
    ref.onDispose(() {
      _disposed = true;
      _cancelToken?.cancel('Home disposed');
      _timer?.cancel();
      searchController.dispose();
    });

    _startFlashTimer();

    // جلب البيانات الحقيقية من خادم Laravel API في الخلفية مع تفعيل الهيكل Skeleton
    Future.microtask(() => loadHomeData());

    return const HomeContentState(
      banners: [],
      categories: [],
      topProducts: [],
      newItems: [],
      flashSale: [],
      mostPopular: [],
      justForYou: [],
      isLoading: true,
      hasLoaded: false,
      hasError: false,
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

  /// جلب البيانات الحقيقية من الكتالوج وقاعدة بيانات Laravel
  /// يطبق أفضل الممارسات: محاولة جلب نقطة النهاية المجمعة أولاً (BFF Composite API)
  /// لتقليص 5 اتصالات إلى طلب واحد، مع بديل متوازٍ بـ Dart 3 Records مع إلغاء الطلبات القديمة (CancelToken)
  Future<void> loadHomeData({bool isRefresh = false}) async {
    _cancelToken?.cancel('New home request started');
    _cancelToken = CancelToken();
    final cancelToken = _cancelToken;

    state = state.copyWith(
      isLoading: !isRefresh && !state.hasLoaded,
      isRefreshing: isRefresh,
      hasError: false,
      errorMessage: null,
    );

    try {
      final repo = ref.read(productsRepositoryProvider);
      final service = ref.read(homeServiceProvider);
      final apiClient = ref.read(apiClientProvider);

      // 1. محاولة جلب نقطة النهاية المجمعة (Composite Bootstrap Endpoint) أولاً
      // لتقليل 5 إلى 6 طلبات إلى طلب واحد فقط فائق السرعة
      final bootstrap = await service.fetchHomeBootstrap(
        apiClient,
        cancelToken: cancelToken,
        isRefresh: isRefresh,
      );

      if (bootstrap != null) {
        if (_disposed) return;

        final topProductsList = bootstrap.popularItems.isNotEmpty
            ? bootstrap.popularItems
            : bootstrap.newItems;

        state = state.copyWith(
          isLoading: false,
          isRefreshing: false,
          hasLoaded: true,
          hasError: false,
          banners: bootstrap.banners,
          categories: bootstrap.categories,
          topProducts: topProductsList,
          newItems: bootstrap.newItems,
          flashSale: bootstrap.flashSale,
          mostPopular: bootstrap.popularItems,
          justForYou: bootstrap.newItems,
        );
        return;
      }

      // 2. خطة بديلة فائقة التزامن باستخدام Dart 3 Records مع عزل الأخطاء الجزئية
      final (fetchedBanners, fetchedCategories, newestProducts, popularProducts, discountProducts) = await (
        service.fetchBanners(apiClient, cancelToken: cancelToken),
        repo.getCategories(parentId: 'null', cancelToken: cancelToken).then((cats) async {
          if (cats.isEmpty) {
            return await repo.getCategories(cancelToken: cancelToken);
          }
          return cats;
        }).catchError((e) {
          debugPrint('[HomeContentNotifier] Error fetching categories: $e');
          return <HomeCategoryItem>[];
        }),
        repo.getProducts(limit: 15, sort: ListingSort.newest, cancelToken: cancelToken).catchError((e) {
          debugPrint('[HomeContentNotifier] Error fetching newest products: $e');
          return <HomeProductItem>[];
        }),
        repo.getProducts(limit: 10, sort: ListingSort.popular, cancelToken: cancelToken).catchError((e) {
          debugPrint('[HomeContentNotifier] Error fetching popular products: $e');
          return <HomeProductItem>[];
        }),
        repo.getProducts(limit: 10, sort: ListingSort.discountHigh, cancelToken: cancelToken).catchError((e) {
          debugPrint('[HomeContentNotifier] Error fetching discount products: $e');
          return <HomeProductItem>[];
        }),
      ).wait;

      // فلترة المنتجات التي تحتوي على خصومات فعلية للـ Flash Sale
      final discountOnly = discountProducts
          .where((p) => p.hasDiscount)
          .toList();
      final flashSaleList = discountOnly.isNotEmpty
          ? discountOnly
          : discountProducts;

      final topProductsList = popularProducts.isNotEmpty
          ? popularProducts
          : newestProducts;

      if (_disposed) return;

      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        hasError: false,
        banners: fetchedBanners.isNotEmpty ? fetchedBanners : state.banners,
        categories: fetchedCategories.isNotEmpty ? fetchedCategories : state.categories,
        topProducts: topProductsList.isNotEmpty ? topProductsList : state.topProducts,
        newItems: newestProducts.isNotEmpty ? newestProducts : state.newItems,
        flashSale: flashSaleList.isNotEmpty ? flashSaleList : state.flashSale,
        mostPopular: popularProducts.isNotEmpty ? popularProducts : state.mostPopular,
        justForYou: newestProducts.isNotEmpty ? newestProducts : state.justForYou,
      );
    } catch (e, st) {
      if (_disposed) return;
      if (e is DioException && CancelToken.isCancel(e)) {
        // تم إلغاء الطلب بأمان بسبب إعادة المحاولة أو مغادرة الشاشة
        return;
      }
      debugPrint(
        '[HomeContentNotifier] Error loading home data from API: $e\n$st',
      );
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        hasLoaded: true,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> refreshHome() async {
    await loadHomeData(isRefresh: true);
  }

  /// إعادة محاولة تحميل قسم محدد فقط مع إظهار هيكل الـ Skeleton الخاص به حصراً
  Future<void> retrySection(HomeSection section) async {
    state = state.copyWith(
      loadingSections: {...state.loadingSections, section},
    );

    try {
      final repo = ref.read(productsRepositoryProvider);
      final service = ref.read(homeServiceProvider);
      final apiClient = ref.read(apiClientProvider);

      switch (section) {
        case HomeSection.banners:
          final banners = await service.fetchBanners(apiClient);
          state = state.copyWith(banners: banners);
          break;
        case HomeSection.categories:
          final cats = await repo.getCategories(parentId: 'null').then((list) async {
            if (list.isEmpty) return await repo.getCategories();
            return list;
          });
          state = state.copyWith(categories: cats);
          break;
        case HomeSection.flashSale:
          final prods = await repo.getProducts(limit: 10, sort: ListingSort.discountHigh);
          final discountOnly = prods.where((p) => p.hasDiscount).toList();
          state = state.copyWith(
            flashSale: discountOnly.isNotEmpty ? discountOnly : prods,
          );
          break;
        case HomeSection.topProducts:
          final prods = await repo.getProducts(limit: 10, sort: ListingSort.popular);
          state = state.copyWith(topProducts: prods);
          break;
        case HomeSection.newItems:
          final prods = await repo.getProducts(limit: 15, sort: ListingSort.newest);
          state = state.copyWith(newItems: prods);
          break;
        case HomeSection.mostPopular:
          final prods = await repo.getProducts(limit: 10, sort: ListingSort.popular);
          state = state.copyWith(mostPopular: prods);
          break;
        case HomeSection.justForYou:
          final prods = await repo.getProducts(limit: 15, sort: ListingSort.newest);
          state = state.copyWith(justForYou: prods);
          break;
      }
    } catch (e) {
      debugPrint('[HomeContentNotifier] Error retrying section $section: $e');
    } finally {
      if (!_disposed) {
        state = state.copyWith(
          loadingSections: Set.from(state.loadingSections)..remove(section),
        );
      }
    }
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
    AppNav.toNamed(
      AppRoutes.listing,
      arguments: {
        'title': c.name.tr,
        'source': 'category_${c.id}',
        'categoryId': c.id,
        'items': <HomeProductItem>[],
      },
    );
  }

  void openCamera() {}
}
