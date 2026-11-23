import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_env.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/errors/exceptions.dart' show CacheException;
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/checkout/providers/checkout_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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

  bool get isCurrentSessionBanned => state.isBanned;
  String? get currentErrorMessage => state.errorMessage;

  static const String _kCachedProfilePrefix = 'cached_customer_profile_';
  static const String _kLastAuthUserIdKey = 'last_authenticated_user_id';
  static const String _kLegacyCachedProfileKey = 'cached_customer_profile';
  static const String _kSessionInvalidatedKey = 'auth_session_invalidated_flag';

  /// طابور متسلسل لتنفيذ كافة عمليات كتابة ومسح التوكن والكاش بشكل متسلسل ومحمي من السباق
  Future<void> _storageQueue = Future<void>.value();

  Future<T> _enqueueStorageOp<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _storageQueue = _storageQueue.then((_) async {
      try {
        final result = await action();
        completer.complete(result);
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  void _reportError(Object error, StackTrace stackTrace, String operation) {
    try {
      Sentry.captureException(
        error,
        stackTrace: stackTrace,
        withScope: (scope) {
          scope.setTag('auth_operation', operation);
          scope.setTag('session_status', state.status.name);
        },
      );
    } catch (_) {
      // Sentry failure must never crash the app
    }
  }

  Future<void> _saveCustomerProfile(CustomerModel customer, [SharedPreferences? preferences]) async {
    return _enqueueStorageOp(() async {
      try {
        SharedPreferences? prefs = preferences;
        if (prefs == null) {
          try {
            prefs = ref.read(sharedPreferencesInstanceProvider);
          } catch (e, st) {
            debugPrint('[AuthSession] Error reading sharedPreferencesInstanceProvider in _saveCustomerProfile: $e\n$st');
            return;
          }
        }
        if (prefs == null) return;
        final envelope = <String, dynamic>{
          'user_id': customer.id,
          'email': customer.email,
          'cached_at': DateTime.now().millisecondsSinceEpoch,
          'customer': customer.toJson(),
        };
        await prefs.setString(
          '$_kCachedProfilePrefix${customer.id}',
          jsonEncode(envelope),
        );
        await prefs.setString(_kLastAuthUserIdKey, customer.id.toString());
        await prefs.remove(_kSessionInvalidatedKey);
        if (prefs.containsKey(_kLegacyCachedProfileKey)) {
          await prefs.remove(_kLegacyCachedProfileKey);
        }
      } catch (e, st) {
        debugPrint('[AuthSession] Error saving isolated customer cache: $e\n$st');
      }
    });
  }

  CustomerModel? _getIsolatedCachedCustomer([SharedPreferences? preferences]) {
    try {
      SharedPreferences? prefs = preferences;
      if (prefs == null) {
        try {
          prefs = ref.read(sharedPreferencesInstanceProvider);
        } catch (e, st) {
          debugPrint('[AuthSession] Error reading sharedPreferencesInstanceProvider in _getIsolatedCachedCustomer: $e\n$st');
          return null;
        }
      }
      if (prefs == null) return null;

      final lastUserId = prefs.getString(_kLastAuthUserIdKey);
      if (lastUserId == null || lastUserId.isEmpty) return null;

      final rawEnvelope = prefs.getString('$_kCachedProfilePrefix$lastUserId');
      if (rawEnvelope == null || rawEnvelope.isEmpty) return null;

      final decoded = jsonDecode(rawEnvelope) as Map<String, dynamic>;
      final envelopeUserId = decoded['user_id']?.toString();
      final customerData = decoded['customer'];

      // التحقق الصارم من تطابق هوية المستخدم مع الكاش قبل الاسترجاع
      if (envelopeUserId == lastUserId && customerData is Map<String, dynamic>) {
        return CustomerModel.fromJson(customerData);
      }
    } catch (e, st) {
      debugPrint('[AuthSession] Error reading isolated customer cache: $e\n$st');
    }
    return null;
  }

  Future<void> _clearCustomerProfileCache([SharedPreferences? preferences]) async {
    return _enqueueStorageOp(() async {
      try {
        SharedPreferences? prefs = preferences;
        if (prefs == null) {
          try {
            prefs = ref.read(sharedPreferencesInstanceProvider);
          } catch (e, st) {
            debugPrint('[AuthSession] Error reading sharedPreferencesInstanceProvider in _clearCustomerProfileCache: $e\n$st');
            return;
          }
        }
        if (prefs == null) return;
        final lastUserId = prefs.getString(_kLastAuthUserIdKey);
        if (lastUserId != null && lastUserId.isNotEmpty) {
          await prefs.remove('$_kCachedProfilePrefix$lastUserId');
        }
        await prefs.remove(_kLastAuthUserIdKey);
        await prefs.remove(_kLegacyCachedProfileKey);
        await prefs.setBool(_kSessionInvalidatedKey, true);
      } catch (e, st) {
        debugPrint('[AuthSession] Error clearing customer cache: $e\n$st');
      }
    });
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
    String rawToken = '';

    try {
      rawToken = (initialToken != null && initialToken != 'cached_session')
          ? initialToken
          : (await storage.readToken() ?? '');
    } on PlatformException catch (e, st) {
      debugPrint('[AuthSession] PlatformException reading storage on bootstrap: ${e.code} - ${e.message}\n$st');
      state = state.copyWith(
        status: AuthSessionStatus.serverError,
        errorMessage: 'تعذر الوصول إلى التخزين الآمن في الجهاز',
      );
      return;
    } on CacheException catch (e, st) {
      debugPrint('[AuthSession] CacheException reading storage on bootstrap: ${e.message}\n$st');
      state = state.copyWith(
        status: AuthSessionStatus.serverError,
        errorMessage: 'تعذر الوصول إلى التخزين الآمن في الجهاز',
      );
      return;
    } catch (e, st) {
      debugPrint('[AuthSession] Unexpected error reading storage on bootstrap: $e\n$st');
      state = state.copyWith(
        status: AuthSessionStatus.serverError,
        errorMessage: 'تعذر قراءة بيانات الجلسة',
      );
      return;
    }

    final token = rawToken.trim();

    // التحقق هل الجلسة السابقة تم إبطالها (مثلاً خروج أو دخول ضيف سابق مع تعثر في مسح التخزين)
    SharedPreferences? bootstrapPrefs;
    try {
      bootstrapPrefs = ref.read(sharedPreferencesInstanceProvider);
    } catch (_) {}
    final isSessionInvalidated = bootstrapPrefs?.getBool(_kSessionInvalidatedKey) ?? false;
    if (isSessionInvalidated) {
      debugPrint('[AuthSession] Stored session was invalidated previously. Wiping stale token.');
      try {
        await storage.clearToken();
      } catch (e, st) {
        debugPrint('[AuthSession] Error retrying clearToken on bootstrap: $e\n$st');
      }
      state = state.copyWith(
        status: AuthSessionStatus.unauthenticated,
        clearToken: true,
        clearCustomer: true,
        isBootstrapping: false,
      );
      if (AppNav.context != null && !state.isGuest) {
        final currentRoute = AppNav.currentRoute;
        if (currentRoute != null &&
            currentRoute != AppRoutes.onboarding &&
            currentRoute != AppRoutes.login) {
          AppNav.offAllNamed(AppRoutes.login);
        }
      }
      return;
    }

    if (token.isEmpty) {
      state = state.copyWith(
        status: AuthSessionStatus.unauthenticated,
        isBootstrapping: false,
      );
      if (AppNav.context != null && !state.isGuest) {
        final currentRoute = AppNav.currentRoute;
        if (currentRoute != null &&
            currentRoute != AppRoutes.onboarding &&
            currentRoute != AppRoutes.login) {
          AppNav.offAllNamed(AppRoutes.login);
        }
      }
      return;
    }

    // تعيين الجلسة في حالة التحقق الأولي (Bootstrapping) دون اعتبارها مصادقة نهائياً قبل فحص /auth/me
    state = state.copyWith(
      status: AuthSessionStatus.authenticating,
      token: token,
      isBootstrapping: true,
    );

    // استرجاع بيانات العميل الحقيقية المحفوظة محلياً مسبقاً بشكل معزول لآخر مستخدم موثق
    if (state.customer == null) {
      final cached = _getIsolatedCachedCustomer();
      if (cached != null) {
        state = state.copyWith(customer: cached);
      }
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
        await markAsBanned(customerPayload: customer);
        return;
      }

      final requiresVerification = customer.emailVerifiedAt == null;
      final nextGen = state.sessionGeneration + 1;

      if (requiresVerification) {
        state = state.copyWith(
          status: AuthSessionStatus.emailVerificationRequired,
          customer: customer,
          sessionGeneration: nextGen,
          isBootstrapping: false,
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
        isBootstrapping: false,
      );

      _saveCustomerProfile(customer);

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
      await markAsBanned(
        customerPayload: customer,
        reason: bannedEx.message,
      );
    } on UnauthorizedException {
      await _clearSessionAndRedirectToLogin();
    } catch (e) {
      debugPrint('[AuthSession] bootstrapSession transient error: $e');
      state = state.copyWith(
        status: AuthSessionStatus.serverError,
        errorMessage: e.toString(),
        isBootstrapping: false,
      );
      if (AppNav.context != null) {
        AppNav.offAllNamed(AppRoutes.networkError);
      }
    }
  }

  /// إعادة محاولة الاتصال بالخادم والتحقق من الجلسة
  Future<bool> retryBootstrap() async {
    state = state.copyWith(
      status: AuthSessionStatus.authenticating,
      isBootstrapping: true,
      clearErrorMessage: true,
    );

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final customer = await authRepo.me();

      if (customer.isBanned == true) {
        await markAsBanned(customerPayload: customer);
        return false;
      }

      final requiresVerification = customer.emailVerifiedAt == null;
      final nextGen = state.sessionGeneration + 1;

      if (requiresVerification) {
        state = state.copyWith(
          status: AuthSessionStatus.emailVerificationRequired,
          customer: customer,
          sessionGeneration: nextGen,
          isBootstrapping: false,
        );
        AppNav.offAllNamed(
          AppRoutes.emailVerify,
          arguments: <String, dynamic>{'email': customer.email},
        );
        return false;
      }

      state = state.copyWith(
        status: AuthSessionStatus.authenticated,
        customer: customer,
        sessionGeneration: nextGen,
        isBootstrapping: false,
      );

      _saveCustomerProfile(customer);

      _syncSessionScopedProviders(
        userId: customer.id.toString(),
        generation: nextGen,
      );

      AppNav.offAllNamed(AppRoutes.main);
      return true;
    } on AccountBannedException catch (bannedEx) {
      CustomerModel? customer;
      if (bannedEx.customerData != null) {
        try {
          customer = CustomerModel.fromJson(bannedEx.customerData!);
        } catch (_) {}
      }
      await markAsBanned(
        customerPayload: customer,
        reason: bannedEx.message,
      );
      return false;
    } on UnauthorizedException {
      await _clearSessionAndRedirectToLogin();
      return false;
    } catch (e) {
      debugPrint('[AuthSession] retryBootstrap failed: $e');
      state = state.copyWith(
        status: AuthSessionStatus.serverError,
        errorMessage: e.toString(),
        isBootstrapping: false,
      );
      return false;
    }
  }

  /// بدء جلسة مصادقة ناجحة بعد تسجيل الدخول أو التسجيل
  Future<void> startSession({
    required String accessToken,
    CustomerModel? customerPayload,
    bool emailVerificationRequired = false,
  }) async {
    // 0. حماية استباقية (FIX-03): منع إنشاء جلسة لحساب محظور
    if (customerPayload?.isBanned == true) {
      await markAsBanned(customerPayload: customerPayload);
      return;
    }

    final normalizedToken = accessToken.trim();
    if (normalizedToken.isEmpty) {
      state = state.copyWith(
        status: AuthSessionStatus.unauthenticated,
        errorMessage: 'رمز المصادقة غير صالح',
      );
      return;
    }

    IAuthTokenStorage? storage;
    SharedPreferences? prefs;
    try {
      storage = ref.read(authTokenStorageProvider);
      prefs = ref.read(sharedPreferencesInstanceProvider);
    } catch (e, st) {
      debugPrint('[AuthSession] Error obtaining storage providers: $e\n$st');
    }

    // 1. التخزين الآمن أولاً (FIX-02): التحقق من نجاح حفظ التوكن بشكل آمن قبل إنشاء أي جلسة بالذاكرة
    if (!emailVerificationRequired && normalizedToken.isNotEmpty) {
      final activeStorage = storage;
      if (activeStorage == null) {
        throw const CacheException(message: 'تعذر حفظ بيانات الجلسة بشكل آمن.');
      }
      try {
        await _enqueueStorageOp(() async {
          final currentStoredToken = await activeStorage.readToken();
          if (currentStoredToken != normalizedToken) {
            await activeStorage.writeToken(normalizedToken);
          }
        });
      } on CacheException {
        rethrow;
      } catch (e, st) {
        debugPrint('[AuthSession] Error persisting token in startSession: $e\n$st');
        _reportError(e, st, 'writeToken_startSession');
        Error.throwWithStackTrace(
          const CacheException(message: 'تعذر حفظ بيانات الجلسة بشكل آمن.'),
          st,
        );
      }
    }

    // 2. لن نصل إلى هنا إلا بعد ضمان التخزين الآمن والتحقق من عدم الحظر
    final nextGen = state.sessionGeneration + 1;
    final status = emailVerificationRequired
        ? AuthSessionStatus.emailVerificationRequired
        : AuthSessionStatus.authenticated;

    CustomerModel? resolvedCustomer = customerPayload;

    // تحديث الحالة بالذاكرة وتنسيق الموفرات فقط بعد ضمان التخزين الآمن
    state = state.copyWith(
      status: status,
      token: normalizedToken,
      customer: resolvedCustomer,
      clearTwoFactorPayload: true,
      clearErrorMessage: true,
      sessionGeneration: nextGen,
    );

    _syncSessionScopedProviders(
      userId: resolvedCustomer?.id.toString(),
      generation: nextGen,
      isLogin: true,
    );

    // أمنياً وعزل بيانات (SEC-02): لا نسترجع أي كاش قديم إذا لم يتم تمرير ملف العميل الموثق،
    // لمنع تسريب بيانات مستخدم سابق للمستخدم الجديد عند تسجيل الدخول
    if (resolvedCustomer != null) {
      await _saveCustomerProfile(resolvedCustomer, prefs);
    }
  }

  /// محاولة استعادة وتحديث بيانات العميل عند بدء جلسة بدون بيانات العميل
  Future<CustomerModel?> recoverCustomerProfile() async {
    final callingGeneration = state.sessionGeneration;
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final customer = await authRepo.me();

      // حماية من العمليات القديمة (Stale Write Guard):
      // إذا تغير جيل الجلسة (مثلاً سجل المستخدم خروجه أثناء انتظار الاستجابة)، نتجاهل النتيجة فوراً
      if (state.sessionGeneration != callingGeneration || !state.isAuthenticated) {
        debugPrint('[AuthSession] Stale recoverCustomerProfile ignored: generation changed');
        return null;
      }

      if (customer.isBanned == true) {
        await markAsBanned(customerPayload: customer);
        return null;
      }
      setCustomer(customer);
      await _saveCustomerProfile(customer);
      _syncSessionScopedProviders(
        userId: customer.id.toString(),
        generation: state.sessionGeneration,
      );
      return customer;
    } catch (e) {
      debugPrint('[AuthSession] recoverCustomerProfile failed: $e');
      return null;
    }
  }

  /// التحقق من حساب المستخدم بعد تسجيل دخول ناجح بدون بيانات العميل في الاستجابة
  /// (Login Bootstrap Verification: Single Writer + Fail-Closed)
  Future<CustomerModel?> bootstrapLoginVerification({
    required String token,
  }) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      await clearSession();
      return null;
    }

    IAuthTokenStorage? storage;
    try {
      storage = ref.read(authTokenStorageProvider);
    } catch (e, st) {
      debugPrint('[AuthSession] Error obtaining storage in bootstrapLoginVerification: $e\n$st');
    }

    final activeStorage = storage;
    if (activeStorage == null) {
      await clearSession();
      return null;
    }

    // 1. Single Writer: حفظ التوكن في التخزين الآمن أولاً
    try {
      await _enqueueStorageOp(() async {
        final currentStoredToken = await activeStorage.readToken();
        if (currentStoredToken != normalizedToken) {
          await activeStorage.writeToken(normalizedToken);
        }
      });
    } on CacheException catch (e, st) {
      debugPrint('[AuthSession] Storage cache error in bootstrapLoginVerification: ${e.message}\n$st');
      _reportError(e, st, 'writeToken_bootstrapLoginVerification_cache');
      await clearSession();
      return null;
    } catch (e, st) {
      debugPrint('[AuthSession] Unexpected error writing token in bootstrapLoginVerification: $e\n$st');
      _reportError(e, st, 'writeToken_bootstrapLoginVerification_unexpected');
      await clearSession();
      return null;
    }

    // 2. تعيين حالة الجلسة المؤقتة للتحقق (isBootstrapping: true) دون اعتبارها authenticated
    final callingGen = state.sessionGeneration + 1;
    state = state.copyWith(
      status: AuthSessionStatus.unauthenticated,
      token: normalizedToken,
      isBootstrapping: true,
      clearCustomer: true,
      clearErrorMessage: true,
      sessionGeneration: callingGen,
    );

    // 3. استدعاء /api/v1/customer/auth/me للتحقق من هوية وحالة الحظر للمستخدم
    try {
      final authRepo = ref.read(authRepositoryProvider);
      final customer = await authRepo.me();

      // التحقق من تداخل الجلسات
      if (state.sessionGeneration != callingGen) {
        debugPrint('[AuthSession] Stale bootstrapLoginVerification ignored: generation mismatch');
        return null;
      }

      if (customer.isBanned == true) {
        await markAsBanned(customerPayload: customer);
        return null;
      }

      final requiresVerification = customer.emailVerifiedAt == null;
      final nextGen = state.sessionGeneration + 1;

      if (requiresVerification) {
        state = state.copyWith(
          status: AuthSessionStatus.emailVerificationRequired,
          customer: customer,
          sessionGeneration: nextGen,
          isBootstrapping: false,
        );
        AppNav.offAllNamed(
          AppRoutes.emailVerify,
          arguments: <String, dynamic>{'email': customer.email},
        );
        return customer;
      }

      // الانتقال إلى authenticated فقط بعد التحقق الناجح
      state = state.copyWith(
        status: AuthSessionStatus.authenticated,
        customer: customer,
        sessionGeneration: nextGen,
        isBootstrapping: false,
      );

      _syncSessionScopedProviders(
        userId: customer.id.toString(),
        generation: nextGen,
        isLogin: true,
      );

      await _saveCustomerProfile(customer);
      return customer;
    } on AccountBannedException catch (bannedEx) {
      CustomerModel? bannedCustomer;
      if (bannedEx.customerData != null) {
        try {
          bannedCustomer = CustomerModel.fromJson(bannedEx.customerData!);
        } catch (_) {}
      }
      await markAsBanned(
        customerPayload: bannedCustomer,
        reason: bannedEx.message,
      );
      return null;
    } catch (e, st) {
      debugPrint('[AuthSession] Verification me() failed in bootstrapLoginVerification: $e\n$st');
      await clearSession();
      return null;
    }
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
  Future<void> enterGuestMode() async {
    final nextGen = state.sessionGeneration + 1;

    // تحديث فوري ومتزامن لحالة الجلسة في الذاكرة لضمان عدم وجود هوية أو توكن
    state = state.copyWith(
      status: AuthSessionStatus.guest,
      clearToken: true,
      clearCustomer: true,
      clearTwoFactorPayload: true,
      clearErrorMessage: true,
      sessionGeneration: nextGen,
      isBootstrapping: false,
    );

    _syncSessionScopedProviders(
      userId: 'guest',
      generation: nextGen,
    );

    // تنظيف متسلسل في التخزين عبر الـ queue مع حماية generation وعدم كتم الأخطاء
    await _safeClearTokenAndProfileCache(targetGeneration: nextGen);
  }

  Future<void> _safeClearTokenAndProfileCache({required int targetGeneration}) async {
    IAuthTokenStorage? storage;
    SharedPreferences? prefs;
    try {
      storage = ref.read(authTokenStorageProvider);
      prefs = ref.read(sharedPreferencesInstanceProvider);
    } catch (_) {}

    final activeStorage = storage;
    final activePrefs = prefs;

    await _enqueueStorageOp(() async {
      // حماية جيل الجلسة: إذا تغير جيل الجلسة أو تم التخلص من الموفر نتجاهل العملية
      try {
        if (state.sessionGeneration != targetGeneration) {
          debugPrint('[AuthSession] Stale _safeClearTokenAndProfileCache skipped: generation changed');
          return;
        }
      } catch (_) {
        return;
      }

      // 1. مسح التوكن من التخزين الآمن دون ابتلاع صامت للخطأ
      if (activeStorage != null) {
        try {
          await activeStorage.clearToken();
        } on PlatformException catch (e, st) {
          debugPrint('[AuthSession] PlatformException clearing token in guest mode: ${e.code} - ${e.message}\n$st');
          _reportError(e, st, 'clearToken_guestMode_platform');
          try {
            await activePrefs?.setBool(_kSessionInvalidatedKey, true);
          } catch (_) {}
        } on CacheException catch (e, st) {
          debugPrint('[AuthSession] CacheException clearing token in guest mode: ${e.message}\n$st');
          _reportError(e, st, 'clearToken_guestMode_cache');
          try {
            await activePrefs?.setBool(_kSessionInvalidatedKey, true);
          } catch (_) {}
        } catch (e, st) {
          debugPrint('[AuthSession] Unexpected error clearing token in guest mode: $e\n$st');
          _reportError(e, st, 'clearToken_guestMode_unexpected');
          try {
            await activePrefs?.setBool(_kSessionInvalidatedKey, true);
          } catch (_) {}
        }
      }

      // التحقق مجدداً من الجيل قبل مسح كاش الملف الشخصي
      try {
        if (state.sessionGeneration != targetGeneration) {
          debugPrint('[AuthSession] Stale profile cache clear skipped: generation changed');
          return;
        }
      } catch (_) {
        return;
      }

      // 2. مسح كاش الملف الشخصي
      if (activePrefs != null) {
        try {
          final lastUserId = activePrefs.getString(_kLastAuthUserIdKey);
          if (lastUserId != null && lastUserId.isNotEmpty) {
            await activePrefs.remove('$_kCachedProfilePrefix$lastUserId');
          }
          await activePrefs.remove(_kLastAuthUserIdKey);
          await activePrefs.remove(_kLegacyCachedProfileKey);
        } catch (e, st) {
          debugPrint('[AuthSession] Error clearing customer cache in guest mode: $e\n$st');
          _reportError(e, st, 'clearCustomerProfile_guestMode');
        }
      }
    });
  }

  /// تحديث بيانات العميل المسجل
  void setCustomer(CustomerModel? customerModel) {
    state = state.copyWith(
      customer: customerModel,
      clearCustomer: customerModel == null,
    );
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
    try {
      await storage.writeToken(currentToken);
    } on CacheException {
      rethrow;
    } catch (e, st) {
      debugPrint(
          '[AuthSession] Error persisting token on completeEmailVerification: $e\n$st');
      Error.throwWithStackTrace(
        const CacheException(message: 'تعذر حفظ بيانات الجلسة بشكل آمن.'),
        st,
      );
    }

    state = state.copyWith(
      status: AuthSessionStatus.authenticated,
      customer: updatedCustomer ?? currentCustomer,
    );
  }

  /// وسم الحساب كمحظور وإعادة توجيهه بشكل فوري إلى شاشة الحظر
  Future<void> markAsBanned({CustomerModel? customerPayload, String? reason}) async {
    final nextGen = state.sessionGeneration + 1;

    state = state.copyWith(
      status: AuthSessionStatus.banned,
      clearToken: true,
      isBootstrapping: false,
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

    // تفريغ التوكن التخزيني بأمان من SecureStorage لمنع استخدامه في أي طلبات لاحقة (FIX-01/FIX-03)
    try {
      final storage = ref.read(authTokenStorageProvider);
      await storage.clearToken();
    } on CacheException catch (e, st) {
      debugPrint('[AuthSession] Storage cache error clearing token on markAsBanned: ${e.message}\n$st');
    } catch (e, st) {
      debugPrint('[AuthSession] Unexpected error clearing token on markAsBanned: $e\n$st');
    }
  }

  /// تفريغ الجلسة محلياً بالكامل
  Future<void> clearSession() async {
    IAuthTokenStorage? storage;
    SharedPreferences? prefs;
    try {
      storage = ref.read(authTokenStorageProvider);
      prefs = ref.read(sharedPreferencesInstanceProvider);
    } catch (_) {}

    final nextGen = state.sessionGeneration + 1;

    // تفريغ فوري متزامن لحالة الجلسة والموفرات المرتبطة
    state = state.copyWith(
      status: AuthSessionStatus.unauthenticated,
      clearToken: true,
      clearCustomer: true,
      clearTwoFactorPayload: true,
      clearErrorMessage: true,
      isBootstrapping: false,
      sessionGeneration: nextGen,
    );

    _syncSessionScopedProviders(
      userId: null,
      generation: nextGen,
    );

    final activeStorage = storage;
    if (activeStorage != null) {
      await _enqueueStorageOp(() async {
        await activeStorage.clearToken();
      });
    }

    await _clearCustomerProfileCache(prefs);
  }

  /// تسجيل الخروج الآمن
  Future<void> logout() async {
    final storage = ref.read(authTokenStorageProvider);
    final authRepo = ref.read(authRepositoryProvider);

    try {
      await authRepo.logout();
    } catch (_) {
      // نتجاهل أخطاء الشبكة أثناء تسجيل الخروج لضمان استمرار التطهير المحلي
    }

    // 1. حذف التوكن من التخزين الآمن دون ابتلاع الخطأ (FIX-02-HOTFIX-02)
    // إذا فشل الحذف، نلقي CacheException فوراً ولا نعلن نجاح تسجيل الخروج أو إعادة التوجيه
    await storage.clearToken();
    await clearSession();

    try {
      onSessionTerminated?.call();
    } catch (e) {
      debugPrint('[AuthSession] Error in onSessionTerminated: $e');
    }

    _redirectOnLogout();
  }

  /// معالجة استجابة HTTP 401 Unauthorized المركزية من عميل الشبكة
  Future<void> handleUnauthorized({
    String? failedToken,
    int? staleGeneration,
  }) async {
    if (_isHandlingUnauthorized) {
      return;
    }

    // حماية حالة الحظر (FIX-01): إذا كان الحساب محظوراً، نرفض فوراً أي استجابة 401 لمنع كسر قفل الحظر
    if (state.isBanned) {
      debugPrint('[AuthSession] 401 ignored: account is currently banned.');
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
      await clearSession();

      try {
        onSessionTerminated?.call();
      } catch (e) {
        debugPrint('[AuthSession] Error in onSessionTerminated: $e');
      }

      _redirectOnLogout();
    } catch (e, st) {
      debugPrint('[AuthSession] Error in handleUnauthorized: $e\n$st');
    } finally {
      _isHandlingUnauthorized = false;
    }
  }

  Future<void> _clearSessionAndRedirectToLogin() async {
    await clearSession();
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
        currentRoute == AppRoutes.banned ||
        currentRoute == AppRoutes.networkError) {
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
    bool isLogin = false,
  }) {
    final previousUserId = _activeSessionUserId;
    final isAccountBoundary =
        (previousUserId != null && previousUserId != userId) ||
        (previousUserId == 'guest' && userId != 'guest') ||
        userId == null;
    _activeSessionUserId = userId;

    // 1. عند حدود الحساب (SEC-03): نطهر أولاً السلة والـ checkout من بيانات الحساب السابق
    // قبل الشروع في مزامنة الموفرات بهوية الحساب الجديد
    if (isAccountBoundary) {
      _purgeSessionScopedStores(nextGen: generation);
    }

    // 2. بعد التطهير، نقوم بمزامنة الموفرات بهوية الحساب الجديد (أو تفريغها إذا كان userId == null)
    // مزامنة المفضلة والمشاهدات الأخيرة
    try {
      ref.read(wishlistProvider.notifier).syncWithSession(
            userId: userId,
            generation: generation,
            isLogin: isLogin,
          );
    } catch (e, st) {
      // استثناء فقط عدم توفر المزود أثناء الاختبارات المعزولة
      if (e is! StateError && e is! UnimplementedError) {
        debugPrint(
          '[AuthSession] ERROR in wishlistProvider.syncWithSession: $e\n$st',
        );
      }
    }

    // مزامنة عناوين الشحن والتوصيل بهوية المستخدم الجديد
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

    // مزامنة الطلبات بهوية المستخدم الجديد
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
  }

  void _purgeSessionScopedStores({int? nextGen}) {
    // تطهير سلة ومرحلة دفع Riverpod المعتمدة (SSOT)
    try {
      ref.read(cartProvider.notifier).clearCart();
    } catch (_) {}
    try {
      ref.read(cartQuoteProvider.notifier).reset();
    } catch (_) {}
    try {
      ref.read(checkoutFlowProvider.notifier).reset();
    } catch (_) {}
  }
}
