import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/two_factor_settings_service.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

// ==========================================
// 1. THEME MODE PROVIDER
// ==========================================

const String kAppThemeModeStorageKey = 'app_theme_mode';

final appThemeModeProvider =
    NotifierProvider<AppThemeModeNotifier, ThemeMode>(AppThemeModeNotifier.new);

class AppThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return _readInitialSavedTheme();
  }

  ThemeMode _readInitialSavedTheme() {
    try {
      final prefs = ref.read(sharedPreferencesInstanceProvider);
      final val = prefs?.getString(kAppThemeModeStorageKey);
      if (val == 'dark') return ThemeMode.dark;
      if (val == 'light') return ThemeMode.light;
      return ThemeMode.system;
    } catch (_) {
      return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = ref.read(sharedPreferencesInstanceProvider);
      if (prefs != null) {
        final val = mode == ThemeMode.dark
            ? 'dark'
            : (mode == ThemeMode.light ? 'light' : 'system');
        await prefs.setString(kAppThemeModeStorageKey, val);
      }
    } catch (_) {}

    String message;
    switch (mode) {
      case ThemeMode.dark:
        message = 'تم تفعيل الوضع الليلي';
        break;
      case ThemeMode.light:
        message = 'تم تفعيل الوضع النهاري';
        break;
      case ThemeMode.system:
        message = 'تم تفعيل الوضع التلقائي حسب الجهاز';
        break;
    }
    AppNotifier.info(message, isKey: false);
  }
}

// ==========================================
// 2. CUSTOMER SETTINGS PROVIDER
// ==========================================

class CustomerSettingsState {
  const CustomerSettingsState({
    this.notificationsEnabled = true,
    this.selectedCurrency = 'YER',
    this.isLoggingOut = false,
  });

  final bool notificationsEnabled;
  final String selectedCurrency;
  final bool isLoggingOut;

  CustomerSettingsState copyWith({
    bool? notificationsEnabled,
    String? selectedCurrency,
    bool? isLoggingOut,
  }) {
    return CustomerSettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      isLoggingOut: isLoggingOut ?? this.isLoggingOut,
    );
  }
}

final customerSettingsProvider =
    NotifierProvider<CustomerSettingsNotifier, CustomerSettingsState>(
  CustomerSettingsNotifier.new,
);

class CustomerSettingsNotifier extends Notifier<CustomerSettingsState> {
  @override
  CustomerSettingsState build() => const CustomerSettingsState();

  void toggleNotifications(bool enabled) {
    state = state.copyWith(notificationsEnabled: enabled);
    AppNotifier.info(
      enabled ? 'تم تفعيل إشعارات المتجر' : 'تم تعطيل إشعارات المتجر',
      isKey: false,
    );
  }

  void setCurrency(String currency) {
    state = state.copyWith(selectedCurrency: currency);
    AppNotifier.info('تم تغيير العملة المعتمدة إلى $currency', isKey: false);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoggingOut: true);
    try {
      try {
        final repo = ref.read(authRepositoryProvider);
        await repo.logout();
      } catch (_) {}

      ref.read(authSessionProvider.notifier).clearSession();
      AppNotifier.success(Tk.settingsLogout.tr);
      AppNav.offAllNamed(AppRoutes.login);
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      state = state.copyWith(isLoggingOut: false);
    }
  }
}

// ==========================================
// 3. PROFILE STATS & INFO PROVIDER
// ==========================================

