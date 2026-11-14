import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
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
    final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(text)) {
      return invalidMsg ?? Tk.loginEmailInvalid.tr;
    }
    return null;
  }

  /// التحقق من صحة رقم الهاتف اليمني حصراً (يبدأ بـ 77، 78، 73، 71، أو 70)
  static String? yemenPhone(
    String? value, {
    String? requiredMsg,
    String? invalidMsg,
  }) {
    final text = (value ?? '').trim();
    if (text.isEmpty) {
      return requiredMsg ?? Tk.registerPhoneRequired.tr;
    }

    final clean = text.replaceAll(RegExp(r'[\s\-]'), '');
    final yemenPhoneRegex = RegExp(r'^(?:(?:\+|00)?967|0)?(7[01378]\d{7})$');

    if (!yemenPhoneRegex.hasMatch(clean)) {
      return invalidMsg ??
          'يرجى إدخال رقم هاتف يمني صالح (يبدأ بـ 77، 78، 73، 71، أو 70)';
    }

    return null;
  }

  /// التحقق من صحة رقم الهاتف (اليمن حصراً)
  static String? phone(
    String? value, {
    String? requiredMsg,
    String? invalidMsg,
    int minDigits = 8,
  }) {
    return yemenPhone(
      value,
      requiredMsg: requiredMsg,
      invalidMsg: invalidMsg,
    );
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

