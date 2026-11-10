import 'package:flutter/foundation.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';

/// حالات جلسة المصادقة المعتمدة هندسياً
enum AuthSessionStatus {
  /// الجلسة غير مصادقة ولا يوجد توكن صالح
  unauthenticated,

  /// جاري التحقق من التوكن أو تنفيذ المصادقة
  authenticating,

  /// وضع الضيف (المعاينة والتصميم)
  guest,

  /// يلزم التحقق بخطوتين (2FA Challenge) قبل منح الجلسة الكاملة
  twoFactorChallengeRequired,

  /// تم تسجيل الدخول لكن يلزم تأكيد البريد الإلكتروني
  emailVerificationRequired,

  /// الجلسة مصادقة بالكامل ومؤكدة مع الخادم
  authenticated,
}

/// بيانات تحدي التحقق بخطوتين المؤقتة في الذاكرة (غير محفورة في التخزين الدائم)
@immutable
class TwoFactorChallengePayload {
  final String email;
  final String password;
  final String? message;

  const TwoFactorChallengePayload({
    required this.email,
    required this.password,
    this.message,
  });
}

/// نموذج حالة جلسة المصادقة النقي غير القابل للتعديل [AuthSessionState]
@immutable
class AuthSessionState {
  final AuthSessionStatus status;
  final String? token;
  final CustomerModel? customer;
  final TwoFactorChallengePayload? twoFactorPayload;
  final int sessionGeneration;
  final String? errorMessage;

  const AuthSessionState({
    this.status = AuthSessionStatus.unauthenticated,
    this.token,
    this.customer,
    this.twoFactorPayload,
    this.sessionGeneration = 0,
    this.errorMessage,
  });

  /// التحقق هل الجلسة مصادقة ومصرح لها بالدخول
  bool get isAuthenticated =>
      status == AuthSessionStatus.authenticated ||
      status == AuthSessionStatus.guest;

  /// التحقق هل الجلسة في وضع الضيف
  bool get isGuest => status == AuthSessionStatus.guest;

  /// التحقق هل يلزم إكمال تحدي التحقق بخطوتين
  bool get requiresTwoFactor =>
      status == AuthSessionStatus.twoFactorChallengeRequired;

  /// التحقق هل يلزم تأكيد البريد الإلكتروني
  bool get requiresEmailVerification =>
      status == AuthSessionStatus.emailVerificationRequired;

  /// معرف العميل المسجل كنص
  String? get customerId => customer?.id.toString();

  /// استنساخ الحالة مع خيارات تصفير صريحة للحقول القابلة لـ null
  AuthSessionState copyWith({
    AuthSessionStatus? status,
    String? token,
    bool clearToken = false,
    CustomerModel? customer,
    bool clearCustomer = false,
    TwoFactorChallengePayload? twoFactorPayload,
    bool clearTwoFactorPayload = false,
    int? sessionGeneration,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthSessionState(
      status: status ?? this.status,
      token: clearToken ? null : (token ?? this.token),
      customer: clearCustomer ? null : (customer ?? this.customer),
      twoFactorPayload: clearTwoFactorPayload
          ? null
          : (twoFactorPayload ?? this.twoFactorPayload),
      sessionGeneration: sessionGeneration ?? this.sessionGeneration,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

