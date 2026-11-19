import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// واجهة مستودع المفضلة النقية [IWishlistRepository]
abstract class IWishlistRepository {
  /// جلب قائمة المنتجات المضافة للمفضلة من السيرفر
  Future<List<HomeProductItem>> getWishlist();

  /// جلب قائمة معرفات المنتجات المفضلة فقط بشكل خفيف وسريع (< 50 بايت)
  Future<List<String>> getWishlistIds();

  /// تبديل حالة المفضلة (إضافة / حذف) وإرجاع الحالة الجديدة (true: مفضلة، false: محذوفة)
  Future<bool> toggleWishlist(String productId);

  /// إضافة منتج إلى المفضلة في السيرفر
  Future<void> addToWishlist(String productId);

  /// إزالة منتج من المفضلة في السيرفر
  Future<void> removeFromWishlist(String productId);

  /// مزامنة عناصر المفضلة المحلية مع خادم Laravel عند تسجيل الدخول
  Future<List<HomeProductItem>> syncWishlist(List<String> productIds);
}
