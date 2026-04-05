import 'package:get/get.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بالشاشة الرئيسية.
///
/// نستخدمه لعزل:
/// - التبويب الحالي المختار في الـ Bottom Navigation
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن منطق التنقل العام لاحقًا،
/// بينما تبقى حالة الواجهة الخام هنا.
class MainUiController extends GetxController {
  /// رقم التبويب الحالي في الشاشة الرئيسية.
  final currentIndex = 0.obs;

  /// هذه الدالة تغيّر التبويب الحالي.
  void changeTab(int index) {
    currentIndex.value = index;
  }
}