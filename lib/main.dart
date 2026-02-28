import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/bindings/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/translations/app_translations.dart';

import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // Bindings عامة
      initialBinding: InitialBinding(),

      // Routes
      initialRoute: AppRoutes.main,
      getPages: AppPages.routes,

      // Theme
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,

      // Translations
      translations: AppTranslations(),
      locale: const Locale('ar', 'YE'),
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
