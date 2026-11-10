import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/core/utils/app_mask_utils.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

/// هذا الـ enum يحدد وسائل استعادة كلمة المرور المتاحة.
enum RecoveryMethod { sms, email }

class OtpVerificationResult {
  const OtpVerificationResult({
    required this.success,
    required this.requiresEmailVerification,
    this.message,
  });

  final bool success;
  final bool requiresEmailVerification;
  final String? message;
}

/// هذا الملف مسؤول عن المنطق المساعد الخاص بمنظومة استعادة كلمة المرور.
class ForgotPasswordService {
  ForgotPasswordService(this._authRepository, this._session);

  final IAuthRepository _authRepository;
  final AuthSessionNotifier _session;

  /// هذه الدالة تعيد الهدف الحقيقي حسب وسيلة الاستعادة المختارة.
  String resolveTarget(RecoveryMethod method) {
    if (method == RecoveryMethod.sms) {
      return '+967777777777';
    }

    return 'name@example.com';
  }

  /// هذه الدالة تعيد النص المخفي المناسب حسب وسيلة الاستعادة.
  String resolveMaskedTarget({
    required RecoveryMethod method,
    required String target,
  }) {
    if (method == RecoveryMethod.sms) {
      return AppMaskUtils.maskPhone(target);
    }

    return AppMaskUtils.maskEmail(target);
  }

  /// هذه الدالة تتحقق من صلاحية رمز التحقق الحالي.
  bool isValidOtp(String otp) {
    return otp.trim().length >= 4;
  }

  /// هذه الدالة تتحقق من إمكانية حفظ كلمة المرور الجديدة.
  bool canSaveNewPassword({
    required bool isFormValid,
    required String password,
    required String confirmPassword,
  }) {
    if (!isFormValid) return false;
    if (password != confirmPassword) return false;
    return true;
  }

  Future<String> sendPasswordResetLink({required String email}) async {
    await _authRepository.forgotPassword(email: email.trim());
    return 'Password reset link sent.';
  }

  Future<OtpVerificationResult> verifyTwoFactorLogin({
    required String email,
    required String password,
    required String code,
  }) async {
    final result = await _authRepository.login(
      email: email,
      password: password,
      code: code,
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

    return OtpVerificationResult(
      success: result.isSuccess,
      requiresEmailVerification: result.requiresEmailVerification,
      message: result.message,
    );
  }

  Future<String> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    await _authRepository.resetPassword(
      token: token,
      email: email.trim(),
      password: password,
    );
    return 'Password reset successfully.';
  }
}
