import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
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

  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await _authRepository.verifyPasswordResetCode(
      email: email.trim(),
      code: code.trim(),
    );
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

      await _session.startSession(
        accessToken: result.token ?? '',
        customerPayload: customer,
        emailVerificationRequired: result.requiresEmailVerification,
      );

      if (customer == null && !result.requiresEmailVerification) {
        try {
          customer = await _authRepository.me();
          if (customer.isBanned == true) {
            await _session.markAsBanned(
              customerPayload: customer,
              reason: 'تم حظر حسابك. يرجى التواصل مع إدارة المتجر لمزيد من التفاصيل.',
            );
            return OtpVerificationResult(
              success: false,
              requiresEmailVerification: false,
              message: 'تم حظر حسابك. يرجى التواصل مع إدارة المتجر لمزيد من التفاصيل.',
            );
          }
          _session.setCustomer(customer);
        } on AccountBannedException catch (bannedEx) {
          CustomerModel? bannedCustomer;
          if (bannedEx.customerData != null) {
            try {
              bannedCustomer = CustomerModel.fromJson(bannedEx.customerData!);
            } catch (_) {}
          }
          await _session.markAsBanned(
            customerPayload: bannedCustomer,
            reason: bannedEx.message,
          );
          return OtpVerificationResult(
            success: false,
            requiresEmailVerification: false,
            message: bannedEx.message,
          );
        } catch (e, st) {
          debugPrint('[ForgotPasswordService] Warning: Failed to fetch customer profile via me(): $e\n$st');
        }
      }
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
