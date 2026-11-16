/// نقاط نهاية عامة مشتركة للنظام وغير مرتبطة بموديول محدد [ApiEndpoints]
class ApiEndpoints {
  ApiEndpoints._();

  /// رفع الصور والملفات المؤقتة العامة للنظام
  /// 
  /// - الطريقة: **POST** (Multipart / Form-Data)
  /// - المسار: `/api/temporary-images`
  static const String temporaryImages = '/api/temporary-images';
}
