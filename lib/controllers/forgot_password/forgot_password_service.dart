import 'package:rwnaqk/core/utils/app_mask_utils.dart';

/// هذا الـ enum يحدد وسائل استعادة كلمة المرور المتاحة.
///
/// نستخدمه للتبديل بين:
/// - الرسائل النصية
/// - البريد الإلكتروني
enum RecoveryMethod { sms, email }

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
    return otp.trim().length == 4;
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
}