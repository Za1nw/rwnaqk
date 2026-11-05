import 'package:rwnaqk_frontend/core/constants/app_env.dart';

/// Global application constants and configuration values.
class AppConstants {
  AppConstants._();

  static String get appName => AppEnv.appName;
  static const String appVersion = '1.0.0';

  // Timeouts & Durations
  static Duration get connectTimeout =>
      Duration(seconds: AppEnv.apiTimeoutSeconds);
  static Duration get receiveTimeout =>
      Duration(seconds: AppEnv.apiTimeoutSeconds);
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);

  // Pagination & Lists
  static int get defaultPageSize => AppEnv.defaultPageSize;

  // Storage Keys
  static String get tokenKey => AppEnv.storageAuthTokenKey;
  static const String userKey = 'cached_user';
  static const String themeKey = 'app_theme_mode';
  static const String languageKey = 'app_locale';
  static String get isFirstTimeKey => AppEnv.storageOnboardingKey;
}
