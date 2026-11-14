import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

/// كلاس بديل خفيف وخالص من أي تبعية لـ GetX لتوافق الحقول التفاعلية
class SessionRx<T> {
  SessionRx(this.value);
  T value;
  T call([T? v]) {
    if (v != null) value = v;
    return value;
  }

  @override
  String toString() => 'SessionRx($value)';
}

/// جسر التوافقية المؤقت لجلسة المصادقة (Single-Writer Compatibility Bridge الخالص).
///
/// تم تحويل هذا الكلاس إلى مهايئ قراءة وتفويض أحادي الاتجاه خالص من GetX،
/// حيث تكون حاوية Riverpod 3 وموفر [authSessionProvider] هي المالك الحصري الأوحد للحالة (Single Authoritative Writer).
class AuthSessionService {
  AuthSessionService({
    String? initialAccessToken,
    IAuthTokenStorage? tokenStorage,
    this._container,
  })  : _tokenStorage = tokenStorage ?? SecureAuthTokenStorage() {
    final hasInitialToken = (initialAccessToken ?? '').trim().isNotEmpty;
    if (hasInitialToken) {
      final normToken = initialAccessToken!.trim();
      token.value = normToken;
      try {
        _notifier.startSession(accessToken: normToken);
      } catch (_) {}
    }
    _bindToRiverpod();
  }

  // ignore: unused_field
  final IAuthTokenStorage _tokenStorage;
  final ProviderContainer? _container;
  ProviderSubscription<dynamic>? _subscription;

  ProviderContainer get _effectiveContainer =>
      _container ?? globalProviderContainer;

  AuthSessionNotifier get _notifier =>
      _effectiveContainer.read(authSessionProvider.notifier);

  /// إسقاط قراءة تفاعلي متزامن أحادي الاتجاه من Riverpod
  final token = SessionRx<String?>(null);
  final requiresEmailVerification = SessionRx<bool>(false);
  final customer = SessionRx<CustomerModel?>(null);
  final isGuestMode = SessionRx<bool>(false);

  void Function()? _onSessionTerminated;

  /// دالة تنظيف البيانات المحلية المرتبطة بالحساب (السلة، الطلبات، العناوين، المفضلة)
  void Function()? get onSessionTerminated =>
      _notifier.onSessionTerminated ?? _onSessionTerminated;

  set onSessionTerminated(void Function()? callback) {
    _onSessionTerminated = callback;
    _notifier.onSessionTerminated = callback;
  }

  bool get isAuthenticated =>
      (token.value ?? '').isNotEmpty || isGuestMode.value;

  /// رقم جيل الجلسة الحالي المنعكس من Riverpod
  int get sessionGeneration =>
      _effectiveContainer.read(authSessionProvider).sessionGeneration;

  void _bindToRiverpod() {
    try {
      final container = _effectiveContainer;
      final initial = container.read(authSessionProvider);
      if (initial.token != null && initial.token!.isNotEmpty) {
        token.value = initial.token;
      }
      requiresEmailVerification.value = initial.requiresEmailVerification;
      customer.value = initial.customer;
      isGuestMode.value = initial.isGuest;

      _subscription?.close();
      _subscription = container.listen(
        authSessionProvider,
        (previous, next) {
          token.value = next.token;
          requiresEmailVerification.value = next.requiresEmailVerification;
          customer.value = next.customer;
          isGuestMode.value = next.isGuest;
        },
        fireImmediately: false,
      );
    } catch (_) {
      // حماية في حال تم الاستدعاء قبل تهيئة الحاوية في بيئة الاختبار
    }
  }

  void onClose() {
    _subscription?.close();
    _subscription = null;
  }

  void dispose() => onClose();

  /// تمكين وضع الضيف لتجاوز تسجيل الدخول لأغراض التصميم والتطوير
  void enterGuestMode() {
    _notifier.enterGuestMode();
  }

  /// استعادة الجلسة عند بدء تشغيل التطبيق
  Future<void> bootstrapSession([CustomerAuthApiService? api]) async {
    await _notifier.bootstrapSession(initialToken: token.value);
  }

  /// بدء جلسة مصادقة جديدة
  void startSession({
    required String accessToken,
    CustomerModel? customerPayload,
    bool emailVerificationRequired = false,
  }) {
    _notifier.startSession(
      accessToken: accessToken,
      customerPayload: customerPayload,
      emailVerificationRequired: emailVerificationRequired,
    );
  }

  /// تعيين بيانات العميل
  void setCustomer(CustomerModel? customerModel) {
    _notifier.setCustomer(customerModel);
  }

  /// تحديث بيانات العميل عبر دالة تحويل
  void updateCustomer(CustomerModel Function(CustomerModel? current) update) {
    _notifier.updateCustomer(update);
  }

  bool _isHandlingUnauthorized = false;

  /// تفريغ الجلسة محلياً
  void clearSession() {
    isGuestMode.value = false;
    token.value = null;
    customer.value = null;
    requiresEmailVerification.value = false;
    _notifier.clearSession();
  }

  /// إكمال تأكيد البريد الإلكتروني
  Future<void> completeEmailVerification() async {
    await _notifier.completeEmailVerification();
  }

  /// تعيين راية تأكيد البريد الإلكتروني
  void setEmailVerificationRequired(bool value) {
    if (value) {
      _notifier.startSession(
        accessToken: token.value ?? '',
        customerPayload: customer.value,
        emailVerificationRequired: true,
      );
    } else {
      unawaited(_notifier.completeEmailVerification());
    }
  }

  /// معالجة استجابة HTTP 401 المركزية
  Future<void> handleUnauthorized({
    String? failedToken,
    int? staleGeneration,
  }) async {
    if (_isHandlingUnauthorized) {
      return;
    }

    _isHandlingUnauthorized = true;
    try {
      // تفويض المعالجة بالكامل وبشكل صارم إلى نوتيفاير Riverpod (الكاتب الأوحد)
      await _notifier.handleUnauthorized(
        failedToken: failedToken,
        staleGeneration: staleGeneration,
      );

      // مزامنة حالة الإسقاط المحلي حصراً من نوتيفاير Riverpod بعد المعالجة
      final currentRiverpodState =
          _effectiveContainer.read(authSessionProvider);
      token.value = currentRiverpodState.token;
      requiresEmailVerification.value =
          currentRiverpodState.requiresEmailVerification;
      customer.value = currentRiverpodState.customer;
      isGuestMode.value = currentRiverpodState.isGuest;

      // إذا كانت النتيجة الفعلية لنوتيفاير Riverpod هي إنهاء الجلسة، نقوم بمسح التخزين الممرر للمهايئ محلياً
      if (!currentRiverpodState.isAuthenticated) {
        await _tokenStorage.clearToken();
      }
    } finally {
      _isHandlingUnauthorized = false;
    }
  }
}
