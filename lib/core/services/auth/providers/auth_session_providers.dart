import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/checkout/providers/checkout_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// الموفر المركزي والمتحكم الأوحد لجلسة المصادقة [AuthSessionNotifier]
final authSessionProvider =
    NotifierProvider<AuthSessionNotifier, AuthSessionState>(
  AuthSessionNotifier.new,
);

/// موفر العميل الحالي المسجل
final currentCustomerProvider = Provider<CustomerModel?>((ref) {
  return ref.watch(authSessionProvider).customer;
});

/// موفر حالة المصادقة (هل مسموح له بالوصول للواجهات المحمية)
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authSessionProvider).isAuthenticated;
});

/// موفر حالة وضع الضيف
final isGuestModeProvider = Provider<bool>((ref) {
  return ref.watch(authSessionProvider).isGuest;
});

/// موفر حالة الجلسة التفصيلية
final authSessionStatusProvider = Provider<AuthSessionStatus>((ref) {
  return ref.watch(authSessionProvider).status;
});

/// المتحكم الرئيسي المعتمد لإدارة جلسة المصادقة بالكامل
class AuthSessionNotifier extends Notifier<AuthSessionState> {
  bool _isHandlingUnauthorized = false;
  String? _activeSessionUserId;
  void Function()? onSessionTerminated;

  @override
  AuthSessionState build() {
    return const AuthSessionState();
  }

  /// تهيئة فورية ومحلية للتوكن في الذاكرة دون حظر واجهة المستخدم
  void primeSession({required String token}) {
    final normalized = token.trim();
    if (normalized.isNotEmpty) {
      state = state.copyWith(
        status: AuthSessionStatus.authenticated,
        token: normalized,
      );
    }
  }

