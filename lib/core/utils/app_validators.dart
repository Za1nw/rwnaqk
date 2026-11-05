import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

/// أدوات مركزية وموحدة للتحقق من صحة المدخلات في جميع نماذج التطبيق.
class AppValidators {
  AppValidators._();

  /// التحقق من أن الحقل ليس فارغاً
  static String? required(String? value, String message) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return message;
    }
    return null;
  }

  /// التحقق من صحة البريد الإلكتروني
  static String? email(
    String? value, {
    String? requiredMsg,
    String? invalidMsg,
  }) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return requiredMsg ?? Tk.loginEmailRequired.tr;
    }
    if (!GetUtils.isEmail(text)) {
      return invalidMsg ?? Tk.loginEmailInvalid.tr;
    }
    return null;
  }

  /// التحقق من صحة رقم الهاتف (اليمن والدولي)
  static String? phone(
    String? value, {
    String? requiredMsg,
    String? invalidMsg,
    int minDigits = 8,
  }) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return requiredMsg ?? Tk.registerPhoneRequired.tr;
    }
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.length < minDigits) {
      return invalidMsg ?? Tk.registerPhoneInvalid.tr;
    }
    return null;
  }

  /// التحقق من كلمة المرور
  static String? password(
    String? value, {
    String? requiredMsg,
    String? shortMsg,
    int minLength = 6,
  }) {
    final text = value ?? '';
    if (text.isEmpty) {
      return requiredMsg ?? Tk.loginPasswordRequired.tr;
    }
    if (text.length < minLength) {
      return shortMsg ?? Tk.loginPasswordShort.tr;
    }
    return null;
  }

  /// التحقق من تطابق تأكيد كلمة المرور
  static String? confirmPassword(
    String? value,
    String originalPassword, {
    String? requiredMsg,
    String? mismatchMsg,
  }) {
    final text = value ?? '';
    if (text.isEmpty) {
      return requiredMsg ?? Tk.registerConfirmPasswordRequired.tr;
    }
    if (text != originalPassword) {
      return mismatchMsg ?? Tk.registerPasswordMismatch.tr;
    }
    return null;
  }

  /// التحقق من القوائم المنسدلة والاختيارات
  static String? requiredSelection<T>(T? value, String message) {
    if (value == null) {
      return message;
    }
    if (value is String && value.trim().isEmpty) {
      return message;
    }
    return null;
  }
}

