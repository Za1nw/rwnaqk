import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/passkey_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/user_session_model.dart';

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
    String? gender,
    String? deviceName,
  });

  Future<CustomerModel> me();

  Future<void> logout();

  Future<void> forgotPassword({required String email});

  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  });

  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
  });

  Future<void> sendEmailVerificationCode();

  Future<void> verifyEmailCode({required String code});

  Future<CustomerModel> updateProfile({
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? mobile,
    String? gender,
    String? avatarFilePath,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  });

  Future<List<UserSessionModel>> getSessions();

  Future<void> revokeSession(int id);

  Future<void> revokeOtherSessions();

  Future<List<PasskeyModel>> getPasskeys();

  Future<PasskeyModel> storePasskey({
    required String name,
    String? credentialId,
    Map<String, dynamic>? credential,
  });

  Future<LoginResult> passkeyLogin({
    required String credentialId,
    String? secret,
    String? email,
  });

  Future<void> deletePasskey(int id);
}

