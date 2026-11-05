import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// هذا الملف مسؤول عن حالات الواجهة العامة الخاصة بإعدادات التطبيق.
///
/// نستخدمه لعزل:
/// - وضع الثيم الحالي
/// - اللغة الحالية
///
/// الهدف أن يبقى الكنترولر الرئيسي مسؤولًا عن منطق التطبيق
/// وتطبيق التغييرات على GetX، بينما تبقى الحالة الخام هنا.
class AppSettingsUiController extends GetxController {
  /// وضع الثيم الحالي للتطبيق.
  final themeMode = ThemeMode.light.obs;

  /// اللغة الحالية للتطبيق.
  final locale = const Locale('ar', 'YE').obs;

  /// هذه الدالة تغيّر وضع الثيم الحالي.
  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
  }

  /// هذه الدالة تغيّر اللغة الحالية.
  void setLocale(Locale value) {
    locale.value = value;
  }
}