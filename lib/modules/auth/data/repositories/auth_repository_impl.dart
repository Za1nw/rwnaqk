import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_endpoints.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

/// تطبيق مستودع المصادقة النقي بالاعتماد على Dio و [ApiClient]
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl({
    required ApiClient apiClient,
    required this._tokenStorage,
  })  : _api = apiClient;

  final ApiClient _api;
  final IAuthTokenStorage _tokenStorage;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
    String? deviceName,
  }) async {
    final payload = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
      if (code != null && code.isNotEmpty) 'code': code,
      if (recoveryCode != null && recoveryCode.isNotEmpty)
        'recovery_code': recoveryCode,
      'device_name': deviceName ?? 'rwnaqk-mobile',
    };

    final response = await _api.post<dynamic>(
      ApiEndpoints.login,
      data: payload,
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة تسجيل الدخول غير صالحة من الخادم');
    }

    if (response.statusCode == 202 || data['two_factor_required'] == true) {
      return LoginResult(
        isSuccess: false,
        requiresTwoFactor: true,
        requiresEmailVerification: false,
        message: data['message'] as String?,
      );
    }

    final token = data['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.writeToken(token);
    }

    CustomerModel? customer;
    if (data['customer'] is Map<String, dynamic>) {
      try {
        customer =
            CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
      } catch (_) {}
    }

    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: false,
      requiresEmailVerification: data['requires_email_verification'] == true,
      message: data['message'] as String?,
      token: token,
      customer: customer,
    );
  }

  @override
  Future<LoginResult> register({
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
    final payload = <String, dynamic>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      'mobile': phone.trim(),
      'email': email.trim().toLowerCase(),
      'country': country.trim(),
      'governorate': governorate.trim(),
      'password': password,
      'password_confirmation': passwordConfirmation,
      'terms_accepted': termsAccepted,
      'privacy_policy_accepted': privacyPolicyAccepted,
      'device_name': deviceName ?? 'rwnaqk-mobile',
    };

    final response = await _api.post<dynamic>(
      ApiEndpoints.register,
      data: payload,
    );

    final data = response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('استجابة التسجيل غير صالحة من الخادم');
    }

    final token = data['token'] as String?;
    if (token != null && token.isNotEmpty) {
      await _tokenStorage.writeToken(token);
    }

    CustomerModel? customer;
    if (data['customer'] is Map<String, dynamic>) {
      try {
        customer =
            CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
      } catch (_) {}
    }

    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: false,
      requiresEmailVerification: data['requires_email_verification'] == true,
      message: data['message'] as String?,
      token: token,
      customer: customer,
    );
  }

  @override
  Future<CustomerModel> me() async {
    final response = await _api.get<dynamic>(ApiEndpoints.me);
    final data = response.data;
    if (data is Map<String, dynamic> && data['customer'] is Map<String, dynamic>) {
      return CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
    }
    throw const FormatException('تعذر قراءة بيانات المستخدم من الخادم');
  }

  @override
  Future<void> logout() async {
    try {
      await _api.post<dynamic>(ApiEndpoints.logout);
    } finally {
      await _tokenStorage.clearToken();
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _api.post<dynamic>(
      ApiEndpoints.forgotPassword,
      data: <String, dynamic>{'email': email.trim().toLowerCase()},
    );
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {
    await _api.post<dynamic>(
      ApiEndpoints.resetPassword,
      data: <String, dynamic>{
        'token': token,
        'email': email.trim().toLowerCase(),
        'password': password,
        'password_confirmation': password,
      },
    );
  }

  @override
  Future<void> sendEmailVerificationCode() async {
    await _api.post<dynamic>(ApiEndpoints.sendVerificationCode);
  }

  @override
  Future<void> verifyEmailCode({required String code}) async {
    await _api.post<dynamic>(
      ApiEndpoints.verifyEmailCode,
      data: <String, dynamic>{'code': code.trim()},
    );
  }
}
