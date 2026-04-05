import 'package:get/get.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_date_utils.dart';

/// هذا الـ enum يحدد نوع فلتر العناصر التي تمت مشاهدتها مؤخرًا.
///
/// نستخدمه داخل واجهة الـ Wishlist لتحديد:
/// - اليوم
/// - الأمس
/// - تاريخ محدد
enum RecentFilter { today, yesterday, date }

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بشاشة المفضلة.
///
/// نستخدمه لعزل:
/// - التبويب الحالي
/// - فلتر العناصر التي تمت مشاهدتها مؤخرًا
/// - التاريخ المختار
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن بيانات المفضلة
/// والعمليات الأساسية، بينما تبقى تفاصيل الواجهة هنا.
class WishlistUiController extends GetxController {
  /// التبويب الحالي:
  /// 0 = Wishlist
  /// 1 = Recently viewed
  final RxInt tabIndex = 0.obs;

  /// فلتر العناصر التي تمت مشاهدتها مؤخرًا.
  final Rx<RecentFilter> recentFilter = RecentFilter.today.obs;

  /// التاريخ المختار عند استخدام فلتر التاريخ المخصص.
  final Rxn<DateTime> selectedDate = Rxn<DateTime>();

  /// هذه الدالة تغيّر التبويب الحالي.
  void setTab(int index) {
    tabIndex.value = index;
  }

  /// هذه الدالة تغيّر نوع فلتر المشاهدة الأخيرة.
  /// وإذا لم يكن الفلتر "تاريخ مخصص"، يتم إلغاء التاريخ المختار.
  void setRecentFilter(RecentFilter filter) {
    recentFilter.value = filter;

    if (filter != RecentFilter.date) {
      selectedDate.value = null;
    }
  }

  /// هذه الدالة تختار تاريخًا مخصصًا للفلتر.
  /// ونحوّل التاريخ إلى يوم/شهر/سنة فقط بدون الوقت.
  void chooseDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
    recentFilter.value = RecentFilter.date;
  }

  /// هذه الدالة تعيد النص المناسب لفلتر العرض الحالي.
  /// نستخدمها داخل واجهة RecentFilterRow.
  String recentFilterLabel() {
    switch (recentFilter.value) {
      case RecentFilter.today:
        return Tk.wishlistFilterToday.tr;
      case RecentFilter.yesterday:
        return Tk.wishlistFilterYesterday.tr;
      case RecentFilter.date:
        final date = selectedDate.value;
        if (date == null) return Tk.wishlistFilterChooseDate.tr;
        return AppDateUtils.formatMonthDay(date);
    }
  }
}
