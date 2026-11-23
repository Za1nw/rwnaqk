import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

class LoginResult {
  const LoginResult({
    required this.isSuccess,
    required this.requiresTwoFactor,
    required this.requiresEmailVerification,
    this.isBanned = false,
    this.message,
    this.token,
    this.customer,
  });

  final bool isSuccess;
  final bool requiresTwoFactor;
  final bool requiresEmailVerification;
  final bool isBanned;
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

    if (result.isBanned || result.customer?.isBanned == true) {
      await _session.markAsBanned(
        customerPayload: result.customer,
        reason: result.message,
      );
      return result;
    }

    if (result.isSuccess) {
      final token = result.token ?? '';
      CustomerModel? customer = result.customer;

      if (customer != null) {
        // Path A: بيانات العميل متوفرة في استجابة تسجيل الدخول
        if (customer.isBanned == true) {
          await _session.markAsBanned(
            customerPayload: customer,
            reason: 'تم حظر حسابك. يرجى التواصل مع إدارة المتجر لمزيد من التفاصيل.',
          );
          return LoginResult(
            isSuccess: false,
            requiresTwoFactor: false,
            requiresEmailVerification: false,
            isBanned: true,
            message: 'تم حظر حسابك. يرجى التواصل مع إدارة المتجر لمزيد من التفاصيل.',
            customer: customer,
          );
        }

        await _session.startSession(
          accessToken: token,
          customerPayload: customer,
          emailVerificationRequired: result.requiresEmailVerification,
        );
        return result;
      } else {
        // Path B: بيانات العميل غير متوفرة في استجابة تسجيل الدخول
        if (result.requiresEmailVerification) {
          await _session.startSession(
            accessToken: token,
            customerPayload: null,
            emailVerificationRequired: true,
          );
          return result;
        }

        // التحقق الاستباقي قبل الانتقال إلى authenticated
        final verifiedCustomer = await _session.bootstrapLoginVerification(
          token: token,
        );

        if (verifiedCustomer == null) {
          final isBannedNow = _session.isCurrentSessionBanned;
          return LoginResult(
            isSuccess: false,
            requiresTwoFactor: false,
            requiresEmailVerification: false,
            isBanned: isBannedNow,
            message: isBannedNow
                ? (_session.currentErrorMessage ??
                    'تم حظر حسابك. يرجى التواصل مع إدارة المتجر لمزيد من التفاصيل.')
                : 'فشل التحقق من هوية الحساب، يرجى المحاولة مرة أخرى.',
            customer: null,
          );
        }

        return LoginResult(
          isSuccess: true,
          requiresTwoFactor: false,
          requiresEmailVerification: false,
          isBanned: false,
          message: result.message,
          token: token,
          customer: verifiedCustomer,
        );
      }
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
