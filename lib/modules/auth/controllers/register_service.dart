import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

class RegisterResult {
  const RegisterResult({
    required this.message,
    required this.requiresEmailVerification,
    this.isBanned = false,
  });

  final String message;
  final bool requiresEmailVerification;
  final bool isBanned;
}

/// هذا الملف مسؤول عن المنطق المساعد الخاص بشاشة إنشاء الحساب.
class RegisterService {
  RegisterService(
    this._authRepository,
    this._session,
    this._geoLookupApiService,
  );

  final IAuthRepository _authRepository;
  final AuthSessionNotifier _session;
  final GeoLookupApiService _geoLookupApiService;

  final List<String> governorates = <String>[];
  String _defaultCountryName = 'اليمن';

  Future<void> loadGovernorates({bool forceRefresh = false}) async {
    if (!forceRefresh && governorates.isNotEmpty) {
      return;
    }

    final yemenLookup = await _geoLookupApiService.yemenGovernorates(
      forceRefresh: forceRefresh,
    );

    if (yemenLookup == null || yemenLookup.governorates.isEmpty) {
      if (governorates.isEmpty) {
        governorates.addAll(GeoLookupApiService.defaultYemenGovernorates);
      }
      return;
    }

    if (yemenLookup.countryName.trim().isNotEmpty) {
      _defaultCountryName = yemenLookup.countryName;
    }

    governorates
      ..clear()
      ..addAll(yemenLookup.governorates.map((item) => item.name));
  }

  String? defaultGovernorate() {
    if (governorates.isEmpty) return 'صنعاء';

    if (governorates.contains('صنعاء')) {
      return 'صنعاء';
    }

    return governorates.first;
  }

  String defaultCountryName() => _defaultCountryName;

  /// هذه الدالة تتحقق من صلاحية عملية التسجيل قبل المتابعة.
  bool canRegister({
    required bool isFormValid,
    required String? gender,
    required String? governorate,
    required String password,
    required String passwordConfirmation,
    required bool agreed,
  }) {
    if (!isFormValid) return false;
    if (gender == null || gender.trim().isEmpty) return false;
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
    String? gender,
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
      gender: gender,
    );

    if (result.isBanned || result.customer?.isBanned == true) {
      await _session.markAsBanned(
        customerPayload: result.customer,
        reason: result.message,
      );
      return RegisterResult(
        message: result.message ?? 'تم حظر الحساب.',
        requiresEmailVerification: false,
        isBanned: true,
      );
    }

    if (result.isSuccess) {
      CustomerModel? customer = result.customer;

      await _session.startSession(
        accessToken: result.token ?? '',
        customerPayload: customer,
        emailVerificationRequired: result.requiresEmailVerification,
      );

      if (customer == null && !result.requiresEmailVerification) {
        try {
          customer = await _authRepository.me();
          if (customer.isBanned == true) {
            await _session.markAsBanned(
              customerPayload: customer,
              reason: 'تم حظر الحساب.',
            );
            return const RegisterResult(
              message: 'تم حظر الحساب.',
              requiresEmailVerification: false,
              isBanned: true,
            );
          }
          _session.setCustomer(customer);
        } on AccountBannedException catch (bannedEx) {
          CustomerModel? bannedCustomer;
          if (bannedEx.customerData != null) {
            try {
              bannedCustomer = CustomerModel.fromJson(bannedEx.customerData!);
            } catch (_) {}
          }
          await _session.markAsBanned(
            customerPayload: bannedCustomer,
            reason: bannedEx.message,
          );
          return RegisterResult(
            message: bannedEx.message,
            requiresEmailVerification: false,
            isBanned: true,
          );
        } catch (e, st) {
          debugPrint('[RegisterService] Warning: Failed to fetch customer profile via me(): $e\n$st');
        }
      }
    }

    return RegisterResult(
      message: result.message ?? 'Registered successfully.',
      requiresEmailVerification: result.requiresEmailVerification,
    );
  }
}
