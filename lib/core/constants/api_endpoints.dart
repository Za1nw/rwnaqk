import 'package:rwnaqk_frontend/core/constants/app_env.dart';

/// Centralized API Endpoints based on Environment Configuration.
class ApiEndpoints {
  ApiEndpoints._();

  static String get baseUrl => AppEnv.apiBaseUrl;

  // Prefixes
  static String get apiVersion => AppEnv.apiVersionPrefix;
  static String get customerAuth => AppEnv.customerAuthPrefix;
  static String get geoLookup => AppEnv.geoLookupPrefix;

  // Auth endpoints
  static String get login => '$customerAuth/login';
  static String get register => '$customerAuth/register';
  static String get logout => '$customerAuth/logout';
  static String get profile => '$customerAuth/profile';
}
