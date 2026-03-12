import 'package:get/get.dart';

/// هذا الـ enum يحدد أنواع الفلاتر المتاحة في شاشة الطلبات.
///
/// نستخدمه لعزل خيارات العرض الحالية:
/// - الكل
/// - النشطة
/// - المسلّمة
/// - الملغاة
enum OrdersFilter { all, active, delivered, canceled }

/// هذا الملف مسؤول عن حالات الواجهة فقط الخاصة بشاشة الطلبات.
///
/// نستخدمه لعزل:
/// - الفلتر الحالي المختار
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن بيانات الطلبات،
/// بينما تبقى حالة العرض الحالية هنا.
class OrdersUiController extends GetxController {
  /// الفلتر الحالي المختار في شاشة الطلبات.
  final filter = OrdersFilter.all.obs;

  /// هذه الدالة تقوم بتغيير الفلتر الحالي.
  void setFilter(OrdersFilter value) {
    filter.value = value;
  }
}