import 'dart:async';

import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk/models/customer_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rwnaqk/core/constants/local_storage_keys.dart';

class AuthSessionService extends GetxService {
  AuthSessionService({String? initialAccessToken}) {
    final hasInitialToken = (initialAccessToken ?? '').trim().isNotEmpty;
    if (hasInitialToken) {
      token.value = initialAccessToken!.trim();
    }
  }

  final token = RxnString();
  final requiresEmailVerification = false.obs;
  final customer = Rxn<CustomerModel>();

  bool get isAuthenticated => (token.value ?? '').isNotEmpty;

  Future<void> bootstrapSession(CustomerAuthApiService api) async {
    final currentToken = (token.value ?? '').trim();
    if (currentToken.isEmpty) {
      return;
    }

    try {
      final response = await api.me(token: currentToken);

      if (!response.isOk) {
        await _clearSessionAndRedirectToLogin();
        return;
      }

      final body = response.body;
      if (body is! Map<String, dynamic>) {
        await _clearSessionAndRedirectToLogin();
        return;
      }

      final customerPayload = body['customer'];
      if (customerPayload is Map<String, dynamic>) {
        final parsedCustomer = CustomerModel.fromJson(customerPayload);
        customer.value = parsedCustomer;
        final requiresVerification = parsedCustomer.emailVerifiedAt == null;
        _setEmailVerificationRequired(requiresVerification);

        if (requiresVerification) {
          await _clearSessionAndRedirectToLogin();
          return;
        }
      }
    } catch (_) {
      await _clearSessionAndRedirectToLogin();
    }
  }

  void startSession({
    required String accessToken,
    CustomerModel? customerPayload,
    bool emailVerificationRequired = false,
  }) {
    final normalizedToken = accessToken.trim();
    token.value = normalizedToken;
    customer.value = customerPayload;
    _setEmailVerificationRequired(emailVerificationRequired);
    if (!emailVerificationRequired) {
      unawaited(_persistToken(normalizedToken));
    }
  }

  void setCustomer(CustomerModel? customerModel) {
    customer.value = customerModel;
  }

  void updateCustomer(CustomerModel Function(CustomerModel? current) update) {
    customer.value = update(customer.value);
  }

  void clearSession() {
    token.value = null;
    customer.value = null;
    requiresEmailVerification.value = false;
    unawaited(_persistToken(null));
  }

  Future<void> completeEmailVerification() async {
    final currentToken = (token.value ?? '').trim();

    if (currentToken.isEmpty) {
      _setEmailVerificationRequired(false);
      return;
    }

    final currentCustomer = customer.value;
    if (currentCustomer != null && currentCustomer.emailVerifiedAt == null) {
      customer.value = currentCustomer.copyWith(emailVerifiedAt: DateTime.now());
    }

    _setEmailVerificationRequired(false);
    await _persistToken(currentToken);
  }

  void setEmailVerificationRequired(bool value) {
    _setEmailVerificationRequired(value);
  }

  Future<void> _persistToken(String? accessToken) async {
    final prefs = await SharedPreferences.getInstance();

    final normalizedToken = (accessToken ?? '').trim();
    if (normalizedToken.isEmpty) {
      await prefs.remove(LocalStorageKeys.authToken);
      return;
    }

    await prefs.setString(LocalStorageKeys.authToken, normalizedToken);
  }

  void _setEmailVerificationRequired(bool value) {
    requiresEmailVerification.value = value;
  }

  Future<void> _clearSessionAndRedirectToLogin() async {
    clearSession();

    final currentRoute = Get.currentRoute;
    if (currentRoute == AppRoutes.onboarding ||
        currentRoute == AppRoutes.login ||
        currentRoute == AppRoutes.register ||
        currentRoute == AppRoutes.forgot ||
        currentRoute == AppRoutes.otp ||
        currentRoute == AppRoutes.reset) {
      return;
    }

    Get.offAllNamed(AppRoutes.login);
  }
}
