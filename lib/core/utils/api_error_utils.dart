import 'package:dio/dio.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class ApiErrorUtils {
  const ApiErrorUtils._();

  /// تحويل أي استثناء شبكي أو خطأ في التطبيق إلى رسالة نصية واضحة ومفهومة للمستخدم
  static String toMessage(Object error) {
    // 1. فحص استثناءات DioException
    if (error is DioException) {
      return _fromDioException(error);
    }

    // 2. فحص استثناءات ApiException المخصصة
    if (error is ValidationException) {
      return _fromValidationException(error);
    }

    if (error is AccountBannedException) {
      return error.message;
    }

    if (error is ApiException) {
      if (_isInvalidCredentials(error.message)) {
        return Tk.loginInvalidCredentials.tr;
      }
      return error.message;
    }

    // 3. فحص استثناءات AuthApiException
    if (error is AuthApiException) {
      if (_isInvalidCredentials(error.message)) {
        return Tk.loginInvalidCredentials.tr;
      }
      return error.message;
    }

    // 4. فحص النصوص العامة والاستثناءات الأخرى
    final text = error.toString();
    if (_isInvalidCredentials(text)) {
      return Tk.loginInvalidCredentials.tr;
    }

    final key = toLocaleKey(error);
    return key.tr;
  }

  /// إرجاع مفتاح الترجمة المطابق (للتوافق القديم)
  static String toLocaleKey(Object error) {
    if (error is DioException) {
      final inner = error.error;
      if (inner != null) {
        return toLocaleKey(inner);
      }
      if (error.response?.statusCode == 422) {
        final data = error.response?.data;
        if (data is Map && _containsInvalidCredentials(data)) {
          return Tk.loginInvalidCredentials;
        }
        return Tk.commonValidationError;
      }
      if (error.response?.statusCode == 401) return Tk.commonUnauthorized;
      if (error.response?.statusCode == 403) return Tk.commonForbidden;
      if (error.response?.statusCode == 404) return Tk.commonNotFound;
      if (error.response?.statusCode == 500) return Tk.commonServerError;
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout) {
        return Tk.commonTimeoutError;
      }
      if (error.type == DioExceptionType.connectionError) {
        return Tk.commonNetworkError;
      }
    }

    if (error is ValidationException) {
      if (_isInvalidCredentials(error.combinedErrorMessage) ||
          _isInvalidCredentials(error.message)) {
        return Tk.loginInvalidCredentials;
      }
      return Tk.commonValidationError;
    }

    if (error is AuthApiException) {
      return _fromAuthApiException(error);
    }

    final text = error.toString().toLowerCase();
    return _fromRawText(text);
  }

  static String _fromDioException(DioException error) {
    // أ) فحص الاستثناء المربوط بداخل DioException إن وجد
    final innerError = error.error;
    if (innerError is ValidationException) {
      return _fromValidationException(innerError);
    }
    if (innerError is AccountBannedException) {
      return innerError.message;
    }
    if (innerError is ApiException) {
      if (_isInvalidCredentials(innerError.message)) {
        return Tk.loginInvalidCredentials.tr;
      }
      return innerError.message;
    }

    // ب) فحص بيانات الاستجابة من السيرفر rawResponse
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      // 1. أخطاء التحقق (Validation Errors)
      if (data['errors'] is Map) {
        final errorsMap = data['errors'] as Map;
        for (final entry in errorsMap.entries) {
          final val = entry.value;
          if (val is List && val.isNotEmpty) {
            final firstMsg = val.first.toString();
            if (_isInvalidCredentials(firstMsg) ||
                _isInvalidCredentials(entry.key.toString())) {
              return Tk.loginInvalidCredentials.tr;
            }
            return firstMsg;
          } else if (val != null) {
            final msg = val.toString();
            if (_isInvalidCredentials(msg)) {
              return Tk.loginInvalidCredentials.tr;
            }
            return msg;
          }
        }
      }

      // 2. رسالة الخطأ المباشرة من السيرفر
      if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        final msg = data['message'] as String;
        if (_isInvalidCredentials(msg)) {
          return Tk.loginInvalidCredentials.tr;
        }
        return msg;
      }
    }

    // ج) فحص رمز الحالة HTTP
    final statusCode = error.response?.statusCode;
    if (statusCode == 422) {
      return Tk.loginInvalidCredentials.tr;
    }
    if (statusCode == 401) {
      return Tk.commonUnauthorized.tr;
    }
    if (statusCode == 403) {
      return Tk.commonForbidden.tr;
    }
    if (statusCode == 404) {
      return Tk.commonNotFound.tr;
    }
    if (statusCode != null && statusCode >= 500) {
      return Tk.commonServerError.tr;
    }

    // د) فحص نوع خطأ الشبكة
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return Tk.commonTimeoutError.tr;
    }
    if (error.type == DioExceptionType.connectionError) {
      return Tk.commonNetworkError.tr;
    }

    return Tk.commonUnknownApiError.tr;
  }

  static String _fromValidationException(ValidationException error) {
    // 1. فحص إذا كان الخطأ متعلقاً ببيانات تسجيل الدخول (Email/Password)
    for (final entry in error.errors.entries) {
      final field = entry.key.toLowerCase();
      final messages = entry.value;
      for (final msg in messages) {
        if (_isInvalidCredentials(msg) ||
            _isInvalidCredentials(field) ||
            field == 'email' ||
            field == 'password') {
          if (_isInvalidCredentials(msg) || field == 'email') {
            return Tk.loginInvalidCredentials.tr;
          }
        }
      }
    }

    if (_isInvalidCredentials(error.message)) {
      return Tk.loginInvalidCredentials.tr;
    }

    // 2. إرجاع أول رسالة خطأ محددة من السيرفر إن وجدت
    if (error.errors.isNotEmpty) {
      for (final list in error.errors.values) {
        if (list.isNotEmpty) {
          final first = list.first;
          if (_isInvalidCredentials(first)) {
            return Tk.loginInvalidCredentials.tr;
          }
          return first;
        }
      }
    }

    if (error.message.isNotEmpty &&
        !error.message.toLowerCase().contains('unprocessable')) {
      return error.message;
    }

    return Tk.commonValidationError.tr;
  }

  static bool _containsInvalidCredentials(Map data) {
    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;
      for (final val in errors.values) {
        if (val is List) {
          for (final msg in val) {
            if (_isInvalidCredentials(msg.toString())) return true;
          }
        } else if (val != null && _isInvalidCredentials(val.toString())) {
          return true;
        }
      }
    }
    if (data['message'] != null &&
        _isInvalidCredentials(data['message'].toString())) {
      return true;
    }
    return false;
  }

  static bool _isInvalidCredentials(String text) {
    final lower = text.toLowerCase();
    return lower.contains('auth.failed') ||
        lower.contains('provided credentials') ||
        lower.contains('credentials do not match') ||
        lower.contains('do not match our records') ||
        lower.contains('these credentials') ||
        lower.contains('invalid credentials') ||
        lower.contains('incorrect password') ||
        lower.contains('incorrect email') ||
        lower.contains('بيانات الاعتماد') ||
        lower.contains('غير متطابقة') ||
        lower.contains('غير صحيحة') ||
        lower.contains('كلمة المرور غير صحيحة') ||
        lower.contains('البريد أو كلمة المرور');
  }

  static String _fromAuthApiException(AuthApiException error) {
    final message = error.message;
    if (_isInvalidCredentials(message)) {
      return Tk.loginInvalidCredentials;
    }

    if (message
            .toLowerCase()
            .contains('two factor authentication code required') ||
        message.toLowerCase().contains('two_factor_required')) {
      return Tk.loginTwoFactorRequired;
    }

    final statusCode = error.statusCode;
    if (statusCode == 401) return Tk.commonUnauthorized;
    if (statusCode == 403) return Tk.commonForbidden;
    if (statusCode == 404) return Tk.commonNotFound;
    if (statusCode == 422 || error.hasValidationErrors) {
      return Tk.commonValidationError;
    }
    if (statusCode == 500) return Tk.commonServerError;
    if (statusCode == 503) return Tk.commonServiceUnavailable;

    return _fromRawText(message.toLowerCase());
  }

  static String _fromRawText(String text) {
    if (_isInvalidCredentials(text)) {
      return Tk.loginInvalidCredentials;
    }

    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network') ||
        text.contains('connection refused')) {
      return Tk.commonNetworkError;
    }

    if (text.contains('timeout') || text.contains('timed out')) {
      return Tk.commonTimeoutError;
    }

    if (text.contains('401') || text.contains('unauthorized')) {
      return Tk.commonUnauthorized;
    }

    if (text.contains('403') || text.contains('forbidden')) {
      return Tk.commonForbidden;
    }

    if (text.contains('404') || text.contains('not found')) {
      return Tk.commonNotFound;
    }

    if (text.contains('422') ||
        text.contains('validation') ||
        text.contains('unprocessable entity')) {
      return Tk.commonValidationError;
    }

    if (text.contains('500')) {
      return Tk.commonServerError;
    }

    if (text.contains('503') || text.contains('service unavailable')) {
      return Tk.commonServiceUnavailable;
    }

    return Tk.commonUnknownApiError;
  }
}
