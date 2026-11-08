import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Environment Variables Configuration via flutter_dotenv.
class AppEnv {
  AppEnv._();

  static String _safeGet(String key, String fallback) {
    if (!dotenv.isInitialized) return fallback;
    return dotenv.get(key, fallback: fallback);
  }

  // App & Environment
  static String get appName => _safeGet('APP_NAME', 'رونقك');
  static String get appEnv => _safeGet('APP_ENV', 'development');
  static String get appLocale => _safeGet('APP_LOCALE', 'ar_YE');
  static bool get enableDebugLogs =>
      _safeGet('ENABLE_DEBUG_LOGS', 'true').toLowerCase() == 'true';

  static bool get isDevelopment => appEnv.toLowerCase() == 'development';
  static bool get isStaging => appEnv.toLowerCase() == 'staging';
  static bool get isProduction => appEnv.toLowerCase() == 'production';

  // API & Networking
  static String get apiBaseUrl {
    final url = _safeGet('API_BASE_URL', 'http://192.168.8.124:8000');
    if (isProduction && url.startsWith('http://')) {
      debugPrint('[SECURITY ALERT] Insecure cleartext HTTP API_BASE_URL detected in production: $url');
    }
    return url;
  }
  static int get apiTimeoutSeconds =>
      int.tryParse(_safeGet('API_TIMEOUT_SECONDS', '30')) ?? 30;
  static String get apiVersionPrefix =>
      _safeGet('API_VERSION_PREFIX', '/api/v1');
  static String get customerAuthPrefix =>
      _safeGet('CUSTOMER_AUTH_PREFIX', '/api/v1/customer/auth');
  static String get geoLookupPrefix =>
      _safeGet('GEO_LOOKUP_PREFIX', '/api/v1/geo');

  // Features & Mock Data
  static bool get enableMockData {
    // في بيئة الإنتاج الحقيقي: يمنع منعاً باتاً تفعيل البيانات التجريبية أياً كان وضع البناء أو الإعدادات
    if (isProduction) return false;

    final configured = _safeGet('ENABLE_MOCK_DATA', '').toLowerCase();
    if (configured == 'true') return true;
    if (configured == 'false') return false;

    // تفعيل الموك افتراضياً فقط في بيئة التطوير لتشغيل الشاشات دون الحاجة إلى خادم حي
    return isDevelopment;
  }
  static int get defaultPageSize =>
      int.tryParse(_safeGet('DEFAULT_PAGE_SIZE', '15')) ?? 15;

  // Support Contacts
  static String get supportWhatsapp =>
      _safeGet('SUPPORT_WHATSAPP', '+967770000000');
  static String get supportEmail =>
      _safeGet('SUPPORT_EMAIL', 'support@rwnaqk.com');
  static String get supportPhone =>
      _safeGet('SUPPORT_PHONE', '+9671234567');

  // Legal URLs
  static String get termsUrl => _safeGet('TERMS_URL', '/terms');
  static String get privacyPolicyUrl =>
      _safeGet('PRIVACY_POLICY_URL', '/privacy');

  // Storage Keys
  static String get storageAuthTokenKey =>
      _safeGet('STORAGE_AUTH_TOKEN_KEY', 'auth_token');
  static String get storageOnboardingKey =>
      _safeGet('STORAGE_ONBOARDING_KEY', 'onboarding_seen');
}
