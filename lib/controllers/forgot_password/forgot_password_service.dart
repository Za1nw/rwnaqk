import 'package:rwnaqk/core/utils/app_mask_utils.dart';
import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk/models/customer_model.dart';

/// هذا الـ enum يحدد وسائل استعادة كلمة المرور المتاحة.
///
/// نستخدمه للتبديل بين:
/// - الرسائل النصية
/// - البريد الإلكتروني
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
///
/// نستخدمه لفصل:
/// - تحديد الهدف الحالي (هاتف أو بريد)
/// - إخفاء البيانات الحساسة
/// - التحقق من OTP
/// - التحقق من كلمة المرور الجديدة
///
/// لاحقًا عند ربط الـ API، سيكون هذا الملف هو المكان الطبيعي لـ:
/// - إرسال OTP
/// - التحقق من OTP
/// - إعادة تعيين كلمة المرور
class ForgotPasswordService {
  ForgotPasswordService(this._api, this._session);

  final CustomerAuthApiService _api;
  final AuthSessionService _session;

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
  ///
  /// نتحقق من:
  /// - صحة الفورم
  /// - تطابق كلمتي المرور
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
    final response = await _api.forgotPassword(email: email.trim());

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to send reset link.',
      );
    }

    final body = response.body;

    if (body is Map<String, dynamic> && body['message'] is String) {
      return body['message'] as String;
    }

    return 'Password reset link sent.';
  }

  Future<OtpVerificationResult> verifyTwoFactorLogin({
    required String email,
    required String password,
    required String code,
  }) async {
    final response = await _api.login(
      email: email,
      password: password,
      code: code,
    );

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to verify two-factor code.',
      );
    }

    final body = response.body;

    if (body is! Map<String, dynamic>) {
      throw const AuthApiException(
        message: 'Unexpected response while verifying 2FA code.',
      );
    }

    final token = body['token'];

    if (token is! String || token.trim().isEmpty) {
      throw const AuthApiException(
        message: 'Missing token after 2FA verification.',
      );
    }

    _session.startSession(
      accessToken: token,
      customerPayload: _parseCustomer(body['customer']),
      emailVerificationRequired: body['requires_email_verification'] == true,
    );

    return OtpVerificationResult(
      success: true,
      requiresEmailVerification: body['requires_email_verification'] == true,
      message: body['message'] as String?,
    );
  }

  Future<String> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    final response = await _api.resetPassword(
      token: token,
      email: email,
      password: password,
    );

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to reset password.',
      );
    }

    final body = response.body;

    if (body is Map<String, dynamic> && body['message'] is String) {
      return body['message'] as String;
    }

    return 'Password reset successfully.';
  }

  CustomerModel? _parseCustomer(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return CustomerModel.fromJson(payload);
    }

    return null;
  }
}
