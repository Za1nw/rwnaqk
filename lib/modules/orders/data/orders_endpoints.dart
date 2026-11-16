/// نقاط نهاية إدارة طلبات العميل وعمليات الشراء [OrdersEndpoints]
class OrdersEndpoints {
  OrdersEndpoints._();

  /// قائمة طلبات العميل المنفذة أو إنشاء طلب جديد
  /// 
  /// - الطريقة: **GET** (جلب سجل الطلبات) | **POST** (إنشاء وتأكيد طلب شراء جديد)
  /// - المسار: `/api/v1/customer/orders`
  /// - المعاملات المدعومة (GET Query):
  ///   - `status`: تصفية حسب حالة الطلب (`pending`, `processing`, `delivered`, `cancelled`)
  ///   - `page`: رقم الصفحة
  ///   - `limit`: عدد الطلبات في الصفحة
  /// - جسم الطلب (POST Body):
  ///   - `items`: عناصر الطلب والكميات والخيارات المحددة
  ///   - `shipping_address_id`: معرف عنوان التوصيل
  ///   - `payment_method`: طريقة الدفع (`cod`, `card`, `kuraimi`, `jawwal`, إلخ)
  ///   - `shipping_method`: نوع التوصيل (`standard`, `express`)
  ///   - `coupon_code`: كود الخصم إن وجد
  ///   - `notes`: ملاحظات التوصيل الإضافية
  static const String orders = '/api/v1/customer/orders';

  /// جلب تفاصيل طلب محدد برقم المعرف
  /// 
  /// - الطريقة: **GET**
  /// - المسار: `/api/v1/customer/orders/{id}`
  /// - المعاملات:
  ///   - `id`: المعرف الرقمي للطلب أو كود الطلب
  /// - الاستجابة: بيانات الطلب الكاملة، تتبع الشحنة، قائمة المنتجات، والفاتورة المالية
  static String orderDetails(String id) => '/api/v1/customer/orders/$id';

  /// إلغاء الطلب من قبل العميل قبل البدء بتجهيزه وشحنه
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/orders/{id}/cancel`
  /// - المعاملات:
  ///   - `id`: معرف الطلب المراد إلغاؤه
  /// - جسم الطلب (Body):
  ///   - `reason`: سبب الإلغاء (اختياري)
  static String cancelOrder(String id) => '/api/v1/customer/orders/$id/cancel';
}
