import 'package:dio/dio.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_endpoints.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/passkey_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/user_session_model.dart';

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

    try {
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

      CustomerModel? customer;
      if (data['customer'] is Map<String, dynamic>) {
        try {
          customer =
              CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
        } catch (_) {}
      }

      final isBanned = data['error_code'] == 'ACCOUNT_BANNED' ||
          data['is_banned'] == true ||
          customer?.isBanned == true;

      if (isBanned) {
        return LoginResult(
          isSuccess: false,
          requiresTwoFactor: false,
          requiresEmailVerification: false,
          isBanned: true,
          message: data['message'] as String? ??
              'تم حظر حسابك. يرجى التواصل مع إدارة المتجر لمزيد من التفاصيل.',
          customer: customer,
        );
      }

      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _tokenStorage.writeToken(token);
      }

      return LoginResult(
        isSuccess: true,
        requiresTwoFactor: false,
        requiresEmailVerification: data['requires_email_verification'] == true,
        message: data['message'] as String?,
        token: token,
        customer: customer,
      );
    } on AccountBannedException catch (bannedEx) {
      CustomerModel? customer;
      if (bannedEx.customerData != null) {
        try {
          customer = CustomerModel.fromJson(bannedEx.customerData!);
        } catch (_) {}
      }
      return LoginResult(
        isSuccess: false,
        requiresTwoFactor: false,
        requiresEmailVerification: false,
        isBanned: true,
        message: bannedEx.message,
        customer: customer,
      );
    } on DioException catch (dioErr) {
      if (dioErr.error is AccountBannedException) {
        final bannedEx = dioErr.error as AccountBannedException;
        CustomerModel? customer;
        if (bannedEx.customerData != null) {
          try {
            customer = CustomerModel.fromJson(bannedEx.customerData!);
          } catch (_) {}
        }
        return LoginResult(
          isSuccess: false,
          requiresTwoFactor: false,
          requiresEmailVerification: false,
          isBanned: true,
          message: bannedEx.message,
          customer: customer,
        );
      }
      rethrow;
    }
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
    String? gender,
    String? deviceName,
  }) async {
    final payload = <String, dynamic>{
      'first_name': firstName.trim(),
      'last_name': lastName.trim(),
      if (gender != null && gender.trim().isNotEmpty)
        'gender': gender.trim(),
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

    try {
      final response = await _api.post<dynamic>(
        ApiEndpoints.register,
        data: payload,
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('استجابة التسجيل غير صالحة من الخادم');
      }

      CustomerModel? customer;
      if (data['customer'] is Map<String, dynamic>) {
        try {
          customer =
              CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
        } catch (_) {}
      }

      final isBanned = data['error_code'] == 'ACCOUNT_BANNED' ||
          data['is_banned'] == true ||
          customer?.isBanned == true;

      if (isBanned) {
        return LoginResult(
          isSuccess: false,
          requiresTwoFactor: false,
          requiresEmailVerification: false,
          isBanned: true,
          message: data['message'] as String? ??
              'تم حظر حسابك. يرجى التواصل مع إدارة المتجر لمزيد من التفاصيل.',
          customer: customer,
        );
      }

      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _tokenStorage.writeToken(token);
      }

      return LoginResult(
        isSuccess: true,
        requiresTwoFactor: false,
        requiresEmailVerification: data['requires_email_verification'] == true,
        message: data['message'] as String?,
        token: token,
        customer: customer,
      );
    } on AccountBannedException catch (bannedEx) {
      CustomerModel? customer;
      if (bannedEx.customerData != null) {
        try {
          customer = CustomerModel.fromJson(bannedEx.customerData!);
        } catch (_) {}
      }
      return LoginResult(
        isSuccess: false,
        requiresTwoFactor: false,
        requiresEmailVerification: false,
        isBanned: true,
        message: bannedEx.message,
        customer: customer,
      );
    } on DioException catch (dioErr) {
      if (dioErr.error is AccountBannedException) {
        final bannedEx = dioErr.error as AccountBannedException;
        CustomerModel? customer;
        if (bannedEx.customerData != null) {
          try {
            customer = CustomerModel.fromJson(bannedEx.customerData!);
          } catch (_) {}
        }
        return LoginResult(
          isSuccess: false,
          requiresTwoFactor: false,
          requiresEmailVerification: false,
          isBanned: true,
          message: bannedEx.message,
          customer: customer,
        );
      }
      rethrow;
    }
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
  Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await _api.post<dynamic>(
      ApiEndpoints.verifyPasswordResetCode,
      data: <String, dynamic>{
        'email': email.trim().toLowerCase(),
        'code': code.trim(),
      },
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

  @override
  Future<CustomerModel> updateProfile({
    String? firstName,
    String? lastName,
    String? name,
    String? email,
    String? mobile,
    String? gender,
    String? avatarFilePath,
  }) async {
    final Map<String, dynamic> fields = <String, dynamic>{
      if (firstName != null && firstName.trim().isNotEmpty)
        'first_name': firstName.trim(),
      if (lastName != null && lastName.trim().isNotEmpty)
        'last_name': lastName.trim(),
      if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
      if (email != null && email.trim().isNotEmpty)
        'email': email.trim().toLowerCase(),
      if (mobile != null && mobile.trim().isNotEmpty) 'mobile': mobile.trim(),
      if (gender != null && gender.trim().isNotEmpty) 'gender': gender.trim(),
    };

    dynamic postData;
    if (avatarFilePath != null && avatarFilePath.isNotEmpty) {
      final multipartFile = await MultipartFile.fromFile(
        avatarFilePath,
        filename: avatarFilePath.split(RegExp(r'[\\/]')).last,
      );
      postData = FormData.fromMap(<String, dynamic>{
        ...fields,
        'avatar': multipartFile,
      });
    } else {
      postData = fields;
    }

    final response = await _api.post<dynamic>(
      ApiEndpoints.updateProfile,
      data: postData,
    );

    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['customer'] is Map<String, dynamic>) {
      return CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
    }
    throw const FormatException('استجابة تحديث الملف الشخصي غير صالحة');
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _api.post<dynamic>(
      ApiEndpoints.changePassword,
      data: <String, dynamic>{
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      },
    );
  }

  @override
  Future<List<UserSessionModel>> getSessions() async {
    final response = await _api.get<dynamic>(ApiEndpoints.sessions);
    final data = response.data;
    if (data is Map<String, dynamic> && data['sessions'] is List) {
      final list = data['sessions'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => UserSessionModel.fromJson(item))
          .toList();
    }
    return const [];
  }

  @override
  Future<void> revokeSession(int id) async {
    await _api.delete<dynamic>(ApiEndpoints.revokeSession(id));
  }

  @override
  Future<void> revokeOtherSessions() async {
    await _api.post<dynamic>(ApiEndpoints.revokeOtherSessions);
  }

  @override
  Future<List<PasskeyModel>> getPasskeys() async {
    final response = await _api.get<dynamic>(ApiEndpoints.passkeys);
    final data = response.data;
    if (data is Map<String, dynamic> && data['passkeys'] is List) {
      final list = data['passkeys'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => PasskeyModel.fromJson(item))
          .toList();
    }
    return const [];
  }

  @override
  Future<PasskeyModel> storePasskey({
    required String name,
    String? credentialId,
    Map<String, dynamic>? credential,
  }) async {
    final payload = <String, dynamic>{
      'name': name.trim(),
    };
    if (credentialId != null && credentialId.isNotEmpty) {
      payload['credential_id'] = credentialId;
    }
    if (credential != null && credential.isNotEmpty) {
      payload['credential'] = credential;
    }

    final response = await _api.post<dynamic>(
      ApiEndpoints.passkeys,
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic> &&
        data['passkey'] is Map<String, dynamic>) {
      return PasskeyModel.fromJson(data['passkey'] as Map<String, dynamic>);
    }
    throw const FormatException('استجابة إنشاء مفتاح المرور غير صالحة');
  }

  @override
  Future<LoginResult> passkeyLogin({
    required String credentialId,
    String? secret,
    String? email,
  }) async {
    final payload = <String, dynamic>{
      'credential_id': credentialId,
    };
    if (secret != null && secret.isNotEmpty) {
      payload['secret'] = secret;
    }
    if (email != null && email.isNotEmpty) {
      payload['email'] = email;
    }

    final response = await _api.post<dynamic>(
      ApiEndpoints.passkeyLogin,
      data: payload,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final token = data['token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _tokenStorage.writeToken(token);
      }
      CustomerModel? customer;
      if (data['customer'] is Map<String, dynamic>) {
        customer =
            CustomerModel.fromJson(data['customer'] as Map<String, dynamic>);
      }
      return LoginResult(
        isSuccess: true,
        token: token,
        customer: customer,
        requiresTwoFactor: data['two_factor'] == true,
        requiresEmailVerification: data['requires_email_verification'] == true,
      );
    }
    throw const FormatException('استجابة تسجيل الدخول بمفتاح المرور غير صالحة');
  }

  @override
  Future<void> deletePasskey(int id) async {
    await _api.delete<dynamic>(ApiEndpoints.deletePasskey(id));
  }
}
