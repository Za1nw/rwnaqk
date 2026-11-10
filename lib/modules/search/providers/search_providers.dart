import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/search/controllers/search_service.dart';
import 'package:rwnaqk_frontend/modules/search/models/search_state.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// موفر خدمة البحث النقي [SearchService]
final searchServiceProvider = Provider<SearchService>((ref) {
  return SearchService();
});

/// موفر حالة البحث الرئيسي بالمتجر [productSearchProvider]
final productSearchProvider =
    NotifierProvider<ProductSearchNotifier, SearchState>(
  ProductSearchNotifier.new,
);

/// موفر اقتراحات وسجل البحث [searchSuggestionsProvider]
final searchSuggestionsProvider = Provider<List<String>>((ref) {
  final state = ref.watch(productSearchProvider);
  final q = state.query.trim().toLowerCase();
  if (q.isEmpty) {
    return state.recommendations;
  }
  final combined = {...state.history, ...state.recommendations};
  return combined.where((item) => item.toLowerCase().contains(q)).toList();
});

/// متحكم البحث المتكامل المعتمد على Riverpod 3 مع إلغاء الطلبات المتتالية ومكافحة التردد (Debounce)
class ProductSearchNotifier extends Notifier<SearchState> {
  IProductsRepository get _repo => ref.read(productsRepositoryProvider);
  SearchService get _service => ref.read(searchServiceProvider);

  Timer? _debounce;
  CancelToken? _cancelToken;
  int _searchSequence = 0;

  @override
  SearchState build() {
    ref.onDispose(() {
      _debounce?.cancel();
      _cancelToken?.cancel();
    });

    final history = _service.initialHistory();
    final recommendations = _service.initialRecommendations();
    final discover = _service.sampleProducts(10, seed: 900);

    return SearchState(
      history: history,
      recommendations: recommendations,
      discover: discover,
      results: const [],
      query: '',
      isLoading: false,
      searchSequence: 0,
      activeFilters: 0,
    );
  }

  /// الاستجابة لتغيير نص البحث مع إلغاء الطلبات المعلقة فوراً ومؤقت Debounce
  void onQueryChanged(String text) {
    final trimmed = text.trim();

    _debounce?.cancel();

    // 1. إلغاء أي طلب شبكة معلق فوراً بمجرد كتابة حرف جديد لمنع السباق الزمني
    _cancelToken?.cancel('Superseded by user typing: $trimmed');
    _cancelToken = null;

    // 2. زيادة التسلسل فوراً لإبطال أي استجابة قيد الوصول قبل انقضاء المؤقت
    final nextSeq = ++_searchSequence;
    state = state.copyWith(
      query: text,
      searchSequence: nextSeq,
    );

    if (trimmed.isEmpty) {
      state = state.copyWith(
        results: const [],
        isLoading: false,
        hasSearched: false,
        errorMessage: () => null,
      );
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 250), () {
      _executeSearch(trimmed);
    });
  }

  /// إرسال البحث فوراً عند الضغط على Enter / Submit
  void onSubmitted(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _debounce?.cancel();
    state = state.copyWith(query: trimmed);
    _commitToHistory(trimmed);
    _executeSearch(trimmed);
    _openResultsScreenIfNeeded();
  }

  void submitSearch(String query) => onSubmitted(query);

  void openFilters() {
    AppNav.toNamed(AppRoutes.listing);
  }

  /// اختيار اقتراح أو عنصر من السجل
  void onTapChip(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _debounce?.cancel();
    state = state.copyWith(query: trimmed);
    _commitToHistory(trimmed);
    _executeSearch(trimmed);
    _openResultsScreenIfNeeded();
  }

  /// تفريغ سجل البحث
  void clearHistory() {
    state = state.copyWith(history: const []);
  }

  /// تفريغ النص ومسح النتائج فوراً
  void clearQuery() {
    _debounce?.cancel();
    _cancelToken?.cancel();
    _cancelToken = null;
    state = state.copyWith(
      query: '',
      results: const [],
      isLoading: false,
      hasSearched: false,
      errorMessage: () => null,
    );
  }

  /// فتح الكاميرا (ميزة مستقبلية)
  void openCamera() {
    AppToast.info(Tk.commonNotImplementedYet.tr, title: Tk.commonCamera.tr);
  }

  /// فتح صفحة تفاصيل المنتج
  void openProduct(HomeProductItem item) {
    final isSale = (item.discountPercent ?? 0) > 0;
    AppNav.toNamed(
      AppRoutes.product,
      arguments: {
        'item': item,
        'forceSale': isSale,
      },
    );
  }

  /// إضافة النص إلى سجل البحث بطريقة فريدة
  void _commitToHistory(String text) {
    final updated = _service.commitToHistory(
      currentHistory: state.history,
      query: text,
    );
    state = state.copyWith(history: updated);
  }

  /// تنفيذ البحث مع إدارة التوكن والتسلسل وحماية الاستجابات المتأخرة
  Future<void> _executeSearch(String query) async {
    // 1. إلغاء أي طلب شبكة معلق مسبقاً
    _cancelToken?.cancel('New search query triggered: $query');
    _cancelToken = CancelToken();

    final currentSequence = ++_searchSequence;
    state = state.copyWith(
      isLoading: true,
      hasSearched: true,
      searchSequence: currentSequence,
      errorMessage: () => null,
    );

    try {
      // 2. البحث عبر المستودع مع تمرير CancelToken
      List<HomeProductItem> results;
      try {
        results = await _repo.searchProducts(
          query,
          cancelToken: _cancelToken,
        );
      } catch (repoErr) {
        if (repoErr is DioException && CancelToken.isCancel(repoErr)) {
          // تم الإلغاء عمداً بسبب كتابة استعلام جديد - نتجاهله بأمان
          return;
        }
        // Fallback إلى البحث المحلي في منتجات Discover إذا فشلت الشبكة
        results = _service.runLocalSearch(
          source: state.discover,
          rawQuery: query,
        );
      }

      // 3. رفض الاستجابة المتأخرة إذا تم بدء استعلام أحدث أثناء التنفيذ (Stale Query Rejection)
      if (currentSequence != _searchSequence) {
        return;
      }

      state = state.copyWith(
        results: results,
        isLoading: false,
        errorMessage: () => null,
      );
    } catch (e) {
      if (currentSequence == _searchSequence) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => 'Search failed',
        );
      }
    }
  }

  void _openResultsScreenIfNeeded() {
    try {
      AppNav.toNamed(AppRoutes.searchResults);
    } catch (_) {
      // In headless unit tests without a navigation key, ignore navigation
    }
  }
}
