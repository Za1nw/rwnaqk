import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// مخزن آمن لرمز الزائر المخصص للمفضلة والعمليات غير المصادقة
class GuestTokenStorage {
  GuestTokenStorage._();

  static const String _key = 'guest_wishlist_token';
  static String? _cached;

  /// جلب رمز الزائر الفريد أو إنشائه وحفظه في حال لم يكن موجوداً
  static Future<String> getGuestToken() async {
    if (_cached != null && _cached!.isNotEmpty) {
      return _cached!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString(_key);
      if (token == null || token.isEmpty) {
        token = const Uuid().v4();
        await prefs.setString(_key, token);
      }
      _cached = token;
      return token;
    } catch (_) {
      return _cached ??= const Uuid().v4();
    }
  }

  /// مسح رمز الزائر المخزن (عند تسجيل الدخول أو الرغبة في إعادة التعيين)
  static Future<void> clearGuestToken() async {
    _cached = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
