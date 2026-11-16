/// نقاط نهاية إتمام الشراء ورفع إيصالات التحويل البنكي [CheckoutEndpoints]
class CheckoutEndpoints {
  CheckoutEndpoints._();

  /// رفع صورة إشعار أو إيصال التحويل المالي مؤقتاً لربطها بالطلب
  /// 
  /// - الطريقة: **POST** (Multipart / Form-Data)
  /// - المسار: `/api/temporary-images`
  /// - الحقل: `image` (ملف صورة الإشعار بصيغة jpg/png)
  /// - الاستجابة: رابط الصورة المؤقتة أو المعرف للربط مع الطلب
  static const String temporaryImages = '/api/temporary-images';
}
