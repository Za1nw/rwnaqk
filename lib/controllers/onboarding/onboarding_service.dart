import 'package:flutter/material.dart';

/// هذا الموديل يمثل شريحة واحدة داخل شاشة الـ Onboarding.
///
/// نستخدمه لتعريف:
/// - الأيقونة
/// - مفتاح العنوان
/// - مفتاح الوصف
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

/// هذا الملف مسؤول عن منطق البيانات الخاص بشاشة الـ Onboarding.
///
/// نستخدمه لفصل:
/// - الشرائح الثابتة
/// - التحقق من الصفحة الأخيرة
///
/// لاحقًا إذا أردت جعل الـ onboarding ديناميكيًا أو قادمًا من إعدادات،
/// فهذا هو المكان الطبيعي لذلك.
class OnboardingService {
  /// الشرائح الحالية المعروضة في شاشة الـ Onboarding.
  List<OnboardingSlide> get slides => const <OnboardingSlide>[
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

  /// هذه الدالة تتحقق هل الصفحة الحالية هي الأخيرة أم لا.
  bool isLastPage({
    required int currentIndex,
    required int totalSlides,
  }) {
    if (totalSlides <= 0) return true;
    return currentIndex == totalSlides - 1;
  }
}