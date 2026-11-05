import 'package:rwnaqk_frontend/core/constants/app_env.dart';

abstract class LocalStorageKeys {
  static String get onboardingSeen => AppEnv.storageOnboardingKey;
  static String get authToken => AppEnv.storageAuthTokenKey;
}
