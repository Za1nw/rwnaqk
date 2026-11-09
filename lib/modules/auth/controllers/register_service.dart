import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

class RegisterResult {
  const RegisterResult({
    required this.message,
    required this.requiresEmailVerification,
  });

  final String message;
  final bool requiresEmailVerification;
}

/// هذا الملف مسؤول عن المنطق المساعد الخاص بشاشة إنشاء الحساب.
class RegisterService {
  RegisterService(
    this._authRepository,
    this._session,
    this._geoLookupApiService,
  );

  final IAuthRepository _authRepository;
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
    final result = await _authRepository.register(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      email: email,
      country: country,
      governorate: governorate,
      password: password,
      passwordConfirmation: passwordConfirmation,
      termsAccepted: termsAccepted,
      privacyPolicyAccepted: privacyPolicyAccepted,
    );

    if (result.isSuccess) {
      CustomerModel? customer = result.customer;
      if (customer == null) {
        try {
          customer = await _authRepository.me();
        } catch (_) {}
      }

      _session.startSession(
        accessToken: result.token ?? '',
        customerPayload: customer,
        emailVerificationRequired: result.requiresEmailVerification,
      );
    }

    return RegisterResult(
      message: result.message ?? 'Registered successfully.',
      requiresEmailVerification: result.requiresEmailVerification,
    );
  }
}
