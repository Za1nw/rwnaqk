import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_notifier.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/app_confirm_dialog.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// هذا الملف هو الكنترولر الرئيسي لإعدادات التطبيق.
///
/// نستخدمه لإدارة:
/// - وضع الثيم
/// - اللغة الحالية
/// - الإشعارات والعملة
/// - تطبيق التغييرات على مستوى التطبيق بالكامل
class AppSettingsController extends GetxController {
  AppSettingsController(this._service);

  final AppSettingsService _service;
  final _authSession = Get.find<AuthSessionService>();
  final _authApi = Get.find<CustomerAuthApiService>();

  late final AppSettingsUiController ui;

  final isLoggingOut = false.obs;

  /// إشعارات العروض وحالة الشحنات
  final notificationsEnabled = true.obs;

  /// العملة المعتمدة للعرض (YER, SAR, USD)
  final selectedCurrency = 'YER'.obs;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات والمكونات.
  Rx<ThemeMode> get themeMode => ui.themeMode;

  /// هذا bridge للإبقاء على نفس الاستدعاءات الحالية في الشاشات والمكونات.
  Rx<Locale> get locale => ui.locale;

  /// هل الثيم الحالي ليلي؟
  bool get isDark => themeMode.value == ThemeMode.dark;

  /// كود اللغة الحالي.
  String get lang => locale.value.languageCode;

  /// النص المختصر للغة الحالية.
  String get langLabel => _service.langLabel(locale.value);

  @override
  void onInit() {
    super.onInit();

    ui = Get.find<AppSettingsUiController>();

    ui.setThemeMode(_service.initialThemeMode());
    ui.setLocale(_service.initialLocale());
  }

  /// تسمية وضع الثيم الحالي
  String get themeModeLabel {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return 'الوضع الليلي (داكن)';
      case ThemeMode.light:
        return 'الوضع النهاري (فاتح)';
      case ThemeMode.system:
        return 'تلقائي (حسب الجهاز)';
    }
  }

  /// أيقونة وضع الثيم الحالي
  IconData get themeModeIcon {
    switch (themeMode.value) {
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.light:
        return Icons.light_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  /// هذه الدالة تغيّر الثيم المختار (نهاري، ليلي، أو تلقائي حسب الجهاز).
  void setThemeMode(ThemeMode mode) {
    ui.setThemeMode(mode);
    Get.changeThemeMode(mode);
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
    AppToast.success(message, title: 'المظهر');
  }

  /// هذه الدالة تغيّر الثيم مباشرة حسب القيمة المطلوبة.
  void setDarkMode(bool value) {
    final mode = value ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(mode);
  }

  /// هذه الدالة تبدّل بين الثيم الفاتح والداكن.
  void toggleTheme() {
    final next = _service.nextThemeMode(themeMode.value);
    setThemeMode(next);
  }

  /// هذه الدالة تبدّل بين العربية والإنجليزية.
  void toggleLanguage() {
    final next = _service.nextLocale(locale.value);
    ui.setLocale(next);
    Get.updateLocale(locale.value);
  }

  /// تعيين لغة محددة مباشرة
  void setLanguage(String code) {
    final newLocale = code == 'en'
        ? const Locale('en', 'US')
        : const Locale('ar', 'YE');
    ui.setLocale(newLocale);
    Get.updateLocale(newLocale);
    AppToast.success(
      code == 'en' ? 'Switched to English' : 'تم تغيير اللغة إلى العربية',
      title: 'لغة التطبيق',
    );
  }

  /// تفعيل أو تعطيل إشعارات العروض وحالة الطلبات
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    if (value) {
      AppToast.success(
        'تم تفعيل إشعارات وتنبيهات الطلبات والعروض',
        title: 'الإشعارات',
      );
    } else {
      AppToast.info('تم إيقاف إشعارات التطبيق مؤقتاً', title: 'الإشعارات');
    }
  }

  /// تغيير عملة العرض
  void setCurrency(String currencyCode) {
    selectedCurrency.value = currencyCode;
    AppToast.success(
      'تم اعتماد عملة العرض: $currencyCode',
      title: 'عملة المتجر',
    );
  }

  Future<void> confirmLogout() async {
    if (isLoggingOut.value) {
      return;
    }

    final confirmed = await AppConfirmDialog.show(
      title: Tk.settingsLogout.tr,
      message: 'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك في رَوْنَقُك؟',
      confirmLabel: 'تسجيل الخروج',
      cancelLabel: Tk.commonCancel.tr,
      icon: Icons.logout_rounded,
      isDestructive: true,
    );

    if (confirmed == true) {
      await logout();
    }
  }

  Future<void> logout() async {
    if (isLoggingOut.value) {
      return;
    }

    isLoggingOut.value = true;

    try {
      final token = (_authSession.token.value ?? '').trim();

      if (token.isNotEmpty && !AppEnv.enableMockData) {
        final response = await _authApi.logout(token: token);

        if (!response.isOk) {
          AppNotifier.errorFrom(
            AuthApiException.fromResponse(
              response,
              fallbackMessage: Tk.commonUnexpectedError.tr,
            ),
          );
        }
      }

      _clearLocalUserData();
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (_) {
      _clearLocalUserData();
      if (Get.currentRoute != AppRoutes.login) {
        Get.offAllNamed(AppRoutes.login);
      }
    } finally {
      isLoggingOut.value = false;
    }
  }

  /// تصفير بيانات الجلسة والسلة والعناوين لضمان عدم تسرب بيانات العميل السابق
  void _clearLocalUserData() {
    _authSession.clearSession();
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().clearCart();
    }
    if (Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().clearOrders();
    }
    if (Get.isRegistered<ProfileStoreService>()) {
      Get.find<ProfileStoreService>().addresses.clear();
    }
  }
}
