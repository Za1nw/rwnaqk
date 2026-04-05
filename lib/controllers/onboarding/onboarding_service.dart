import 'package:flutter/material.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

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
          titleKey: Tk.onboardingS1Title,
          subtitleKey: Tk.onboardingS1Subtitle,
        ),
        OnboardingSlide(
          icon: Icons.local_shipping_rounded,
          titleKey: Tk.onboardingS2Title,
          subtitleKey: Tk.onboardingS2Subtitle,
        ),
        OnboardingSlide(
          icon: Icons.discount_rounded,
          titleKey: Tk.onboardingS3Title,
          subtitleKey: Tk.onboardingS3Subtitle,
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
