import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_service.dart';

/// إدارة التخزين المؤقت المحلي (Local Storage) لبيانات الشاشة الرئيسية و ETag
class HomeLocalCache {
  static const String keyEtag = 'home_bootstrap_etag';
  static const String keyPayload = 'home_bootstrap_payload';
  static const String keyTimestamp = 'home_bootstrap_timestamp';

  final SharedPreferences? _prefs;

  HomeLocalCache([this._prefs]);

  Future<SharedPreferences?> _getPrefs() async {
    if (_prefs != null) return _prefs;
    try {
      return await SharedPreferences.getInstance();
    } catch (_) {
      return null;
    }
  }

  /// جلب الـ ETag المحفوظ محلياً
  Future<String?> getEtag() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return null;
      final etag = prefs.getString(keyEtag);
      return (etag != null && etag.trim().isNotEmpty) ? etag : null;
    } catch (e) {
      debugPrint('[HomeLocalCache] Error reading ETag: $e');
      return null;
    }
  }

  /// جلب حمولة البيانات المخزنة محلياً مع فحص الصلاحية
  Future<HomeBootstrapPayload?> getCachedPayload({
    Duration maxAge = const Duration(days: 7),
  }) async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return null;
      final jsonStr = prefs.getString(keyPayload);
      final timestamp = prefs.getInt(keyTimestamp);

      if (jsonStr == null || jsonStr.trim().isEmpty) {
        return null;
      }

      // التحقق من سياسة صلاحية الكاش المحلي (الافتراضي 7 أيام كأقصى حد لحماية البيانات)
      if (timestamp != null) {
        final age = DateTime.now().millisecondsSinceEpoch - timestamp;
        if (age > maxAge.inMilliseconds) {
          debugPrint('[HomeLocalCache] Cached payload expired (${age ~/ 1000}s old).');
          return null;
        }
      }

      final dynamic decoded = jsonDecode(jsonStr);
      if (decoded is Map<String, dynamic>) {
        return HomeBootstrapPayload.fromJson(decoded);
      }
    } catch (e) {
      debugPrint('[HomeLocalCache] Error reading cached payload: $e');
    }
    return null;
  }

  /// حفظ البيانات والـ ETag محلياً عند استلام 200 OK من الخادم
  Future<void> saveBootstrap({
    required String? etag,
    required Map<String, dynamic> rawData,
  }) async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;
      if (etag != null && etag.trim().isNotEmpty) {
        await prefs.setString(keyEtag, etag);
      } else {
        await prefs.remove(keyEtag);
      }
      await prefs.setString(keyPayload, jsonEncode(rawData));
      await prefs.setInt(keyTimestamp, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('[HomeLocalCache] Error saving bootstrap: $e');
    }
  }

  /// مسح الكاش المحلي للشاشة الرئيسية
  Future<void> clear() async {
    try {
      final prefs = await _getPrefs();
      if (prefs == null) return;
      await prefs.remove(keyEtag);
      await prefs.remove(keyPayload);
      await prefs.remove(keyTimestamp);
    } catch (e) {
      debugPrint('[HomeLocalCache] Error clearing cache: $e');
    }
  }
}
