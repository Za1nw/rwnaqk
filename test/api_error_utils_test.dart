import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/api_error_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiErrorUtils Unit Tests', () {
    test('extracts invalid credentials message when Laravel returns auth.failed in 422', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/customer/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/customer/auth/login'),
          statusCode: 422,
          data: {
            'message': 'These credentials do not match our records.',
            'errors': {
              'email': ['These credentials do not match our records.'],
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final message = ApiErrorUtils.toMessage(dioException);
      expect(message, Tk.loginInvalidCredentials.tr);
      expect(message, contains('البريد الإلكتروني أو كلمة المرور غير صحيحة'));
    });

    test('extracts Arabic auth.failed message from Arabic Laravel response', () {
      final dioException = DioException(
        requestOptions: RequestOptions(path: '/api/v1/customer/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/customer/auth/login'),
          statusCode: 422,
          data: {
            'message': 'بيانات الاعتماد هذه غير متطابقة مع سجلاتنا.',
            'errors': {
              'email': ['بيانات الاعتماد هذه غير متطابقة مع سجلاتنا.'],
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final message = ApiErrorUtils.toMessage(dioException);
      expect(message, Tk.loginInvalidCredentials.tr);
    });

    test('extracts invalid credentials from ValidationException with email error', () {
      const valException = ValidationException(
        message: 'The given data was invalid.',
        errors: {
          'email': ['auth.failed'],
        },
      );

      final message = ApiErrorUtils.toMessage(valException);
      expect(message, Tk.loginInvalidCredentials.tr);
    });

    test('extracts specific field validation error when not credentials failure', () {
      const valException = ValidationException(
        message: 'The given data was invalid.',
        errors: {
          'phone': ['رقم الهاتف المدخل غير صالح'],
        },
      );

      final message = ApiErrorUtils.toMessage(valException);
      expect(message, 'رقم الهاتف المدخل غير صالح');
    });

    test('extracts AccountBannedException message accurately', () {
      const bannedException = AccountBannedException(
        message: 'تم حظر حسابك. يرجى التواصل مع إدارة المتجر لمزيد من التفاصيل.',
      );

      final message = ApiErrorUtils.toMessage(bannedException);
      expect(message, contains('تم حظر حسابك'));
    });

    test('extracts NetworkException message accurately', () {
      final networkError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/customer/auth/login'),
        type: DioExceptionType.connectionError,
      );

      final message = ApiErrorUtils.toMessage(networkError);
      expect(message, Tk.commonNetworkError.tr);
    });

    test('extracts TimeoutException message accurately', () {
      final timeoutError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/customer/auth/login'),
        type: DioExceptionType.connectionTimeout,
      );

      final message = ApiErrorUtils.toMessage(timeoutError);
      expect(message, Tk.commonTimeoutError.tr);
    });
  });
}

