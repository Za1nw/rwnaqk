import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

/// عقد مستودع المصادقة النقي
///
/// مستقل تماماً عن أي حزمة إدارة حالة، ويعمل كجسر موحد لعمليات الحسابات.
abstract class IAuthRepository {
  Future<LoginResult> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
    String? deviceName,
  });

  Future<LoginResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String country,
    required String governorate,
    required String password,
    required String passwordConfirmation,
    required bool termsAccepted,
    required bool privacyPolicyAccepted,
    String? deviceName,
  });

  Future<CustomerModel> me();

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
  });

  Future<void> sendEmailVerificationCode();

  Future<void> verifyEmailCode({required String code});
}