class ProfileStatsItem {
  const ProfileStatsItem({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

  String get labelKey => label;
}

class ProfileInfoItem {
  const ProfileInfoItem({
    required this.title,
    required this.value,
    required this.icon,
    this.isCopyable = false,
    this.isVerified = false,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final bool isCopyable;
  final bool isVerified;
  final VoidCallback? onTap;

  String get titleKey => title;
}

class CustomerProfileData {
  const CustomerProfileData({
    required this.name,
    required this.phone,
    required this.email,
    required this.avatarUrl,
    required this.membershipTier,
    required this.membershipBadge,
    required this.membershipPerk,
    required this.stats,
    required this.infoItems,
  });

  final String name;
  final String phone;
  final String email;
  final String avatarUrl;
  final String membershipTier;
  final String membershipBadge;
  final String membershipPerk;
  final List<ProfileStatsItem> stats;
  final List<ProfileInfoItem> infoItems;
}

final customerProfileDataProvider = Provider<CustomerProfileData>((ref) {
  final customer = ref.watch(currentCustomerProvider);
  final ordersCount = ref.watch(ordersProvider).orders.length;
  final wishlistCount = ref.watch(wishlistProvider).itemCount;

  final fullName = customer?.fullName;
  final firstName = customer?.firstName;
  final String displayName = (fullName != null && fullName.isNotEmpty)
      ? fullName
      : ((firstName != null && firstName.isNotEmpty)
          ? firstName
          : 'عميل رَوْنَقُك');

  final phone = customer?.phone;
  final String displayPhone = (phone != null && phone.isNotEmpty)
      ? phone
      : '+967 777 000 000';

  final email = customer?.email;
  final String displayEmail = (email != null && email.isNotEmpty)
      ? email
      : 'customer@rawnaqk.com';

  final stats = [
    ProfileStatsItem(
      label: 'الطلبات',
      value: '$ordersCount',
      icon: Icons.local_shipping_outlined,
      onTap: () => AppNav.toNamed(AppRoutes.orders),
    ),
    ProfileStatsItem(
      label: 'المفضلة',
      value: '$wishlistCount',
      icon: Icons.favorite_border_rounded,
      onTap: () => AppNav.toNamed(AppRoutes.wishlist),
    ),
    ProfileStatsItem(
      label: 'نقاط رونق',
      value: '2,450',
      icon: Icons.diamond_outlined,
    ),
    ProfileStatsItem(
      label: 'القسائم',
      value: '3 كود',
      icon: Icons.confirmation_number_outlined,
    ),
  ];

  final infoItems = [
    ProfileInfoItem(
      title: 'الاسم بالكامل',
      value: displayName,
      icon: Icons.person_outline_rounded,
    ),
    ProfileInfoItem(
      title: 'رقم الهاتف',
      value: displayPhone,
      icon: Icons.phone_outlined,
    ),
    ProfileInfoItem(
      title: 'البريد الإلكتروني',
      value: displayEmail,
      icon: Icons.mail_outline_rounded,
    ),
    ProfileInfoItem(
      title: 'العناوين المحفوظة',
      value: 'إدارة عناوين التوصيل',
      icon: Icons.location_on_outlined,
      onTap: () => AppNav.toNamed(AppRoutes.addresses),
    ),
  ];

  return CustomerProfileData(
    name: displayName,
    phone: displayPhone,
    email: displayEmail,
    avatarUrl: customer?.avatarUrl ?? '',
    membershipTier: 'عضوية رونق الذهبية VIP',
    membershipBadge: 'VIP Gold',
    membershipPerk: 'شحن مجاني + خصم حصري 15%',
    stats: stats,
    infoItems: infoItems,
  );
});

// ==========================================
// 4. TWO-FACTOR SETTINGS PROVIDER
// ==========================================

class TwoFactorState {
  const TwoFactorState({
    this.isEnabled = false,
    this.requiresConfirmation = false,
    this.hasSetupData = false,
    this.manualSetupKey = '',
    this.setupCode = '',
    this.recoveryCodes = const <String>[],
    this.isLoading = false,
    this.isSubmitting = false,
  });

  final bool isEnabled;
  final bool requiresConfirmation;
  final bool hasSetupData;
  final String manualSetupKey;
  final String setupCode;
  final List<String> recoveryCodes;
  final bool isLoading;
  final bool isSubmitting;

  bool get canConfirmCode => setupCode.trim().length == 6;

  TwoFactorState copyWith({
    bool? isEnabled,
    bool? requiresConfirmation,
    bool? hasSetupData,
    String? manualSetupKey,
    String? setupCode,
    List<String>? recoveryCodes,
    bool? isLoading,
    bool? isSubmitting,
  }) {
    return TwoFactorState(
      isEnabled: isEnabled ?? this.isEnabled,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      hasSetupData: hasSetupData ?? this.hasSetupData,
      manualSetupKey: manualSetupKey ?? this.manualSetupKey,
      setupCode: setupCode ?? this.setupCode,
      recoveryCodes: recoveryCodes ?? this.recoveryCodes,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final twoFactorSettingsNotifierProvider =
    NotifierProvider<TwoFactorSettingsNotifier, TwoFactorState>(
  TwoFactorSettingsNotifier.new,
);

class TwoFactorSettingsNotifier extends Notifier<TwoFactorState> {
  late final TwoFactorSettingsService _service;

  @override
  TwoFactorState build() {
    _service = TwoFactorSettingsService(
      CustomerAuthApiService(),
      getToken: () => ref.read(authSessionProvider).token ?? '',
    );
    Future.microtask(loadStatus);
    return const TwoFactorState();
  }

  void setSetupCode(String code) {
    state = state.copyWith(setupCode: code.trim());
  }

  Future<void> loadStatus() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);
    try {
      final res = await _service.fetchStatus();
      List<String> codes = const [];
      if (res.enabled) {
        codes = await _service.fetchRecoveryCodes();
      }
      state = state.copyWith(
        isEnabled: res.enabled,
        requiresConfirmation: res.requiresConfirmation,
        hasSetupData: res.hasSetupData,
        manualSetupKey: res.manualSetupKey ?? '',
        recoveryCodes: codes,
      );
    } catch (_) {} finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> enable() async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);
    try {
      final res = await _service.enable();
      state = state.copyWith(
        isEnabled: res.enabled,
        requiresConfirmation: res.requiresConfirmation,
        hasSetupData: res.hasSetupData,
        manualSetupKey: res.manualSetupKey ?? '',
        recoveryCodes: res.recoveryCodes,
      );
      if (res.requiresConfirmation) {
        AppNotifier.success(Tk.profileTwoFactorSetupPending);
      }
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> confirmSetup() async {
    if (state.isSubmitting || !state.canConfirmCode) return;
    state = state.copyWith(isSubmitting: true);
    try {
      final msg = await _service.confirm(code: state.setupCode);
      AppNotifier.success(msg, isKey: false);
      await loadStatus();
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> disable([String? password]) async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);
    try {
      final msg = await _service.disable();
      AppNotifier.success(msg, isKey: false);
      await loadStatus();
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }

  Future<void> regenerateRecoveryCodes() async {
    if (state.isSubmitting) return;
    state = state.copyWith(isSubmitting: true);
    try {
      final codes = await _service.regenerateRecoveryCodes();
      state = state.copyWith(recoveryCodes: codes);
      AppNotifier.success('تم تجديد رموز الاسترداد بنجاح', isKey: false);
    } catch (e) {
      AppNotifier.errorFrom(e);
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}
