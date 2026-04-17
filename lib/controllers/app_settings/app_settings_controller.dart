import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_service.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_ui_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_notifier.dart';

/// هذا الملف هو الكنترولر الرئيسي لإعدادات التطبيق.
///
/// نستخدمه لإدارة:
/// - وضع الثيم
/// - اللغة الحالية
/// - تطبيق التغييرات على مستوى التطبيق بالكامل
///
/// كما أنه يعمل كحلقة ربط بين:
/// - AppSettingsUiController الخاص بحالة الواجهة
/// - AppSettingsService الخاص بالمنطق المساعد والقيم الابتدائية
class AppSettingsController extends GetxController {
  AppSettingsController(this._service);

  final AppSettingsService _service;
  final _authSession = Get.find<AuthSessionService>();
  final _authApi = Get.find<CustomerAuthApiService>();

  late final AppSettingsUiController ui;

  final isLoggingOut = false.obs;

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
  /// هذه الدالة تُستدعى عند إنشاء الكنترولر لأول مرة.
  /// نستخدمها لتهيئة الـ UI controller بالقيم الابتدائية.
  void onInit() {
    super.onInit();

    ui = Get.find<AppSettingsUiController>();

    ui.setThemeMode(_service.initialThemeMode());
    ui.setLocale(_service.initialLocale());
  }

  /// هذه الدالة تغيّر الثيم مباشرة حسب القيمة المطلوبة.
  ///
  /// نستخدمها مثلًا عند ربط Switch في شاشة الإعدادات.
  void setDarkMode(bool value) {
    final mode = value ? ThemeMode.dark : ThemeMode.light;
    ui.setThemeMode(mode);
    Get.changeThemeMode(themeMode.value);
  }

  /// هذه الدالة تبدّل بين الثيم الفاتح والداكن.
  void toggleTheme() {
    final next = _service.nextThemeMode(themeMode.value);
    ui.setThemeMode(next);
    Get.changeThemeMode(themeMode.value);
  }

  /// هذه الدالة تبدّل بين العربية والإنجليزية.
  void toggleLanguage() {
    final next = _service.nextLocale(locale.value);
    ui.setLocale(next);
    Get.updateLocale(locale.value);
  }

  Future<void> confirmLogout() async {
    if (isLoggingOut.value) {
      return;
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(Tk.settingsLogout.tr),
        content: Text(Tk.settingsLogoutSubtitle.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back<bool>(result: false),
            child: Text(Tk.commonCancel.tr),
          ),
          FilledButton(
            onPressed: () => Get.back<bool>(result: true),
            child: Text(Tk.commonYes.tr),
          ),
        ],
      ),
      barrierDismissible: true,
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

      if (token.isNotEmpty) {
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

      _authSession.clearSession();
      Get.offAllNamed(AppRoutes.login);
    } catch (_) {
      _authSession.clearSession();
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoggingOut.value = false;
    }
  }
}
