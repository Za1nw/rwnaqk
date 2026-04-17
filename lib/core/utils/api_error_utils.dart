import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';

class ApiErrorUtils {
  const ApiErrorUtils._();

  static String toLocaleKey(Object error) {
    if (error is AuthApiException) {
      return _fromAuthApiException(error);
    }

    final text = error.toString().toLowerCase();

    return _fromRawText(text);
  }

  static String _fromAuthApiException(AuthApiException error) {
    final message = error.message.toLowerCase();

    if (message.contains('provided credentials') ||
        message.contains('auth.failed') ||
        message.contains('incorrect')) {
      return Tk.loginInvalidCredentials;
    }

    if (message.contains('two factor authentication code required') ||
        message.contains('two_factor_required')) {
      return Tk.loginTwoFactorRequired;
    }

    final statusCode = error.statusCode;

    if (statusCode == null) {
      return _fromRawText(message);
    }

    if (statusCode == 401) {
      return Tk.commonUnauthorized;
    }

    if (statusCode == 403) {
      return Tk.commonForbidden;
    }

    if (statusCode == 404) {
      return Tk.commonNotFound;
    }

    if (statusCode == 422 || error.hasValidationErrors) {
      return Tk.commonValidationError;
    }

    if (statusCode == 500) {
      return Tk.commonServerError;
    }

    if (statusCode == 503) {
      return Tk.commonServiceUnavailable;
    }

    return _fromRawText(message);
  }

  static String _fromRawText(String text) {
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

    if (text.contains('provided credentials') ||
        text.contains('auth.failed') ||
        text.contains('incorrect')) {
      return Tk.loginInvalidCredentials;
    }

    if (text.contains('two factor authentication code required') ||
        text.contains('two_factor_required')) {
      return Tk.loginTwoFactorRequired;
    }

    return Tk.commonUnknownApiError;
  }
}
