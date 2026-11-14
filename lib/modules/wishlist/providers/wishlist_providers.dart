import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/cart_added_dialog.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_service.dart';
import 'package:rwnaqk_frontend/modules/wishlist/models/wishlist_state.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// مزود خدمة المفضلة والبيانات المبدئية [WishlistService]
final wishlistServiceProvider = Provider<WishlistService>((ref) {
  return WishlistService();
});

/// موفر الحالة المعتمد والمالك الوحيد للمفضلة في كامل التطبيق [WishlistNotifier]
final wishlistProvider =
    NotifierProvider<WishlistNotifier, WishlistState>(WishlistNotifier.new);

/// متحكم حالة المفضلة المعتمد على Riverpod 3 (Single Authoritative State Owner)
class WishlistNotifier extends Notifier<WishlistState> {
  @override
  WishlistState build() {
    final service = ref.watch(wishlistServiceProvider);

    return WishlistState(
      items: service.initialWishlistItems(),
      recentlyViewed: service.initialRecentlyViewedItems(),
      tabIndex: 0,
      recentFilter: RecentFilter.today,
      activeUserId: null,
      sessionGeneration: 0,
    );
  }

  WishlistService get _service => ref.read(wishlistServiceProvider);

  /// التحقق هل المنتج موجود في المفضلة
  bool isInWishlist(String id) => state.isInWishlist(id);

  /// إضافة أو إزالة المنتج من المفضلة
  void toggle(HomeProductItem item) {
    final updated = _service.toggleItem(
      currentList: state.items,
      item: item,
    );
    state = state.copyWith(items: updated);
  }

  void toggleWishlist(HomeProductItem item) => toggle(item);

  /// إزالة منتج من المفضلة صراحةً
  void remove(HomeProductItem item) {
    final updated = _service.removeItem(
      currentList: state.items,
      item: item,
    );
    state = state.copyWith(items: updated);
  }

  void removeFromWishlist(dynamic itemOrId) {
    if (itemOrId is HomeProductItem) {
      remove(itemOrId);
    } else if (itemOrId is String) {
      final found = state.items.where((e) => e.id == itemOrId);
      if (found.isNotEmpty) {
        remove(found.first);
      } else {
        state = state.copyWith(
          items: state.items.where((e) => e.id != itemOrId).toList(),
        );
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
  void syncWithSession({
    required String? userId,
    required int generation,
  }) {
    final isAccountBoundary =
        state.activeUserId != userId || userId == null;

    if (isAccountBoundary) {
      state = WishlistState(
        items: const [],
        recentlyViewed: const [],
        tabIndex: 0,
        recentFilter: RecentFilter.today,
        selectedDate: null,
        activeUserId: userId,
        sessionGeneration: generation,
      );
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
