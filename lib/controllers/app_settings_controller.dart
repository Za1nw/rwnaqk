import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSettingsController extends GetxController {
  final themeMode = ThemeMode.light.obs;
  final locale = const Locale('ar', 'YE').obs;

  void toggleTheme() {
    final isDark = themeMode.value == ThemeMode.dark;
    themeMode.value = isDark ? ThemeMode.light : ThemeMode.dark;
    Get.changeThemeMode(themeMode.value);
  }

  void toggleLanguage() {
    final isArabic = locale.value.languageCode == 'ar';
    locale.value =
        isArabic ? const Locale('en', 'US') : const Locale('ar', 'YE');
    Get.updateLocale(locale.value);
  }
}
