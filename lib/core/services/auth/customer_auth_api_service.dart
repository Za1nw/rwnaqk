import 'package:get/get.dart';

class AuthApiException implements Exception {
  const AuthApiException({
    required this.message,
    this.statusCode,
    this.validationErrors = const <String, List<String>>{},
    this.raw,
  });

  factory AuthApiException.fromResponse(
    Response<dynamic> response, {
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

class CustomerAuthApiService extends GetConnect {
  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  static const String _apiPrefix = '/api/v1/customer/auth';

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = _defaultBaseUrl;
    httpClient.timeout = const Duration(seconds: 20);
    httpClient.defaultContentType = 'application/json';
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      return request;
    });
  }

  Future<Response<dynamic>> register({
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
    String deviceName = 'rwnaqk-mobile',
  }) {
    return post('$_apiPrefix/register', <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'mobile': phone,
      'email': email,
      'country': country,
      'governorate': governorate,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'terms_accepted': termsAccepted,
      'privacy_policy_accepted': privacyPolicyAccepted,
      'device_name': deviceName,
    });
  }

  Future<Response<dynamic>> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
    String deviceName = 'rwnaqk-mobile',
  }) {
    return post(
      '$_apiPrefix/login',
      <String, dynamic>{
        'email': email,
        'password': password,
        'code': code,
        'recovery_code': recoveryCode,
        'device_name': deviceName,
      }..removeWhere((key, value) => value == null || value == ''),
    );
  }

  Future<Response<dynamic>> forgotPassword({required String email}) {
    return post('$_apiPrefix/forgot-password', <String, dynamic>{
      'email': email,
    });
  }

  Future<Response<dynamic>> resetPassword({
    required String token,
    required String email,
    required String password,
  }) {
    return post('$_apiPrefix/reset-password', <String, dynamic>{
      'token': token,
      'email': email,
      'password': password,
      'password_confirmation': password,
    });
  }

  Future<Response<dynamic>> me({required String token}) {
    return get('$_apiPrefix/me', headers: _authHeaders(token));
  }

  Future<Response<dynamic>> logout({required String token}) {
    return post(
      '$_apiPrefix/logout',
      const <String, dynamic>{},
      headers: _authHeaders(token),
    );
  }

  Future<Response<dynamic>> sendEmailVerification({required String token}) {
    return post(
      '$_apiPrefix/email/verification-notification',
      const <String, dynamic>{},
      headers: _authHeaders(token),
    );
  }

  Future<Response<dynamic>> sendEmailVerificationCode({required String token}) {
    return post(
      '$_apiPrefix/email/verification-code',
      const <String, dynamic>{},
      headers: _authHeaders(token),
    );
  }

  Future<Response<dynamic>> verifyEmailVerificationCode({
    required String token,
    required String code,
  }) {
    return post('$_apiPrefix/email/verify-code', <String, dynamic>{
      'code': code,
    }, headers: _authHeaders(token));
  }

  Future<Response<dynamic>> twoFactorStatus({required String token}) {
    return get('$_apiPrefix/two-factor-status', headers: _authHeaders(token));
  }

  Future<Response<dynamic>> enableTwoFactor({required String token}) {
    return post(
      '$_apiPrefix/two-factor-authentication',
      const <String, dynamic>{},
      headers: _authHeaders(token),
    );
  }

  Future<Response<dynamic>> confirmTwoFactor({
    required String token,
    required String code,
  }) {
    return post(
      '$_apiPrefix/two-factor-authentication/confirm',
      <String, dynamic>{'code': code},
      headers: _authHeaders(token),
    );
  }

  Future<Response<dynamic>> disableTwoFactor({required String token}) {
    return delete(
      '$_apiPrefix/two-factor-authentication',
      headers: _authHeaders(token),
    );
  }

  Future<Response<dynamic>> twoFactorRecoveryCodes({required String token}) {
    return get(
      '$_apiPrefix/two-factor-recovery-codes',
      headers: _authHeaders(token),
    );
  }

  Future<Response<dynamic>> regenerateTwoFactorRecoveryCodes({
    required String token,
  }) {
    return post(
      '$_apiPrefix/two-factor-recovery-codes',
      const <String, dynamic>{},
      headers: _authHeaders(token),
    );
  }

  Map<String, String> _authHeaders(String token) {
    return <String, String>{
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  static String? parseErrorMessage(Response<dynamic> response) {
    final body = response.body;

    if (body is Map<String, dynamic>) {
      final message = body['message'];

      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final errors = body['errors'];

      if (errors is Map<String, dynamic>) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty && value.first is String) {
            return (value.first as String).trim();
          }
        }
      }
    }

    if (response.statusText != null && response.statusText!.trim().isNotEmpty) {
      return response.statusText!.trim();
    }

    return null;
  }

  static Map<String, List<String>> parseValidationErrors(
    Response<dynamic> response,
  ) {
    final body = response.body;
    final result = <String, List<String>>{};

    if (body is! Map<String, dynamic>) {
      return result;
    }

    final errors = body['errors'];

    if (errors is! Map<String, dynamic>) {
      return result;
    }

    for (final entry in errors.entries) {
      final value = entry.value;
      if (value is List) {
        result[entry.key] = value
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList(growable: false);
      }
    }

    return result;
  }
}
