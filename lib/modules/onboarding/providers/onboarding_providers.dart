import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/modules/onboarding/controllers/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// موفر كائن التفضيلات التخزينية [SharedPreferences] لتمريره للخدمات دون قفل متزامن
final sharedPreferencesProvider = Provider<SharedPreferences?>((ref) => null);

/// مزود خدمة شاشة التهيئة [OnboardingService]
final onboardingServiceProvider = Provider<OnboardingService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingService(preferences: prefs);
});

/// موفر حالة إتمام شاشة التهيئة الدائمة [OnboardingCompletionNotifier]
final onboardingCompletionProvider =
    NotifierProvider<OnboardingCompletionNotifier, bool>(
  OnboardingCompletionNotifier.new,
);

/// متحكم حالة إتمام التهيئة
class OnboardingCompletionNotifier extends Notifier<bool> {
  @override
  bool build() {
    final service = ref.watch(onboardingServiceProvider);
    return service.hasSeenOnboardingSync();
  }

  /// حفظ حالة إتمام شاشة التهيئة دائمياً وتحديث الحالة
  Future<bool> completeOnboarding() async {
    final service = ref.read(onboardingServiceProvider);
    final success = await service.markOnboardingAsSeen();
    state = true;
    return success;
  }
}

