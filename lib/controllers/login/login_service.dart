import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk/models/customer_model.dart';

class LoginResult {
  const LoginResult({
    required this.isSuccess,
    required this.requiresTwoFactor,
    required this.requiresEmailVerification,
    this.message,
  });

  final bool isSuccess;
  final bool requiresTwoFactor;
  final bool requiresEmailVerification;
  final String? message;
}

class LoginService {
  LoginService(this._api, this._session);

  final CustomerAuthApiService _api;
  final AuthSessionService _session;

  Future<LoginResult> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
  }) async {
    final response = await _api.login(
      email: email.trim(),
      password: password,
      code: code,
      recoveryCode: recoveryCode,
    );

    final body = response.body;

    if (response.statusCode == 202 && body is Map<String, dynamic>) {
      return LoginResult(
        isSuccess: false,
        requiresTwoFactor: body['two_factor_required'] == true,
        requiresEmailVerification: false,
        message: body['message'] as String?,
      );
    }

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to sign in right now.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw const AuthApiException(
        message: 'Unexpected login response from server.',
      );
    }

    final token = body['token'];

    if (token is! String || token.trim().isEmpty) {
      throw const AuthApiException(message: 'Missing token in login response.');
    }

    _session.startSession(
      accessToken: token,
      customerPayload: _parseCustomer(body['customer']),
      emailVerificationRequired: body['requires_email_verification'] == true,
    );

    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: false,
      requiresEmailVerification: body['requires_email_verification'] == true,
      message: body['message'] as String?,
    );
  }

  Future<String> sendEmailVerificationNotification() async {
    final token = _session.token.value;

    if (token == null || token.isEmpty) {
      throw const AuthApiException(message: 'No active authenticated session.');
    }

    final response = await _api.sendEmailVerification(token: token);

    if (response.statusCode == 204) {
      return 'Email already verified.';
    }

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to send verification email.',
      );
    }

    final body = response.body;

    if (body is Map<String, dynamic> && body['message'] is String) {
      return body['message'] as String;
    }

    return 'Verification email sent.';
  }

  Future<String> sendEmailVerificationCode() async {
    final token = _session.token.value;

    if (token == null || token.isEmpty) {
      throw const AuthApiException(message: 'No active authenticated session.');
    }

    final response = await _api.sendEmailVerificationCode(token: token);

    if (response.statusCode == 204) {
      return 'Email already verified.';
    }

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to send verification code.',
      );
    }

    final body = response.body;

    if (body is Map<String, dynamic> && body['message'] is String) {
      return body['message'] as String;
    }

    return 'Verification code sent.';
  }

  Future<String> verifyEmailVerificationCode({required String code}) async {
    final token = _session.token.value;

    if (token == null || token.isEmpty) {
      throw const AuthApiException(message: 'No active authenticated session.');
    }

    final response = await _api.verifyEmailVerificationCode(
      token: token,
      code: code.trim(),
    );

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to verify email code.',
      );
    }

    await _session.completeEmailVerification();

    final body = response.body;

    if (body is Map<String, dynamic> && body['message'] is String) {
      return body['message'] as String;
    }

    return 'Email verified successfully.';
  }

  CustomerModel? _parseCustomer(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return CustomerModel.fromJson(payload);
    }

    return null;
  }
}
