import 'package:get/get.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بشاشة العروض السريعة.
///
/// نستخدمه لعزل:
/// - نسبة الخصم المختارة حاليًا
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن المؤقت والمنتجات،
/// بينما تبقى اختيارات الواجهة المحلية هنا.
class FlashSaleUiController extends GetxController {
  /// نسبة الخصم المختارة حاليًا.
  /// القيمة 0 تعني عرض جميع الخصومات.
  final selectedDiscount = 20.obs;

  /// هذه الدالة تقوم بتغيير نسبة الخصم المختارة.
  void selectDiscount(int discount) {
    selectedDiscount.value = discount;
  }
}