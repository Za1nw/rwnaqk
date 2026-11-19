import 'package:shared_preferences/shared_preferences.dart';

/// مخزن محلي خفيف لحفظ عدد ومعرفات عناصر المفضلة في ذاكرة التطبيق لتجنب طلبات الشبكة الثقيلة عند بدء التشغيل
class WishlistLocalCache {
  WishlistLocalCache._();

  static const String _countKey = 'cached_wishlist_count';
  static const String _idsKey = 'cached_wishlist_ids';

  /// قراءة متزامنة فورية للمعرفات من SharedPreferences المحمل مسبقاً في الذاكرة
  static Set<String> getCachedIdsSync(SharedPreferences? prefs) {
    if (prefs == null) return const {};
    try {
      final list = prefs.getStringList(_idsKey);
      return list != null ? list.toSet() : const {};
    } catch (_) {
      return const {};
    }
  }

  /// قراءة متزامنة فورية للعدد من SharedPreferences
  static int getCachedCountSync(SharedPreferences? prefs) {
    if (prefs == null) return 0;
    try {
      final ids = prefs.getStringList(_idsKey);
      if (ids != null && ids.isNotEmpty) return ids.length;
      return prefs.getInt(_countKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// استرجاع معرفات المفضلة المحفوظة محلياً بشكل غير متزامن
  static Future<Set<String>> getCachedIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_idsKey);
      return list != null ? list.toSet() : const {};
    } catch (_) {
      return const {};
    }
  }

  /// استرجاع العدد المحفوظ محلياً في التطبيق
  static Future<int> getCachedCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_idsKey);
      if (ids != null && ids.isNotEmpty) return ids.length;
      return prefs.getInt(_countKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// تحديث وحفظ قائمة معرفات المفضلة والعدد محلياً
  static Future<void> saveFavoriteIds(Iterable<String> ids) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = ids.toList();
      await prefs.setStringList(_idsKey, list);
      await prefs.setInt(_countKey, list.length);
    } catch (_) {}
  }

  /// تحديث وحفظ عدد المفضلة في الذاكرة المحلية
  static Future<void> saveCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_countKey, count < 0 ? 0 : count);
    } catch (_) {}
  }

  /// مسح البيانات المحفوظة محلياً
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_countKey);
      await prefs.remove(_idsKey);
    } catch (_) {}
  }
}
