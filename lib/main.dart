import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/bindings/initial_binding.dart';
import 'core/constants/local_storage_keys.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/translations/app_translations.dart';

import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding =
      prefs.getBool(LocalStorageKeys.onboardingSeen) ?? false;
  final persistedToken = prefs.getString(LocalStorageKeys.authToken);

  final initialRoute = _resolveInitialRoute(
    hasSeenOnboarding: hasSeenOnboarding,
    persistedToken: persistedToken,
  );

  runApp(MyApp(initialRoute: initialRoute, initialAccessToken: persistedToken));
}

String _resolveInitialRoute({
  required bool hasSeenOnboarding,
  required String? persistedToken,
}) {
  if (!hasSeenOnboarding) {
    return AppRoutes.onboarding;
  }

  final hasToken = (persistedToken ?? '').trim().isNotEmpty;

  return hasToken ? AppRoutes.main : AppRoutes.login;
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.initialRoute = AppRoutes.onboarding,
    this.initialAccessToken,
  });

  final String initialRoute;
  final String? initialAccessToken;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,

      // Bindings عامة
      initialBinding: InitialBinding(initialAccessToken: initialAccessToken),

      // Routes
      initialRoute: initialRoute,
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
