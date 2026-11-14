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
  final List<HomeProductItem> recentlyViewed;
  final int tabIndex;
  final RecentFilter recentFilter;
  final DateTime? selectedDate;
  final String? activeUserId;
  final int sessionGeneration;

  const WishlistState({
    this.items = const [],
    this.recentlyViewed = const [],
    this.tabIndex = 0,
    this.recentFilter = RecentFilter.today,
    this.selectedDate,
    this.activeUserId,
    this.sessionGeneration = 0,
  });

  /// التحقق هل المنتج مضاف للمفضلة الحالية
  bool isInWishlist(String productId) {
    return items.any((item) => item.id == productId);
  }

  int get count => items.length;
  int get itemCount => count;
  int get recentCount => recentlyViewed.length;
  bool get isEmpty => items.isEmpty;

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
    List<HomeProductItem>? recentlyViewed,
    int? tabIndex,
    RecentFilter? recentFilter,
    DateTime? selectedDate,
    bool clearSelectedDate = false,
    String? activeUserId,
    bool clearActiveUserId = false,
    int? sessionGeneration,
  }) {
    return WishlistState(
      items: items != null ? List.unmodifiable(items) : this.items,
      recentlyViewed: recentlyViewed != null
          ? List.unmodifiable(recentlyViewed)
          : this.recentlyViewed,
      tabIndex: tabIndex ?? this.tabIndex,
      recentFilter: recentFilter ?? this.recentFilter,
      selectedDate: clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      activeUserId: clearActiveUserId ? null : (activeUserId ?? this.activeUserId),
      sessionGeneration: sessionGeneration ?? this.sessionGeneration,
    );
  }
}
