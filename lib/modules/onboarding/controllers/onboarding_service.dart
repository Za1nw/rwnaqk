import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/local_storage_keys.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نموذج شريحة العرض التقديمي في شاشة التهيئة [OnboardingScreen].
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

/// خدمة بيانات ومنطق شاشة التهيئة والتحقق من حفظ حالة الإتمام.
class OnboardingService {
  OnboardingService({SharedPreferences? preferences}) : _prefs = preferences;

  final SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  /// التحقق هل أكمل العميل شاشة التهيئة مسبقاً (قراءة متزامنة عند توفر كائن التفضيلات).
  bool hasSeenOnboardingSync() {
    try {
      return _prefs?.getBool(LocalStorageKeys.onboardingSeen) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// التحقق هل أكمل العميل شاشة التهيئة مسبقاً.
  Future<bool> hasSeenOnboarding() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getBool(LocalStorageKeys.onboardingSeen) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// تسجيل إتمام شاشة التهيئة وحفظها في التخزين المحلي الدائم.
  Future<bool> markOnboardingAsSeen() async {
    try {
      final prefs = await _getPrefs();
      return await prefs.setBool(LocalStorageKeys.onboardingSeen, true);
    } catch (_) {
      return false;
    }
  }

  /// الشرائح المعروضة في شاشة التهيئة.
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

  /// التحقق هل الفهرس الحالي يمثل الشريحة الأخيرة.
  bool isLastPage({
    required int currentIndex,
    required int totalSlides,
  }) {
    if (totalSlides <= 0) return true;
    return currentIndex == totalSlides - 1;
  }
}
