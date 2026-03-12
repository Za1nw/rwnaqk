import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_service.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_ui_controller.dart';

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

  late final AppSettingsUiController ui;

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
}