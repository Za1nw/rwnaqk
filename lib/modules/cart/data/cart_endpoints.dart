/// نقاط نهاية حساب تسعيرة السلة والكوبونات والخصومات [CartEndpoints]
class CartEndpoints {
  CartEndpoints._();

  /// حساب التسعيرة السيرفرية الدقيقة للسلة (Server-side Quote)
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/cart/quote`
  /// - الوصف: حساب مجاميع السلة المعتمدة من الخادم وتشمل أسعار المنتجات المحدثة،
  ///   الضرائب، تكلفة الشحن، والخصومات المطبقة.
  /// - جسم الطلب (Body):
  ///   - `items`: مصفوفة عناصر السلة مع `product_id`, `variation_id`, `quantity`
  ///   - `coupon_code`: كود الخصم (اختياري)
  ///   - `shipping_address_id`: معرف عنوان الشحن المحدد لحساب التكلفة
  ///   - `shipping_method`: طريقة التوصيل (`standard`, `express`)
  static const String cartQuote = '/api/v1/customer/cart/quote';

  /// فحص وصلاحية كود قسيمة الشراء / الكوبون
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/cart/validate-coupon`
  /// - جسم الطلب (Body):
  ///   - `code`: كود الكوبون
  ///   - `subtotal`: إجمالي قيمة المنتجات
  ///   - `items`: عناصر السلة للتحقق من شمولها في الكوبون
  static const String validateCoupon = '/api/v1/customer/cart/validate-coupon';
}
