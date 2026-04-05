import 'package:flutter/material.dart';

/// هذا الملف مسؤول عن المنطق المساعد الخاص بإعدادات التطبيق.
///
/// نستخدمه لفصل:
/// - القيم الابتدائية
/// - تحديد الثيم التالي
/// - تحديد اللغة التالية
/// - النصوص المساعدة مثل اختصار اللغة
///
/// لاحقًا يمكن توسيعه لحفظ الإعدادات محليًا باستخدام:
/// - SharedPreferences
/// - Hive
/// - أو أي Local Storage آخر
class AppSettingsService {
  /// هذه الدالة تعيد وضع الثيم الابتدائي.
  ThemeMode initialThemeMode() => ThemeMode.light;

  /// هذه الدالة تعيد اللغة الابتدائية.
  Locale initialLocale() => const Locale('ar', 'YE');

  /// هذه الدالة تعيد وضع الثيم التالي عند التبديل.
  ThemeMode nextThemeMode(ThemeMode current) {
    final darkNow = current == ThemeMode.dark;
    return darkNow ? ThemeMode.light : ThemeMode.dark;
  }

  /// هذه الدالة تعيد اللغة التالية عند التبديل.
  Locale nextLocale(Locale current) {
    final isArabic = current.languageCode == 'ar';
    return isArabic ? const Locale('en', 'US') : const Locale('ar', 'YE');
  }

  /// هذه الدالة تعيد كود اللغة المختصر المناسب للعرض.
  String langLabel(Locale locale) {
    return locale.languageCode == 'ar' ? 'AR' : 'EN';
  }
}