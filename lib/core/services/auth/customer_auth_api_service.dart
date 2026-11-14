import 'package:dio/dio.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';

class CustomerAuthApiResponse<T> {
  const CustomerAuthApiResponse({
    required this.statusCode,
    required this.isOk,
    this.body,
  });

  final int? statusCode;
  final bool isOk;
  final T? body;
}

class AuthApiException implements Exception {
  const AuthApiException({
    required this.message,
    this.statusCode,
    this.validationErrors = const <String, List<String>>{},
    this.raw,
  });

  factory AuthApiException.fromResponse(
    CustomerAuthApiResponse<dynamic> response, {
    String? fallbackMessage,
  }) {
    return AuthApiException(
      message:
          CustomerAuthApiService.parseErrorMessage(response) ??
          fallbackMessage ??
          'Request failed',
      statusCode: response.statusCode,
      validationErrors: CustomerAuthApiService.parseValidationErrors(response),
      raw: response.body,
    );
  }

  final String message;
  final int? statusCode;
  final Map<String, List<String>> validationErrors;
  final dynamic raw;

  bool get hasValidationErrors => validationErrors.isNotEmpty;

  @override
  String toString() {
    return message;
  }
}

class CustomerAuthApiService {
  CustomerAuthApiService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppEnv.apiBaseUrl,
                connectTimeout:
                    Duration(seconds: AppEnv.apiTimeoutSeconds),
                receiveTimeout:
                    Duration(seconds: AppEnv.apiTimeoutSeconds),
                headers: const {'Accept': 'application/json'},
                validateStatus: (status) => true,
              ),
            );

  final Dio _dio;

  static String get _apiPrefix => AppEnv.customerAuthPrefix;

  Future<CustomerAuthApiResponse<dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String country,
    required String governorate,
    required String password,
    required String passwordConfirmation,
    required bool termsAccepted,
    required bool privacyPolicyAccepted,
    String? deviceName,
  }) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/register',
      data: <String, dynamic>{
        'first_name': firstName.trim(),
        'last_name': lastName.trim(),
        'phone': phone.trim(),
        'email': email.trim().toLowerCase(),
        'country': country.trim(),
        'governorate': governorate.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
        'terms_accepted': termsAccepted,
        'privacy_policy_accepted': privacyPolicyAccepted,
        'device_name': deviceName ?? 'rwnaqk-mobile',
      },
    );

    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
    String? deviceName,
  }) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/login',
      data: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'password': password,
        'code': ?code,
        'recovery_code': ?recoveryCode,
        'device_name': deviceName ?? 'rwnaqk-mobile',
      },
    );

    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> forgotPassword({required String email}) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/forgot-password',
      data: <String, dynamic>{'email': email.trim().toLowerCase()},
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/reset-password',
      data: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'token': token.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> me({required String token}) async {
    final response = await _dio.get<dynamic>('$_apiPrefix/me', options: _authOptions(token));
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> logout({required String token}) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/logout',
      data: const <String, dynamic>{},
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> sendEmailVerification({required String token}) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/email/verification-notification',
      data: const <String, dynamic>{},
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> sendEmailVerificationCode({
    required String token,
  }) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/email/verification-code/send',
      data: const <String, dynamic>{},
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> verifyEmailVerificationCode({
    required String token,
    required String code,
  }) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/email/verification-code/verify',
      data: <String, dynamic>{'code': code.trim()},
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> twoFactorStatus({required String token}) async {
    final response = await _dio.get<dynamic>(
      '$_apiPrefix/two-factor-status',
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> enableTwoFactor({required String token}) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/two-factor-authentication',
      data: const <String, dynamic>{},
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> confirmTwoFactor({
    required String token,
    required String code,
  }) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/two-factor-authentication/confirm',
      data: <String, dynamic>{'code': code},
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> disableTwoFactor({required String token}) async {
    final response = await _dio.delete<dynamic>(
      '$_apiPrefix/two-factor-authentication',
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> twoFactorRecoveryCodes({required String token}) async {
    final response = await _dio.get<dynamic>(
      '$_apiPrefix/two-factor-recovery-codes',
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Future<CustomerAuthApiResponse<dynamic>> regenerateTwoFactorRecoveryCodes({
    required String token,
  }) async {
    final response = await _dio.post<dynamic>(
      '$_apiPrefix/two-factor-recovery-codes',
      data: const <String, dynamic>{},
      options: _authOptions(token),
    );
    return _wrapResponse(response);
  }

  Options _authOptions(String token) {
    return Options(
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
  }

  CustomerAuthApiResponse<dynamic> _wrapResponse(Response<dynamic> response) {
    final sc = response.statusCode ?? 500;
    return CustomerAuthApiResponse<dynamic>(
      statusCode: sc,
      isOk: sc >= 200 && sc < 300,
      body: response.data,
    );
  }

  static String? parseErrorMessage(CustomerAuthApiResponse<dynamic> response) {
    final body = response.body;

    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    if (body is String && body.trim().isNotEmpty) {
      return body.trim();
    }

    return null;
  }

  static Map<String, List<String>> parseValidationErrors(
    CustomerAuthApiResponse<dynamic> response,
  ) {
    final body = response.body;
    if (body is! Map<String, dynamic>) {
      return const <String, List<String>>{};
    }

    final rawErrors = body['errors'];
    if (rawErrors is! Map) {
      return const <String, List<String>>{};
    }

    final parsed = <String, List<String>>{};

    rawErrors.forEach((key, value) {
      if (value is List) {
        parsed[key.toString()] =
            value.map((item) => item.toString()).toList(growable: false);
      } else if (value != null) {
        parsed[key.toString()] = <String>[value.toString()];
      }
    });

    return parsed;
  }
}
