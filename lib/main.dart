import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/bindings/initial_binding.dart';
import 'core/constants/app_env.dart';
import 'core/constants/local_storage_keys.dart';
import 'core/services/auth/auth_token_storage.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'core/translations/app_translations.dart';

import 'core/theme/light_theme.dart';
import 'core/theme/dark_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Could not load .env file: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding =
      prefs.getBool(LocalStorageKeys.onboardingSeen) ?? false;
  final tokenStorage = SecureAuthTokenStorage();
  final persistedToken = await tokenStorage.readToken();

  final initialRoute = _resolveInitialRoute(
    hasSeenOnboarding: hasSeenOnboarding,
    persistedToken: persistedToken,
  );

  runApp(MyApp(
    initialRoute: initialRoute,
    initialAccessToken: persistedToken,
    tokenStorage: tokenStorage,
  ));
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
    this.tokenStorage,
  });

  final String initialRoute;
  final String? initialAccessToken;
  final IAuthTokenStorage? tokenStorage;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppEnv.appName,
      debugShowCheckedModeBanner: false,

      // Bindings عامة
      initialBinding: InitialBinding(
        initialAccessToken: initialAccessToken,
        tokenStorage: tokenStorage,
      ),

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
