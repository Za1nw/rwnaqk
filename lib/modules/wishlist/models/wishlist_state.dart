import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_date_utils.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// نوع فلتر العناصر التي تمت مشاهدتها مؤخرًا.
enum RecentFilter { today, yesterday, date }

/// نموذج الحالة غير القابل للتعديل لوحدة المفضلة [WishlistState].
///
/// يدير قائمة المفضلة، وسجل المشاهدة الأخيرة، والتبويبات، ونطاق جلسة المستخدم.
class WishlistState {
  final List<HomeProductItem> items;
  final Set<String> favoriteIds;
  final List<HomeProductItem> recentlyViewed;
  final int tabIndex;
  final RecentFilter recentFilter;
  final DateTime? selectedDate;
  final String? activeUserId;
  final int sessionGeneration;
  final int cachedItemCount;
  final bool hasLoaded;

  const WishlistState({
    this.items = const [],
    this.favoriteIds = const {},
    this.recentlyViewed = const [],
    this.tabIndex = 0,
    this.recentFilter = RecentFilter.today,
    this.selectedDate,
    this.activeUserId,
    this.sessionGeneration = 0,
    this.cachedItemCount = 0,
    this.hasLoaded = false,
  });

  /// التحقق هل المنتج مضاف للمفضلة الحالية (سواء من الكاش المحلي السريع أو المنتجات المحملة)
  bool isInWishlist(String productId) {
    return favoriteIds.contains(productId) ||
        items.any((item) => item.id == productId);
  }

  int get count => hasLoaded
      ? items.length
      : (favoriteIds.isNotEmpty ? favoriteIds.length : cachedItemCount);
  int get itemCount => count;
  int get recentCount => recentlyViewed.length;
  bool get isEmpty => count == 0;

  /// تسمية الفلتر الحالي للواجهة
  String get recentFilterLabel {
    switch (recentFilter) {
      case RecentFilter.today:
        return Tk.wishlistFilterToday.tr;
      case RecentFilter.yesterday:
        return Tk.wishlistFilterYesterday.tr;
      case RecentFilter.date:
        if (selectedDate == null) return Tk.wishlistFilterChooseDate.tr;
        return AppDateUtils.formatMonthDay(selectedDate!);
    }
  }

  WishlistState copyWith({
    List<HomeProductItem>? items,
    Set<String>? favoriteIds,
    List<HomeProductItem>? recentlyViewed,
    int? tabIndex,
    RecentFilter? recentFilter,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    String? activeUserId,
    bool clearActiveUserId = false,
    int? sessionGeneration,
    int? cachedItemCount,
    bool? hasLoaded,
  }) {
    return WishlistState(
      items: items != null ? List.unmodifiable(items) : this.items,
      favoriteIds: favoriteIds != null
          ? Set.unmodifiable(favoriteIds)
          : this.favoriteIds,
      recentlyViewed: recentlyViewed != null
          ? List.unmodifiable(recentlyViewed)
          : this.recentlyViewed,
      tabIndex: tabIndex ?? this.tabIndex,
      recentFilter: recentFilter ?? this.recentFilter,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      activeUserId: clearActiveUserId ? null : (activeUserId ?? this.activeUserId),
      sessionGeneration: sessionGeneration ?? this.sessionGeneration,
      cachedItemCount: cachedItemCount ?? this.cachedItemCount,
      hasLoaded: hasLoaded ?? this.hasLoaded,
    );
  }
}
