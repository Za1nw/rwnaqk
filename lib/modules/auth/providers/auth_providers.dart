import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/register_service.dart';

/// مزود خدمة تسجيل الدخول [LoginService]
final loginServiceProvider = Provider<LoginService>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final sessionNotifier = ref.watch(authSessionProvider.notifier);
  return LoginService(repo, sessionNotifier);
});

/// مزود خدمة إنشاء الحساب [RegisterService]
final registerServiceProvider = Provider<RegisterService>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final sessionNotifier = ref.watch(authSessionProvider.notifier);
  final geoApi = GeoLookupApiService();
  return RegisterService(repo, sessionNotifier, geoApi);
});

/// مزود خدمة استعادة كلمة المرور [ForgotPasswordService]
final forgotPasswordServiceProvider = Provider<ForgotPasswordService>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final sessionNotifier = ref.watch(authSessionProvider.notifier);
  return ForgotPasswordService(repo, sessionNotifier);
});
