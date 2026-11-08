import 'dart:async';

import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

class AuthSessionService extends GetxService {
  AuthSessionService({
    String? initialAccessToken,
    IAuthTokenStorage? tokenStorage,
  }) : _tokenStorage = tokenStorage ?? SecureAuthTokenStorage() {
    final hasInitialToken = (initialAccessToken ?? '').trim().isNotEmpty;
    if (hasInitialToken) {
      token.value = initialAccessToken!.trim();
    }
  }

  final IAuthTokenStorage _tokenStorage;

  final token = RxnString();
  final requiresEmailVerification = false.obs;
  final customer = Rxn<CustomerModel>();
  final isGuestMode = false.obs;

  bool get isAuthenticated =>
      (token.value ?? '').isNotEmpty || isGuestMode.value;

  /// تمكين وضع الضيف لتجاوز تسجيل الدخول لأغراض التصميم والتطوير
  void enterGuestMode() {
    isGuestMode.value = true;
    token.value = 'guest_dev_mode';
    customer.value = const CustomerModel(
      id: 1,
      firstName: 'مستخدم',
      lastName: 'تجريبي',
      fullName: 'مستخدم تجريبي',
      email: 'guest@rawnaqk.com',
      mobile: '777000000',
    );
  }

  Future<void> bootstrapSession(CustomerAuthApiService api) async {
    final currentToken = (token.value ?? '').trim();
    if (currentToken.isEmpty) {
      return;
    }

    if (AppEnv.enableMockData) {
      customer.value ??= CustomerModel(
        id: 1,
        firstName: 'مستخدم',
        lastName: 'تجريبي',
        fullName: 'مستخدم تجريبي',
        email: 'user@rawnaqk.com',
        mobile: '777000000',
        emailVerifiedAt: DateTime.now(),
      );
      _setEmailVerificationRequired(false);
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
    isGuestMode.value = false;
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
      customer.value = currentCustomer.copyWith(
        emailVerifiedAt: DateTime.now(),
      );
    }

    _setEmailVerificationRequired(false);
    await _persistToken(currentToken);
  }

  void setEmailVerificationRequired(bool value) {
    _setEmailVerificationRequired(value);
  }

  Future<void> _persistToken(String? accessToken) async {
    final normalizedToken = (accessToken ?? '').trim();
    if (normalizedToken.isEmpty) {
      await _tokenStorage.clearToken();
      return;
    }

    await _tokenStorage.writeToken(normalizedToken);
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

    if (Get.context == null || (Get.testMode && Get.key.currentState == null)) {
      return;
    }

    Get.offAllNamed(AppRoutes.login);
  }
}
