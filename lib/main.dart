import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_env.dart';
import 'core/constants/local_storage_keys.dart';
import 'core/di/core_providers.dart';
import 'core/localization/app_localizations.dart';
import 'core/routing/app_nav.dart';
import 'core/services/auth/auth_token_storage.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'modules/customer/providers/customer_profile_providers.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';

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

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesInstanceProvider.overrideWithValue(prefs),
    ],
  );
  globalProviderContainer = container;

  // Bootstrap authentication session natively in Riverpod
  await container.read(authSessionProvider.notifier).bootstrapSession(
        initialToken: persistedToken,
      );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(
        initialRoute: initialRoute,
      ),
    ),
  );
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

class MyApp extends ConsumerWidget {
  const MyApp({
    super.key,
    this.initialRoute = AppRoutes.onboarding,
  });

  final String initialRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp(
      navigatorKey: appNavigatorKey,
      scaffoldMessengerKey: appScaffoldMessengerKey,
      title: AppEnv.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      onGenerateRoute: AppRouter.onGenerateRoute,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
