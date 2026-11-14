import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

/// موفر خدمة المصادقة الحيوية والبصمة وقفل الجهاز
final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

/// خدمة إدارة المصادقة الحيوية (بصمة الإصبع، التعرف على الوجه، رمز قفل الهاتف)
/// مصممة وفق أعلى معايير الأمان مع حماية من الأخطاء والانهيارات في بيئات الاختبار والمحاكيات
class BiometricAuthService {
  BiometricAuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _storage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _storage;

  static const String _tokenKey = 'biometric_auth_token';
  static const String _emailKey = 'biometric_user_email';
  static const String _credentialIdKey = 'biometric_credential_id';
  static const String _secretKey = 'biometric_credential_secret';
  static const String _enabledKey = 'biometric_login_enabled';

  /// فحص ما إذا كان الجهاز يدعم المصادقة البيومترية أو قفل الجهاز
  Future<bool> isBiometricsAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      return canCheck;
    } catch (e) {
      debugPrint('[BiometricAuthService] isBiometricsAvailable error: $e');
      return false;
    }
  }

  /// طلب تأكيد بصمة الإصبع أو رمز قفل الهاتف من المستخدم
  Future<bool> authenticate({
    String reason = 'يرجى تأكيد بصمة الإصبع أو رمز قفل الهاتف للمتابعة في رَوْنَقُك',
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: false, // يسمح بالبصمة أو برمز/كلمة مرور قفل الهاتف
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } on PlatformException catch (e) {
      debugPrint('[BiometricAuthService] PlatformException: ${e.code} - ${e.message}');
      return false;
    } catch (e) {
      debugPrint('[BiometricAuthService] Unexpected authenticate error: $e');
      return false;
    }
  }

  /// حفظ جلسة المصادقة الحيوية الآمنة
  Future<void> saveBiometricSession({
    required String token,
    required String email,
  }) async {
    try {
      await _storage.write(key: _tokenKey, value: token.trim());
      await _storage.write(key: _emailKey, value: email.trim());
      await _storage.write(key: _enabledKey, value: 'true');
    } catch (e) {
      debugPrint('[BiometricAuthService] saveBiometricSession error: $e');
    }
  }

  /// استرجاع التوكن المحفوظ للمصادقة الحيوية
  Future<String?> getSavedBiometricToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token?.trim();
    } catch (e) {
      debugPrint('[BiometricAuthService] getSavedBiometricToken error: $e');
      return null;
    }
  }

  /// استرجاع البريد الإلكتروني المرتبط بالبصمة
  Future<String?> getSavedBiometricEmail() async {
    try {
      final email = await _storage.read(key: _emailKey);
      return email?.trim();
    } catch (e) {
      debugPrint('[BiometricAuthService] getSavedBiometricEmail error: $e');
      return null;
    }
  }

  /// التحقق من وجود جلسة بيومترية مسجلة ومحفوظة مسبقاً
  Future<bool> hasSavedBiometricSession() async {
    final token = await getSavedBiometricToken();
    return token != null && token.isNotEmpty;
  }

  /// حفظ بيانات تسجيل مفتاح المرور / البصمة محلياً
  Future<void> saveBiometricRegistration({
    required String credentialId,
    required String secret,
    required String email,
    String? token,
  }) async {
    try {
      await _storage.write(key: _credentialIdKey, value: credentialId.trim());
      await _storage.write(key: _secretKey, value: secret.trim());
      await _storage.write(key: _emailKey, value: email.trim());
      await _storage.write(key: _enabledKey, value: 'true');
      if (token != null && token.isNotEmpty) {
        await _storage.write(key: _tokenKey, value: token.trim());
      }
    } catch (e) {
      debugPrint('[BiometricAuthService] saveBiometricRegistration error: $e');
    }
  }

  /// استرجاع معرف الاعتماد المحفوظ
  Future<String?> getSavedCredentialId() async {
    try {
      return await _storage.read(key: _credentialIdKey);
    } catch (e) {
      debugPrint('[BiometricAuthService] getSavedCredentialId error: $e');
      return null;
    }
  }

  /// استرجاع السر البيومتري المحفوظ
  Future<String?> getSavedCredentialSecret() async {
    try {
      return await _storage.read(key: _secretKey);
    } catch (e) {
      debugPrint('[BiometricAuthService] getSavedCredentialSecret error: $e');
      return null;
    }
  }

  /// التحقق من وجود تسجيل بيومتري محفوظ
  Future<bool> hasSavedBiometricRegistration() async {
    final credId = await getSavedCredentialId();
    if (credId != null && credId.isNotEmpty) return true;
    final token = await getSavedBiometricToken();
    return token != null && token.isNotEmpty;
  }

  /// مسح جلسة المصادقة الحيوية
  Future<void> clearBiometricSession() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _emailKey);
      await _storage.delete(key: _credentialIdKey);
      await _storage.delete(key: _secretKey);
      await _storage.delete(key: _enabledKey);
    } catch (e) {
      debugPrint('[BiometricAuthService] clearBiometricSession error: $e');
    }
  }
}
