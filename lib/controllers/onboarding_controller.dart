import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingSlide {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;

  const OnboardingSlide({
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
  });
}

class OnboardingController extends GetxController {
  final pageCtrl = PageController();
  final pageIndex = 0.obs;

  final slides = const <OnboardingSlide>[
    OnboardingSlide(
      icon: Icons.shopping_bag_rounded,
      titleKey: 'onboarding.s1_title',
      subtitleKey: 'onboarding.s1_subtitle',
    ),
    OnboardingSlide(
      icon: Icons.local_shipping_rounded,
      titleKey: 'onboarding.s2_title',
      subtitleKey: 'onboarding.s2_subtitle',
    ),
    OnboardingSlide(
      icon: Icons.discount_rounded,
      titleKey: 'onboarding.s3_title',
      subtitleKey: 'onboarding.s3_subtitle',
    ),
  ];

  bool get isLast => pageIndex.value == slides.length - 1;

  void onPageChanged(int i) => pageIndex.value = i;

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

  void onSkip() {
    pageCtrl.animateToPage(
      slides.length - 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  // ✅ نفس اللي عندك
  void onGetStarted() {
    // عدّلها حسب روتاتك
    Get.offAllNamed('/main');
  }

  void onHaveAccount() {
    // عدّلها حسب روتاتك
    Get.toNamed('/login');
  }

  @override
  void onClose() {
    pageCtrl.dispose();
    super.onClose();
  }
}