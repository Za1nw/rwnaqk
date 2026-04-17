import 'package:get/get.dart';
import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk/models/customer_model.dart';

class RegisterResult {
  const RegisterResult({
    required this.message,
    required this.requiresEmailVerification,
  });

  final String message;
  final bool requiresEmailVerification;
}

/// هذا الملف مسؤول عن المنطق المساعد الخاص بشاشة إنشاء الحساب.
///
/// نستخدمه لفصل:
/// - البيانات الثابتة مثل قائمة المحافظات
/// - التحقق الأولي من صلاحية الإرسال
///
/// لاحقًا عند ربط الـ API، سيكون هذا الملف هو المكان الطبيعي لـ:
/// - register
/// - التحقق من رقم الهاتف
/// - OTP
/// - حفظ بيانات المستخدم
class RegisterService {
  RegisterService(this._api, this._session, this._geoLookupApiService);

  final CustomerAuthApiService _api;
  final AuthSessionService _session;
  final GeoLookupApiService _geoLookupApiService;

  final RxList<String> governorates = <String>[].obs;
  String _defaultCountryName = 'اليمن';

  Future<void> loadGovernorates() async {
    final yemenLookup = await _geoLookupApiService.yemenGovernorates();
    if (yemenLookup == null) {
      governorates.clear();
      return;
    }

    if (yemenLookup.countryName.trim().isNotEmpty) {
      _defaultCountryName = yemenLookup.countryName;
    }

    governorates.assignAll(yemenLookup.governorates.map((item) => item.name));
  }

  String? defaultGovernorate() {
    if (governorates.isEmpty) return null;

    if (governorates.contains('صنعاء')) {
      return 'صنعاء';
    }

    return governorates.first;
  }

  String defaultCountryName() => _defaultCountryName;

  /// هذه الدالة تتحقق من صلاحية عملية التسجيل قبل المتابعة.
  ///
  /// نستخدمها الآن لفصل قرار السماح بالإرسال عن الكنترولر الرئيسي.
  bool canRegister({
    required bool isFormValid,
    required String? governorate,
    required String password,
    required String passwordConfirmation,
    required bool agreed,
  }) {
    if (!isFormValid) return false;
    if (governorate == null || governorate.trim().isEmpty) return false;
    if (password != passwordConfirmation) return false;
    if (!agreed) return false;
    return true;
  }

  Future<RegisterResult> register({
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
  }) async {
    final response = await _api.register(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      phone: phone.trim(),
      email: email.trim(),
      country: country.trim(),
      governorate: governorate.trim(),
      password: password,
      passwordConfirmation: passwordConfirmation,
      termsAccepted: termsAccepted,
      privacyPolicyAccepted: privacyPolicyAccepted,
    );

    if (!response.isOk) {
      throw AuthApiException.fromResponse(
        response,
        fallbackMessage: 'Unable to create account right now.',
      );
    }

    final body = response.body;

    if (body is! Map<String, dynamic>) {
      throw const AuthApiException(
        message: 'Unexpected register response from server.',
      );
    }

    final token = body['token'];

    if (token is! String || token.trim().isEmpty) {
      throw const AuthApiException(
        message: 'Missing token in register response.',
      );
    }

    _session.startSession(
      accessToken: token,
      customerPayload: _parseCustomer(body['customer']),
      emailVerificationRequired: body['requires_email_verification'] == true,
    );

    return RegisterResult(
      message: (body['message'] as String?) ?? 'Registered successfully.',
      requiresEmailVerification: body['requires_email_verification'] == true,
    );
  }

  CustomerModel? _parseCustomer(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      return CustomerModel.fromJson(payload);
    }

    return null;
  }
}
