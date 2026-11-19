/// نقاط نهاية المفضلة في واجهة البرمجة (Laravel REST API)
class WishlistEndpoints {
  WishlistEndpoints._();

  /// جلب عناصر المفضلة للعميل المصادق أو الزائر
  /// - الطريقة: **GET**
  /// - المسار: `/api/v1/customer/wishlist`
  static const String wishlist = '/api/v1/customer/wishlist';

  /// جلب معرفات عناصر المفضلة فقط بشكل خفيف وسريع
  /// - الطريقة: **GET**
  /// - المسار: `/api/v1/customer/wishlist/ids`
  static const String ids = '/api/v1/customer/wishlist/ids';

  /// إضافة أو إزالة منتج من المفضلة (تبديل الحالة)
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/wishlist/toggle`
  static const String toggle = '/api/v1/customer/wishlist/toggle';

  /// إضافة منتج إلى المفضلة صراحةً
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/wishlist`
  static const String store = '/api/v1/customer/wishlist';

  /// إزالة منتج من المفضلة صراحةً
  /// - الطريقة: **DELETE**
  /// - المسار: `/api/v1/customer/wishlist/{productId}`
  static String delete(String productId) => '/api/v1/customer/wishlist/$productId';

  /// مزامنة عناصر المفضلة المنشأة كزائر مع حساب المستخدم عند تسجيل الدخول
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/wishlist/sync`
  static const String sync = '/api/v1/customer/wishlist/sync';
}
