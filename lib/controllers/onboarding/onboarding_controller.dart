import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/onboarding/onboarding_service.dart';
import 'package:rwnaqk/controllers/onboarding/onboarding_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';

/// هذا الملف هو الكنترولر الرئيسي لشاشة الـ Onboarding.
///
/// نستخدمه لإدارة:
/// - الانتقال بين الشرائح
/// - تحديد هل المستخدم في الصفحة الأخيرة
/// - الانتقال إلى الشاشة الرئيسية
/// - الانتقال إلى شاشة تسجيل الدخول
///
/// كما أنه يعمل كحلقة ربط بين:
/// - OnboardingUiController الخاص بحالة الواجهة
/// - OnboardingService الخاص بالبيانات والتجهيزات
class OnboardingController extends GetxController {
  OnboardingController(this._service);

  final OnboardingService _service;

  late final OnboardingUiController ui;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  PageController get pageCtrl => ui.pageCtrl;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشة.
  RxInt get pageIndex => ui.pageIndex;

  /// هذا getter يعيد الشرائح الحالية من الخدمة.
  List<OnboardingSlide> get slides => _service.slides;

  /// هل المستخدم الآن في آخر شريحة؟
  bool get isLast {
    return _service.isLastPage(
      currentIndex: pageIndex.value,
      totalSlides: slides.length,
    );
  }

  @override
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller.
  void onInit() {
    super.onInit();
    ui = Get.find<OnboardingUiController>();
  }

  /// هذه الدالة تُحدّث رقم الصفحة الحالية.
  void onPageChanged(int index) {
    ui.onPageChanged(index);
  }

  /// هذه الدالة تنتقل إلى الصفحة التالية.
  ///
  /// وإذا كان المستخدم في الصفحة الأخيرة، يتم تنفيذ الانتقال
  /// إلى الشاشة الرئيسية مباشرة.
  void onNext() {
    if (isLast) {
      onGetStarted();
      return;
    }

    pageCtrl.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  /// هذه الدالة تنتقل مباشرة إلى آخر شريحة.
  void onSkip() {
    pageCtrl.animateToPage(
      slides.length - 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  /// هذه الدالة تنقل المستخدم إلى الشاشة الرئيسية بعد انتهاء الـ Onboarding.
  void onGetStarted() {
    Get.offAllNamed(AppRoutes.main);
  }

  /// هذه الدالة تنقل المستخدم إلى شاشة تسجيل الدخول.
  void onHaveAccount() {
    Get.toNamed(AppRoutes.login);
  }
}