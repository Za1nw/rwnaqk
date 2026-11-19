import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/cart_added_dialog.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_service.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/repositories/wishlist_repository.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/wishlist_local_cache.dart';
import 'package:rwnaqk_frontend/modules/wishlist/models/wishlist_state.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// مزود خدمة المفضلة والعمليات الحسابية [WishlistService]
final wishlistServiceProvider = Provider<WishlistService>((ref) {
  return WishlistService();
});

/// مزود مستودع المفضلة المتصل بالسيرفر [IWishlistRepository]
final wishlistRepositoryProvider = Provider<IWishlistRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return WishlistRepositoryImpl(apiClient: client);
});

/// موفر الحالة المعتمد والمالك الوحيد للمفضلة في كامل التطبيق [WishlistNotifier]
final wishlistProvider =
    NotifierProvider<WishlistNotifier, WishlistState>(WishlistNotifier.new);

/// متحكم حالة المفضلة المعتمد على Riverpod 3 متكامل مع خادم Laravel API
class WishlistNotifier extends Notifier<WishlistState> {
  bool _disposed = false;
  bool _isLoading = false;
  bool _isRefreshingIds = false;
  DateTime? _lastIdsRefresh;
  final Set<String> _pendingToggles = {};

  IWishlistRepository get _repo => ref.read(wishlistRepositoryProvider);
  WishlistService get _service => ref.read(wishlistServiceProvider);

  @override
  WishlistState build() {
    _disposed = false;
    _isLoading = false;
    _isRefreshingIds = false;
    _pendingToggles.clear();
    ref.onDispose(() {
      _disposed = true;
      _pendingToggles.clear();
    });

    // قراءة متزامنة فورية من ذاكرة التطبيق (SharedPreferences) عند الإقلاع
    final prefs = ref.watch(sharedPreferencesInstanceProvider);
    final initialIds = WishlistLocalCache.getCachedIdsSync(prefs);
    final initialCount = WishlistLocalCache.getCachedCountSync(prefs);

    // إذا كان التطبيق يفتح لأول مرة ولا توجد بيانات محلية، نحدث المعرفات في الخلفية مرة واحدة
    if (initialIds.isEmpty && initialCount == 0) {
      Future.microtask(() async {
        if (!_disposed) {
          await refreshFavoriteIds();
        }
      });
    }

    return WishlistState(
      items: const [],
      favoriteIds: initialIds,
      recentlyViewed: const [],
      tabIndex: 0,
      recentFilter: RecentFilter.today,
      activeUserId: null,
      sessionGeneration: 0,
      cachedItemCount: initialCount > 0 ? initialCount : initialIds.length,
      hasLoaded: false,
    );
  }

  /// جلب معرفات المفضلة الخفيفة والسريعة من السيرفر مع منع التكرار وكبح التزاحم
  Future<void> refreshFavoriteIds({bool force = false}) async {
    if (_disposed || _isRefreshingIds) return;
    final now = DateTime.now();
    if (!force &&
        _lastIdsRefresh != null &&
        now.difference(_lastIdsRefresh!).inSeconds < 10) {
      return;
    }

    _isRefreshingIds = true;
    _lastIdsRefresh = now;

    try {
      final ids = await _repo.getWishlistIds();
      if (_disposed) return;
      final idsSet = ids.toSet();
      state = state.copyWith(
        favoriteIds: idsSet,
        cachedItemCount: idsSet.length,
      );
      unawaited(WishlistLocalCache.saveFavoriteIds(idsSet));
    } catch (e) {
      debugPrint('[WishlistNotifier] Error refreshing favorite IDs: $e');
    } finally {
      _isRefreshingIds = false;
    }
  }

  /// تحميل عناصر المفضلة بشكل كسول (Lazy Loading) فقط عند دخول شاشة المفضلة
  Future<void> ensureLoaded() async {
    if (state.hasLoaded || _isLoading || _disposed) return;
    await loadWishlist();
  }

