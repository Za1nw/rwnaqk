import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/constants/local_storage_keys.dart';

/// واجهة تخزين توكن الجلسة بشكل آمن
abstract class IAuthTokenStorage {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clearToken();
}

/// تطبيق التخزين الآمن باستخدام Android KeyStore و iOS Keychain
/// مع ترحيل تلقائي لبيانات SharedPreferences القديمة وحماية بيئات الاختبار.
class SecureAuthTokenStorage implements IAuthTokenStorage {
  SecureAuthTokenStorage({FlutterSecureStorage? secureStorage})
      : _storage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                resetOnError: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() async {
    try {
      final secureToken = await _storage.read(key: LocalStorageKeys.authToken);
      if (secureToken != null && secureToken.trim().isNotEmpty) {
        // تنظيف النسخة غير المشفرة في SharedPreferences إن كانت متبقية
        try {
          final prefs = await SharedPreferences.getInstance();
          if (prefs.containsKey(LocalStorageKeys.authToken)) {
            await prefs.remove(LocalStorageKeys.authToken);
          }
        } catch (_) {}
        return secureToken.trim();
      }
    } catch (e) {
      debugPrint('[SecureStorage] Warning on read secure token: $e');
    }

    // ترحيل تلقائي لبيانات التوكن غير المشفرة من SharedPreferences إن وجدت
    try {
      final prefs = await SharedPreferences.getInstance();
      final legacyToken = prefs.getString(LocalStorageKeys.authToken);
      if (legacyToken != null && legacyToken.trim().isNotEmpty) {
        final normalized = legacyToken.trim();
        // نقل التوكن إلى التخزين الآمن
        await writeToken(normalized);
        // حذف التوكن غير المشفر من SharedPreferences
        await prefs.remove(LocalStorageKeys.authToken);
        return normalized;
      }
    } catch (e) {
      debugPrint('[SecureStorage] Fallback check on SharedPreferences: $e');
    }

    return null;
  }

  @override
  Future<void> writeToken(String token) async {
    final normalized = token.trim();
    if (normalized.isEmpty) {
      await clearToken();
      return;
    }

    try {
      await _storage.write(
        key: LocalStorageKeys.authToken,
        value: normalized,
      );
    } catch (e) {
      debugPrint('[SecureStorage] Error writing to secure storage: $e');
      // لا نقوم إطلاقاً بكتابة التوكن كـ plaintext في SharedPreferences لحماية أمان الإنتاج
      if (kReleaseMode) {
        rethrow;
      }
      return;
    }

    // تنظيف SharedPreferences لضمان عدم بقاء نسخة قديمة غير مشفرة
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(LocalStorageKeys.authToken)) {
        await prefs.remove(LocalStorageKeys.authToken);
      }
    } catch (_) {}
  }

  @override
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: LocalStorageKeys.authToken);
    } catch (e) {
      debugPrint('[SecureStorage] Warning deleting secure token: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(LocalStorageKeys.authToken);
    } catch (_) {}
  }
}
