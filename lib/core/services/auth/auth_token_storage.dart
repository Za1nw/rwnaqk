import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/core/constants/local_storage_keys.dart';
import 'package:rwnaqk_frontend/core/errors/exceptions.dart';

/// واجهة تخزين توكن الجلسة بشكل آمن
abstract class IAuthTokenStorage {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clearToken();
}

/// تطبيق التخزين الآمن باستخدام Android KeyStore و iOS Keychain
/// مع تفعيل encryptedSharedPreferences لحماية هواتف سامسونج من التعليق والإغلاق القسري.
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
    } on PlatformException catch (e, st) {
      debugPrint('[SecureStorage] Platform exception occurred while reading secure token.');
      // لا نقوم إطلاقاً بمسح كافة مفاتيح SecureStorage عبر deleteAll() لحماية بيانات البصمة ومفاتيح المرور
      final isDefiniteKeyCorruption = e.code.contains('KEY_PERMANENTLY_INVALIDATED') ||
          (e.message != null && e.message!.contains('KeyPermanentlyInvalidatedException'));

      if (isDefiniteKeyCorruption) {
        try {
          await _storage.delete(key: LocalStorageKeys.authToken);
        } catch (_) {}
      }

      // نعيد رمي الخطأ مع الـ StackTrace كـ CacheException حتى تدرك الطبقات العليا وجود عطل منصة مؤقت
      Error.throwWithStackTrace(
        const CacheException(message: 'تعذر الوصول إلى التخزين الآمن.'),
        st,
      );
    } catch (e, st) {
      if (e is CacheException) {
        rethrow;
      }
      debugPrint('[SecureStorage] Unexpected error occurred while reading secure token.');
      Error.throwWithStackTrace(
        const CacheException(message: 'خطأ غير متوقع أثناء قراءة التوكن.'),
        st,
      );
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
    } catch (_) {
      debugPrint('[SecureStorage] Fallback check on SharedPreferences failed.');
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
    } catch (_, st) {
      debugPrint('[SecureStorage] Failed to write auth token.');
      Error.throwWithStackTrace(
        const CacheException(message: 'تعذر حفظ بيانات الجلسة بشكل آمن.'),
        st,
      );
    }

    // حفظ علامة وجود جلسة سريعة في SharedPreferences لتفادي قفل الواجهة عند الإقلاع
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_auth_session', true);
      if (prefs.containsKey(LocalStorageKeys.authToken)) {
        await prefs.remove(LocalStorageKeys.authToken);
      }
    } catch (_) {}
  }

  @override
  Future<void> clearToken() async {
    try {
      await _storage.delete(key: LocalStorageKeys.authToken);
    } catch (_, st) {
      debugPrint('[SecureStorage] Failed to delete auth token.');
      Error.throwWithStackTrace(
        const CacheException(
          message: 'تعذر حذف بيانات الجلسة بشكل آمن.',
        ),
        st,
      );
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('has_auth_session');
      await prefs.remove(LocalStorageKeys.authToken);
    } catch (_) {}
  }
}
