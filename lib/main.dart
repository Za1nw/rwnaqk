import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_env.dart';
import 'core/constants/local_storage_keys.dart';
import 'core/di/core_providers.dart';
import 'core/localization/app_localizations.dart';
import 'core/routing/app_nav.dart';
import 'core/services/cache/app_image_storage_service.dart';
import 'core/services/monitoring/sentry_event_sanitizer.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'modules/customer/providers/customer_profile_providers.dart';
import 'routes/app_router.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ضبط سياسة كاش الذاكرة (RAM) لمحرك فلاتر لحماية الأجهزة الضعيفة من استهلاك الذاكرة
  AppImageStorageService.instance.configureImageMemoryCache();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Could not load .env file: $e');
  }

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding =
      prefs.getBool(LocalStorageKeys.onboardingSeen) ?? false;
  final hasSavedSession = prefs.getBool('has_auth_session') ?? false;

  final initialRoute = !hasSeenOnboarding
      ? AppRoutes.onboarding
      : (hasSavedSession ? AppRoutes.main : AppRoutes.login);

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesInstanceProvider.overrideWithValue(prefs),
    ],
  );
  globalProviderContainer = container;

  // تهيئة فورية لحالة الجلسة في الذاكرة لتفادي استدعاء KeyStore وحظر الإقلاع
  if (hasSavedSession) {
    container
        .read(authSessionProvider.notifier)
        .primeSession(token: 'cached_session');
  }

  Widget buildRootApp() {
    return UncontrolledProviderScope(
      container: container,
      child: MyApp(
        initialRoute: initialRoute,
      ),
    );
  }

  final dsn = AppEnv.sentryDsn;

  // 1. إطلاق واجهة التطبيق فوراً لإنهاء شاشة الشعار (Splash) فوراً دون أي حظر
  if (dsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.environment = AppEnv.appEnv;
        options.sendDefaultPii = false;
        options.tracesSampleRate = null;
        options.debug = false;
        options.enableLogs = false;
        options.enableMetrics = false;
        options.recordHttpBreadcrumbs = false;
        options.replay.sessionSampleRate = null;
        options.replay.onErrorSampleRate = null;
        options.beforeSend = SentryEventSanitizer.sanitize;
      },
      appRunner: () => runApp(buildRootApp()),
    );
  } else {
    runApp(buildRootApp());
  }

  // 2. قراءة التخزين المشفر والتحقق من التوكن في الخلفية بعد رسم أول إطار بالكامل
  unawaited(
    container.read(authSessionProvider.notifier).bootstrapSession(),
  );
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
