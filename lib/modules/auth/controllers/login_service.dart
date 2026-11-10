import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

class LoginResult {
  const LoginResult({
    required this.isSuccess,
    required this.requiresTwoFactor,
    required this.requiresEmailVerification,
    this.message,
    this.token,
    this.customer,
  });

  final bool isSuccess;
  final bool requiresTwoFactor;
  final bool requiresEmailVerification;
  final String? message;
  final String? token;
  final CustomerModel? customer;
}

class LoginService {
  LoginService(this._authRepository, this._session);

  final IAuthRepository _authRepository;
  final AuthSessionNotifier _session;

  Future<LoginResult> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
  }) async {
    final result = await _authRepository.login(
      email: email,
      password: password,
      code: code,
      recoveryCode: recoveryCode,
    );

    if (result.isSuccess) {
      CustomerModel? customer = result.customer;
      if (customer == null) {
        try {
          customer = await _authRepository.me();
        } catch (_) {}
      }

      _session.startSession(
        accessToken: result.token ?? '',
        customerPayload: customer,
        emailVerificationRequired: result.requiresEmailVerification,
      );
    }

    return result;
  }

  Future<String> sendEmailVerificationNotification() async {
    await _authRepository.sendEmailVerificationCode();
    return 'Verification email sent.';
  }

  Future<String> sendEmailVerificationCode() async {
    await _authRepository.sendEmailVerificationCode();
    return 'Verification code sent.';
  }

  Future<String> verifyEmailVerificationCode({required String code}) async {
    await _authRepository.verifyEmailCode(code: code);
    await _session.completeEmailVerification();
    return 'Email verified successfully.';
  }
}
