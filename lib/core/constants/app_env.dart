import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Environment Variables Configuration via flutter_dotenv.
class AppEnv {
  AppEnv._();

  // App & Environment
  static String get appName => dotenv.get('APP_NAME', fallback: 'رونقك');
  static String get appEnv => dotenv.get('APP_ENV', fallback: 'development');
  static String get appLocale => dotenv.get('APP_LOCALE', fallback: 'ar_YE');
  static bool get enableDebugLogs =>
      dotenv.get('ENABLE_DEBUG_LOGS', fallback: 'true').toLowerCase() == 'true';

  static bool get isDevelopment => appEnv.toLowerCase() == 'development';
  static bool get isProduction => appEnv.toLowerCase() == 'production';

  // API & Networking
  static String get apiBaseUrl =>
      dotenv.get('API_BASE_URL', fallback: 'http://192.168.8.124:8000');
  static int get apiTimeoutSeconds =>
      int.tryParse(dotenv.get('API_TIMEOUT_SECONDS', fallback: '30')) ?? 30;
  static String get apiVersionPrefix =>
      dotenv.get('API_VERSION_PREFIX', fallback: '/api/v1');
  static String get customerAuthPrefix =>
      dotenv.get('CUSTOMER_AUTH_PREFIX', fallback: '/api/v1/customer/auth');
  static String get geoLookupPrefix =>
      dotenv.get('GEO_LOOKUP_PREFIX', fallback: '/api/v1/geo');

  // Features & Mock Data
  static bool get enableMockData =>
      dotenv.get('ENABLE_MOCK_DATA', fallback: 'false').toLowerCase() == 'true';
  static int get defaultPageSize =>
      int.tryParse(dotenv.get('DEFAULT_PAGE_SIZE', fallback: '15')) ?? 15;

  // Support Contacts
  static String get supportWhatsapp =>
      dotenv.get('SUPPORT_WHATSAPP', fallback: '+967770000000');
  static String get supportEmail =>
      dotenv.get('SUPPORT_EMAIL', fallback: 'support@rwnaqk.com');
  static String get supportPhone =>
      dotenv.get('SUPPORT_PHONE', fallback: '+9671234567');

  // Legal URLs
  static String get termsUrl => dotenv.get('TERMS_URL', fallback: '/terms');
  static String get privacyPolicyUrl =>
      dotenv.get('PRIVACY_POLICY_URL', fallback: '/privacy');

  // Storage Keys
  static String get storageAuthTokenKey =>
      dotenv.get('STORAGE_AUTH_TOKEN_KEY', fallback: 'auth_token');
  static String get storageOnboardingKey =>
      dotenv.get('STORAGE_ONBOARDING_KEY', fallback: 'onboarding_seen');
}