  /// جلب عناصر المفضلة الحقيقية من السيرفر مع الحماية من الطلبات المتكررة
  Future<void> loadWishlist() async {
    if (_disposed || _isLoading) return;
    _isLoading = true;
    try {
      final items = await _repo.getWishlist();
      if (!_disposed) {
        final ids = items.map((e) => e.id).toSet();
        state = state.copyWith(
          items: items,
          favoriteIds: ids,
          cachedItemCount: items.length,
          hasLoaded: true,
        );
      }
    } catch (e) {
      debugPrint('[WishlistNotifier] Error loading wishlist from server: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// التحقق هل المنتج موجود في المفضلة
  bool isInWishlist(String id) => state.isInWishlist(id);

  /// إضافة أو إزالة المنتج من المفضلة مع الحفظ المتزامن في السيرفر وحماية التبديل المتكرر السريع
  Future<void> toggle(HomeProductItem item) async {
    if (_pendingToggles.contains(item.id)) return;
    _pendingToggles.add(item.id);

    final originalItems = state.items;
    final originalIds = state.favoriteIds;
    final originalCount = state.itemCount;
    final willAdd = !state.isInWishlist(item.id);

    final newFavoriteIds = Set<String>.from(state.favoriteIds);
    if (willAdd) {
      newFavoriteIds.add(item.id);
    } else {
      newFavoriteIds.remove(item.id);
    }

    // 1. تحديث تفاؤلي فوري في واجهة التطبيق والعدد والمعرفات
    final updated = _service.toggleItem(
      currentList: state.items,
      item: item,
    );
    state = state.copyWith(
      items: updated,
      favoriteIds: newFavoriteIds,
      cachedItemCount: state.hasLoaded ? updated.length : newFavoriteIds.length,
    );

    unawaited(WishlistLocalCache.saveFavoriteIds(newFavoriteIds));

    // 2. إرسال طلب التبديل إلى خادم Laravel لتسجيله في السيرفر
    try {
      final isFav = await _repo.toggleWishlist(item.id);
      if (_disposed) return;
      final verifiedCount = await WishlistLocalCache.getCachedCount();
      if (_disposed) return;

      final countToSet = verifiedCount > 0
          ? verifiedCount
          : (state.hasLoaded ? state.items.length : state.cachedItemCount);

      final syncedIds = Set<String>.from(state.favoriteIds);
      if (isFav) {
        syncedIds.add(item.id);
      } else {
        syncedIds.remove(item.id);
      }

      if (isFav && !state.items.any((e) => e.id == item.id) && state.hasLoaded) {
        state = state.copyWith(
          items: [item, ...state.items],
          favoriteIds: syncedIds,
          cachedItemCount: countToSet,
        );
      } else if (!isFav && state.items.any((e) => e.id == item.id)) {
        state = state.copyWith(
          items: state.items.where((e) => e.id != item.id).toList(),
          favoriteIds: syncedIds,
          cachedItemCount: countToSet,
        );
      } else {
        state = state.copyWith(
          favoriteIds: syncedIds,
          cachedItemCount: countToSet,
        );
      }
      unawaited(WishlistLocalCache.saveFavoriteIds(syncedIds));
    } catch (e) {
      if (_disposed) return;
      debugPrint('[WishlistNotifier] Error syncing toggle with server: $e');
      // استعادة الحالة السابقة عند حدوث خطأ شبكي
      state = state.copyWith(
        items: originalItems,
        favoriteIds: originalIds,
        cachedItemCount: originalCount,
      );
      unawaited(WishlistLocalCache.saveFavoriteIds(originalIds));
      AppToast.error('تعذر تحديث المفضلة في السيرفر، يرجى التأكد من الاتصال.');
    } finally {
      _pendingToggles.remove(item.id);
    }
  }

  Future<void> toggleWishlist(HomeProductItem item) => toggle(item);

  /// إزالة منتج من المفضلة صراحةً ومزامنته في السيرفر
  Future<void> remove(HomeProductItem item) async {
    final originalItems = state.items;
    final originalIds = state.favoriteIds;
    final originalCount = state.itemCount;

    final updated = _service.removeItem(
      currentList: state.items,
      item: item,
    );
    final newFavoriteIds = Set<String>.from(state.favoriteIds)..remove(item.id);

    state = state.copyWith(
      items: updated,
      favoriteIds: newFavoriteIds,
      cachedItemCount: state.hasLoaded ? updated.length : newFavoriteIds.length,
    );
    unawaited(WishlistLocalCache.saveFavoriteIds(newFavoriteIds));

    try {
      await _repo.removeFromWishlist(item.id);
      if (_disposed) return;
      final verifiedCount = await WishlistLocalCache.getCachedCount();
      if (_disposed) return;
      state = state.copyWith(cachedItemCount: verifiedCount);
    } catch (e) {
      if (_disposed) return;
      debugPrint('[WishlistNotifier] Error removing item from server: $e');
      state = state.copyWith(
        items: originalItems,
        favoriteIds: originalIds,
        cachedItemCount: originalCount,
      );
      unawaited(WishlistLocalCache.saveFavoriteIds(originalIds));
      AppToast.error('تعذر حذف المنتج من السيرفر.');
    }
  }

  Future<void> removeFromWishlist(dynamic itemOrId) async {
    if (itemOrId is HomeProductItem) {
      await remove(itemOrId);
    } else if (itemOrId is String) {
      final found = state.items.where((e) => e.id == itemOrId);
      if (found.isNotEmpty) {
        await remove(found.first);
      } else {
        try {
          await _repo.removeFromWishlist(itemOrId);
        } catch (_) {}
      }
    }
  }

  /// تسجيل مشاهدة المنتج في قائمة المشاهدات الأخيرة
  void addRecentlyViewed(HomeProductItem item) {
    final updated = _service.addRecent(
      currentList: state.recentlyViewed,
      item: item,
    );
    state = state.copyWith(recentlyViewed: updated);
  }

  /// تبديل التبويب المعروض (0: المفضلة، 1: المشاهدة مؤخراً)
  void setTab(int index) {
    if (state.tabIndex == index) return;
    state = state.copyWith(tabIndex: index);
  }

  /// تطبيق فلتر زمني على المشاهدات الأخيرة
  void setRecentFilter(RecentFilter filter) {
    if (state.recentFilter == filter && filter != RecentFilter.date) return;
    state = state.copyWith(
      recentFilter: filter,
      clearSelectedDate: filter != RecentFilter.date,
    );
  }

  /// اختيار تاريخ محدد للفلترة الزمنية
  void chooseDate(DateTime date) {
    state = state.copyWith(
      selectedDate: date,
      recentFilter: RecentFilter.date,
    );
  }

  /// تفريغ قائمة المشاهدات مؤخراً بالكامل
  void clearRecent() {
    state = state.copyWith(recentlyViewed: const []);
  }

  /// تفريغ المفضلة بالكامل
  void clearWishlist() {
    state = state.copyWith(items: const []);
  }

  /// مزامنة حالة المفضلة مع جلسة المستخدم الحالية
  Future<void> syncWithSession({
    required String? userId,
    required int generation,
    bool isLogin = false,
  }) async {
    final previousUserId = state.activeUserId;

    // تمييز ربط الجلسة الأولي عند بدء تشغيل التطبيق عن تسجيل الدخول الفعلي أو تبديل الحساب
    final isInitialSessionBind = previousUserId == null && userId != null && !isLogin;
    final isAccountSwitch = (previousUserId != null && previousUserId != userId) ||
        (previousUserId == 'guest' && userId != 'guest') ||
        (previousUserId == null && userId != null && isLogin);
    final isLogout = userId == null;

    if (isInitialSessionBind) {
      // الحفاظ التام على المعرفات والعدد المحفوظ محلياً لمنع وميض الواجهة أو تأخر ظهور القلوب
      state = state.copyWith(
        activeUserId: userId,
        sessionGeneration: generation,
      );
      unawaited(refreshFavoriteIds());
      return;
    }

    if (isAccountSwitch || isLogout) {
      final localIds = state.items.map((e) => e.id).toList();
      state = WishlistState(
        items: const [],
        favoriteIds: const {},
        recentlyViewed: const [],
        tabIndex: 0,
        recentFilter: RecentFilter.today,
        selectedDate: null,
        activeUserId: userId,
        sessionGeneration: generation,
        cachedItemCount: 0,
      );

      if (isLogout) {
        unawaited(WishlistLocalCache.clear());
        return;
      }

      // دمج المفضلة المحفوظة مسبقاً للزائر فقط عند تسجيل الدخول الفعلي أو وجود عناصر محلية غير فارغة
      final shouldSync = isLogin || localIds.isNotEmpty || previousUserId == 'guest';
      if (shouldSync) {
        try {
          final serverItems = await _repo.syncWishlist(localIds);
          final serverIds = serverItems.map((e) => e.id).toSet();
          state = state.copyWith(
            items: serverItems,
            favoriteIds: serverIds,
            cachedItemCount: serverItems.length,
          );
          unawaited(WishlistLocalCache.saveFavoriteIds(serverIds));
        } catch (e) {
          debugPrint('[WishlistNotifier] Error syncing wishlist on session change: $e');
        }
      } else {
        unawaited(refreshFavoriteIds(force: true));
      }
      return;
    }

    state = state.copyWith(
      activeUserId: userId,
      sessionGeneration: generation,
    );
  }

  // ==========================================
  // دوال الربط التوافقي مع السلة والتنقل
  // ==========================================

  /// إضافة منتج إلى السلة
  void addToCart(HomeProductItem item) {
    ref.read(cartProvider.notifier).addToCart(item);

    final context = AppNav.currentContext;
    if (context != null) {
      CartAddedDialog.show(context);
    }
  }

  /// إضافة جميع عناصر المفضلة إلى السلة دفعة واحدة
  void addAllToCart() {
    if (state.items.isEmpty) return;

    for (final item in state.items) {
      ref.read(cartProvider.notifier).addToCart(item);
    }

    final context = AppNav.currentContext;
    if (context != null) {
      CartAddedDialog.show(context);
    }
  }

  /// فتح شاشة تفاصيل المنتج
  void openProduct(HomeProductItem item) {
    final isSale = (item.discountPercent ?? 0) > 0;
    AppNav.toNamed(
      AppRoutes.product,
      arguments: {'item': item, 'forceSale': isSale},
    );
  }

  /// فتح السلة
  void openCart() {
    try {
      globalProviderContainer.read(mainNavigationProvider.notifier).state = 3;
    } catch (_) {}
    AppNav.toNamed(AppRoutes.cart);
  }

  /// الانتقال إلى الصفحة الرئيسية
  void goToHome() {
    try {
      globalProviderContainer.read(mainNavigationProvider.notifier).state = 0;
    } catch (_) {}
    AppNav.offAllNamed(AppRoutes.main);
  }
}
