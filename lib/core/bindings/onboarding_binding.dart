import 'package:get/get.dart';
import 'package:rwnaqk/controllers/onboarding/onboarding_controller.dart';
import 'package:rwnaqk/controllers/onboarding/onboarding_service.dart';
import 'package:rwnaqk/controllers/onboarding/onboarding_ui_controller.dart';

/// هذا الملف مسؤول عن حقن التبعيات الخاصة بشاشة الـ Onboarding.
///
/// نستخدم Binding مستقل هنا لأن الشاشة تعمل عبر route مستقل.
class OnboardingBinding extends Bindings {
  @override
  /// هذه الدالة تقوم بتسجيل جميع التبعيات المطلوبة للشاشة.
  void dependencies() {
    Get.lazyPut<OnboardingUiController>(() => OnboardingUiController());
    Get.lazyPut<OnboardingService>(() => OnboardingService());
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(Get.find<OnboardingService>()),
    );
  }
}