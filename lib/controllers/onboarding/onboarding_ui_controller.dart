import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// هذا الملف مسؤول عن حالات الواجهة الخاصة بشاشة الـ Onboarding.
///
/// نستخدمه لعزل:
/// - PageController
/// - رقم الصفحة الحالية
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن منطق التنقل والانتقال بين الشاشات،
/// بينما تبقى حالة العرض الحالية هنا.
class OnboardingUiController extends GetxController {
  /// المتحكم المسؤول عن التنقل بين صفحات الـ Onboarding.
  final pageCtrl = PageController();

  /// رقم الصفحة الحالية داخل الـ PageView.
  final pageIndex = 0.obs;

  /// هذه الدالة تُحدّث رقم الصفحة الحالية عند تغيير الصفحة.
  void onPageChanged(int index) {
    pageIndex.value = index;
  }

  @override
  /// هذه الدالة تُستدعى عند التخلص من الكنترولر.
  /// نستخدمها لتحرير PageController.
  void onClose() {
    pageCtrl.dispose();
    super.onClose();
  }
}