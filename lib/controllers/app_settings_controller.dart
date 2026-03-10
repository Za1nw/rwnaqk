import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSettingsController extends GetxController {
  final themeMode = ThemeMode.light.obs;
  final locale = const Locale('ar', 'YE').obs;

  bool get isDark => themeMode.value == ThemeMode.dark;

  String get lang => locale.value.languageCode;

  String get langLabel => lang == 'ar' ? 'AR' : 'EN';

  void setDarkMode(bool value) {
    themeMode.value = value ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(themeMode.value);
  }

  void toggleTheme() {
    final darkNow = themeMode.value == ThemeMode.dark;
    themeMode.value = darkNow ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(themeMode.value);
  }

  void toggleLanguage() {
    final isArabic = locale.value.languageCode == 'ar';
    locale.value =
        isArabic ? const Locale('en', 'US') : const Locale('ar', 'YE');
    Get.updateLocale(locale.value);
  }
}