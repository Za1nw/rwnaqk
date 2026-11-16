/// نقاط نهاية بيانات العميل وعناوين التوصيل [CustomerEndpoints]
class CustomerEndpoints {
  CustomerEndpoints._();

  /// جلب أو تحديث بيانات الملف الشخصي للعميل
  /// 
  /// - الطريقة: **GET** (جلب البيانات) | **PUT** / **POST** (تحديث البيانات)
  /// - المسار: `/api/v1/customer/auth/profile`
  /// - جسم الطلب (PUT/POST Body):
  ///   - `name`: اسم العميل
  ///   - `email`: البريد الإلكتروني
  ///   - `phone`: رقم الهاتف
  ///   - `gender`: الجنس (`male`, `female`)
  ///   - `avatar`: صورة الملف الشخصي
  static const String profile = '/api/v1/customer/auth/profile';

  /// قائمة عناوين التوصيل للعميل أو إضافة عنوان جديد
  /// 
  /// - الطريقة: **GET** (جلب العناوين) | **POST** (إضافة عنوان توصيل جديد)
  /// - المسار: `/api/v1/customer/addresses`
  /// - جسم الطلب (POST Body):
  ///   - `label`: تسمية العنوان (`المنزل`, `العمل`, إلخ)
  ///   - `recipient_name`: اسم المستلم
  ///   - `phone`: رقم هاتف المستلم
  ///   - `city`: المدينة / المحافظة
  ///   - `district`: المديرية أو الحي
  ///   - `street`: الشارع والمعالم القريبة
  ///   - `latitude`, `longitude`: إحداثيات الخريطة (اختياري)
  ///   - `is_primary`: تعيين كعنوان افتراضي رئيسي
  static const String addresses = '/api/v1/customer/addresses';

  /// تفاصيل أو تعديل أو حذف عنوان توصيل محدد
  /// 
  /// - الطريقة: **GET** (تفاصيل) | **PUT** (تعديل) | **DELETE** (حذف العنوان)
  /// - المسار: `/api/v1/customer/addresses/{id}`
  /// - المعاملات:
  ///   - `id`: معرف العنوان
  static String addressDetails(String id) => '/api/v1/customer/addresses/$id';

  /// تعيين عنوان التوصيل كعنوان رئيسي افتراضي للطلبات
  /// 
  /// - الطريقة: **POST**
  /// - المسار: `/api/v1/customer/addresses/{id}/primary`
  /// - المعاملات:
  ///   - `id`: معرف العنوان المراد اعتماده كافتراضي
  static String addressPrimary(String id) =>
      '/api/v1/customer/addresses/$id/primary';
}