  /// تهيئة الجلسة وفحص التوكن المحفوظ في التخزين الآمن عند تشغيل التطبيق
  Future<void> bootstrapSession({String? initialToken}) async {
    final storage = ref.read(authTokenStorageProvider);
    final rawToken = (initialToken != null && initialToken != 'cached_session')
        ? initialToken
        : (await storage.readToken() ?? '');
    final token = rawToken.trim();

    if (token.isEmpty) {
      state = state.copyWith(status: AuthSessionStatus.unauthenticated);
      if (AppNav.context != null && !state.isGuest) {
        final currentRoute = AppNav.currentRoute;
        if (currentRoute != AppRoutes.onboarding &&
            currentRoute != AppRoutes.login) {
          AppNav.offAllNamed(AppRoutes.login);
        }
      }
      return;
    }

    if (!state.isAuthenticated || state.token != token) {
      state = state.copyWith(
        status: AuthSessionStatus.authenticated,
        token: token,
      );
    }

    if (AppEnv.enableMockData) {
      final mockCustomer = CustomerModel(
        id: 1,
        firstName: 'مستخدم',
        lastName: 'تجريبي',
        fullName: 'مستخدم تجريبي',
        email: 'user@rawnaqk.com',
        mobile: '777000000',
        emailVerifiedAt: DateTime.now(),
      );
      final nextGen = state.sessionGeneration + 1;
      state = state.copyWith(
        status: AuthSessionStatus.authenticated,
        customer: mockCustomer,
        sessionGeneration: nextGen,
      );
      _syncSessionScopedProviders(
        userId: mockCustomer.id.toString(),
        generation: nextGen,
      );
      return;
    }

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final customer = await authRepo.me();

      if (customer.isBanned == true) {
        markAsBanned(customerPayload: customer);
        return;
      }

      final requiresVerification = customer.emailVerifiedAt == null;
      final nextGen = state.sessionGeneration + 1;

      if (requiresVerification) {
        state = state.copyWith(
          status: AuthSessionStatus.emailVerificationRequired,
          customer: customer,
          sessionGeneration: nextGen,
        );
        AppNav.offAllNamed(
          AppRoutes.emailVerify,
          arguments: <String, dynamic>{'email': customer.email},
        );
        return;
      }

      state = state.copyWith(
        status: AuthSessionStatus.authenticated,
        customer: customer,
        sessionGeneration: nextGen,
      );

      _syncSessionScopedProviders(
        userId: customer.id.toString(),
        generation: nextGen,
      );
    } on AccountBannedException catch (bannedEx) {
      CustomerModel? customer;
      if (bannedEx.customerData != null) {
        try {
          customer = CustomerModel.fromJson(bannedEx.customerData!);
        } catch (_) {}
      }
      markAsBanned(
        customerPayload: customer,
        reason: bannedEx.message,
      );
    } on UnauthorizedException {
      await _clearSessionAndRedirectToLogin();
    } catch (e) {
      debugPrint('[AuthSession] bootstrapSession transient error: $e');
    }
  }

  /// بدء جلسة مصادقة ناجحة بعد تسجيل الدخول أو التسجيل
  void startSession({
    required String accessToken,
    CustomerModel? customerPayload,
    bool emailVerificationRequired = false,
  }) {
    final normalizedToken = accessToken.trim();
    final storage = ref.read(authTokenStorageProvider);

    if (!emailVerificationRequired && normalizedToken.isNotEmpty) {
      unawaited(storage.writeToken(normalizedToken));
    }

    final nextGen = state.sessionGeneration + 1;
    final status = emailVerificationRequired
        ? AuthSessionStatus.emailVerificationRequired
        : AuthSessionStatus.authenticated;

    state = state.copyWith(
      status: status,
      token: normalizedToken,
      customer: customerPayload,
      clearTwoFactorPayload: true,
      clearErrorMessage: true,
      sessionGeneration: nextGen,
    );

    _syncSessionScopedProviders(
      userId: customerPayload?.id.toString(),
      generation: nextGen,
    );
  }

  /// بدء تحدي التحقق بخطوتين (2FA) دون منح الجلسة المصادقة ودون حفظ التوكن
  void startTwoFactorChallenge({
    required String email,
    required String password,
    String? message,
  }) {
    state = state.copyWith(
      status: AuthSessionStatus.twoFactorChallengeRequired,
      twoFactorPayload: TwoFactorChallengePayload(
        email: email.trim(),
        password: password,
        message: message,
      ),
      clearToken: true,
      clearCustomer: true,
      errorMessage: message,
    );
  }

  /// إلغاء تحدي التحقق بخطوتين
  void cancelTwoFactorChallenge() {
    state = state.copyWith(
      status: AuthSessionStatus.unauthenticated,
      clearTwoFactorPayload: true,
      clearErrorMessage: true,
    );
  }

  /// الدخول في وضع الضيف (المعاينة والتصميم)
  void enterGuestMode() {
    const guestCustomer = CustomerModel(
      id: 1,
      firstName: 'مستخدم',
      lastName: 'تجريبي',
      fullName: 'مستخدم تجريبي',
      email: 'guest@rawnaqk.com',
      mobile: '777000000',
    );

    final nextGen = state.sessionGeneration + 1;

    state = state.copyWith(
      status: AuthSessionStatus.guest,
      token: 'guest_dev_mode',
      customer: guestCustomer,
      clearTwoFactorPayload: true,
      clearErrorMessage: true,
      sessionGeneration: nextGen,
    );

    _syncSessionScopedProviders(
      userId: 'guest',
      generation: nextGen,
    );
  }

  /// تحديث بيانات العميل المسجل
  void setCustomer(CustomerModel? customerModel) {
    state = state.copyWith(customer: customerModel);
  }

  /// تعديل بيانات العميل عبر دالة تحويل
  void updateCustomer(CustomerModel Function(CustomerModel? current) update) {
    state = state.copyWith(customer: update(state.customer));
  }

  /// تأكيد التحقق من البريد الإلكتروني وترقية الجلسة
  Future<void> completeEmailVerification() async {
    final currentToken = (state.token ?? '').trim();

    if (currentToken.isEmpty) {
      state = state.copyWith(status: AuthSessionStatus.unauthenticated);
      return;
    }

    final currentCustomer = state.customer;
    CustomerModel? updatedCustomer;
    if (currentCustomer != null && currentCustomer.emailVerifiedAt == null) {
      updatedCustomer = currentCustomer.copyWith(
        emailVerifiedAt: DateTime.now(),
      );
    }

    final storage = ref.read(authTokenStorageProvider);
    await storage.writeToken(currentToken);

    state = state.copyWith(
      status: AuthSessionStatus.authenticated,
      customer: updatedCustomer ?? currentCustomer,
    );
  }

  /// وسم الحساب كمحظور وإعادة توجيهه بشكل فوري إلى شاشة الحظر
  void markAsBanned({CustomerModel? customerPayload, String? reason}) {
    final nextGen = state.sessionGeneration + 1;

    state = state.copyWith(
      status: AuthSessionStatus.banned,
      customer: customerPayload ?? state.customer,
      errorMessage: reason ??
          'تم حظر حسابك. يرجى التواصل مع إدارة المتجر لمزيد من التفاصيل.',
      sessionGeneration: nextGen,
    );

    _syncSessionScopedProviders(
      userId: null,
      generation: nextGen,
    );

    AppNav.offAllNamed(AppRoutes.banned);
  }

  /// تفريغ الجلسة محلياً بالكامل
  void clearSession() {
    final storage = ref.read(authTokenStorageProvider);
    unawaited(storage.clearToken());

    final nextGen = state.sessionGeneration + 1;

    state = state.copyWith(
      status: AuthSessionStatus.unauthenticated,
      clearToken: true,
      clearCustomer: true,
      clearTwoFactorPayload: true,
      clearErrorMessage: true,
      sessionGeneration: nextGen,
    );

    _syncSessionScopedProviders(
      userId: null,
      generation: nextGen,
    );
  }

  /// تسجيل الخروج الآمن
  Future<void> logout() async {
    final storage = ref.read(authTokenStorageProvider);
    final authRepo = ref.read(authRepositoryProvider);

    try {
      await authRepo.logout();
    } catch (_) {
      // نتجاهل أخطاء الشبكة أثناء تسجيل الخروج لضمان استمرار التطهير المحلي
    } finally {
      await storage.clearToken();
      clearSession();

      try {
        onSessionTerminated?.call();
      } catch (e) {
        debugPrint('[AuthSession] Error in onSessionTerminated: $e');
      }

      _redirectOnLogout();
    }
  }

  /// معالجة استجابة HTTP 401 Unauthorized المركزية من عميل الشبكة
  Future<void> handleUnauthorized({
    String? failedToken,
    int? staleGeneration,
  }) async {
    if (_isHandlingUnauthorized) {
      return;
    }

    // إذا كانت الجلسة منتهية بالفعل وغير مصادقة، نتجنب إعادة التطهير
    if ((state.token == null || state.token!.isEmpty) && !state.isAuthenticated) {
      return;
    }

    // التحقق من الاستجابات القديمة برقم جيل الجلسة الأحادي
    if (staleGeneration != null && staleGeneration < state.sessionGeneration) {
      debugPrint(
        '[AuthSession] Stale 401 ignored: request generation $staleGeneration < active ${state.sessionGeneration}',
      );
      return;
    }

    // التحقق من الاستجابات القديمة بمطابقة التوكن (Stale 401 Guard)
    if (failedToken != null && failedToken.isNotEmpty) {
      final currentToken = (state.token ?? '').trim();
      if (currentToken.isNotEmpty && currentToken != failedToken) {
        debugPrint(
          '[AuthSession] Stale 401 ignored: request token does not match active session.',
        );
        return;
      }
    }

    _isHandlingUnauthorized = true;

    try {
      final storage = ref.read(authTokenStorageProvider);
      await storage.clearToken();
      clearSession();

      try {
        onSessionTerminated?.call();
      } catch (e) {
        debugPrint('[AuthSession] Error in onSessionTerminated: $e');
      }

      _redirectOnLogout();
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  Future<void> _clearSessionAndRedirectToLogin() async {
    clearSession();
    try {
      onSessionTerminated?.call();
    } catch (e) {
      debugPrint('[AuthSession] Error in onSessionTerminated: $e');
    }

    _redirectOnLogout();
  }

  void _redirectOnLogout() {
    final currentRoute = AppNav.currentRoute;
    if (currentRoute == AppRoutes.onboarding ||
        currentRoute == AppRoutes.login ||
        currentRoute == AppRoutes.register ||
        currentRoute == AppRoutes.forgot ||
        currentRoute == AppRoutes.otp ||
        currentRoute == AppRoutes.reset ||
        currentRoute == AppRoutes.twoFactorChallenge ||
        currentRoute == AppRoutes.banned) {
      return;
    }

    if (AppNav.context != null) {
      AppNav.offAllNamed(AppRoutes.login);
    }
  }

  /// مزامنة كافة الموفرات ذات النطاق الجلسي (Session-Scoped Providers)
  void _syncSessionScopedProviders({
    required String? userId,
    required int generation,
  }) {
    final previousUserId = _activeSessionUserId;
    final isAccountBoundary =
        (previousUserId != null && previousUserId != userId) ||
        (previousUserId == 'guest' && userId != 'guest') ||
        userId == null;
    _activeSessionUserId = userId;

    // 1. مزامنة المفضلة والمشاهدات الأخيرة
    try {
      ref.read(wishlistProvider.notifier).syncWithSession(
            userId: userId,
            generation: generation,
          );
    } catch (e, st) {
      // استثناء فقط عدم توفر المزود أثناء الاختبارات المعزولة
      if (e is! StateError && e is! UnimplementedError) {
        debugPrint(
          '[AuthSession] ERROR in wishlistProvider.syncWithSession: $e\n$st',
        );
      }
    }

    // 2. مزامنة عناوين الشحن والتوصيل (Phase 05)
    try {
      ref.read(addressesProvider.notifier).syncWithSession(
            userId: userId,
            generation: generation,
          );
    } catch (e, st) {
      if (e is! StateError && e is! UnimplementedError) {
        debugPrint(
          '[AuthSession] ERROR in addressesProvider.syncWithSession: $e\n$st',
        );
      }
    }

    // 3. مزامنة الطلبات وعمليات الشراء (Phase 08)
    try {
      ref.read(ordersProvider.notifier).syncWithSession(
            userId: userId,
            generation: generation,
          );
    } catch (e, st) {
      if (e is! StateError && e is! UnimplementedError) {
        debugPrint(
          '[AuthSession] ERROR in ordersProvider.syncWithSession: $e\n$st',
        );
      }
    }

    // 4. تطهير المتاجر ذات النطاق الجلسي عند حدود الجلسة (تسجيل خروج، تبديل حساب، دخول ضيف)
    if (isAccountBoundary) {
      _purgeSessionScopedStores(nextGen: generation);
    }
  }

  void _purgeSessionScopedStores({int? nextGen}) {
    // تطهير سلة ومرحلة دفع وطلبات وعناوين Riverpod المعتمدة (SSOT)
    try {
      ref.read(cartProvider.notifier).clearCart();
    } catch (_) {}
    try {
      ref.read(cartQuoteProvider.notifier).reset();
    } catch (_) {}
    try {
      ref.read(checkoutFlowProvider.notifier).reset();
    } catch (_) {}
    try {
      ref.read(ordersProvider.notifier).syncWithSession(
            userId: null,
            generation: nextGen ?? (state.sessionGeneration + 1),
          );
    } catch (_) {}
    try {
      ref.read(addressesProvider.notifier).syncWithSession(
            userId: null,
            generation: nextGen ?? (state.sessionGeneration + 1),
          );
    } catch (_) {}
  }
}
