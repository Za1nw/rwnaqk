/// نقاط نهاية واجهات المنتجات والكتالوج والأقسام والعلامات التجارية [CatalogEndpoints]
class CatalogEndpoints {
  CatalogEndpoints._();

  /// قائمة المنتجات العامة والبحث والفلترة
  /// 
  /// - الطريقة: **GET**
  /// - المسار: `/api/v1/products`
  /// - المعاملات المدعومة (Query Parameters):
  ///   - `search`: كلمة البحث في الاسم والوصف والموديل
  ///   - `category_id`: معرف القسم المختار
  ///   - `brand_id`: معرف العلامة التجارية
  ///   - `is_featured`: تصفية المنتجات المميزة (true/false)
  ///   - `min_price`: الحد الأدنى للسعر
  ///   - `max_price`: الحد الأقصى للسعر
  ///   - `sort`: خيارات الترتيب (`newest`, `priceLowToHigh`, `priceHighToLow`, `popular`)
  ///   - `page`: رقم الصفحة
  ///   - `limit` أو `per_page`: عدد العناصر في الصفحة الواحدة
  static const String products = '/api/v1/products';

  /// تفاصيل منتج محدد مع كافة خياراته وتوليفاته ومعرض صوره
  /// 
  /// - الطريقة: **GET**
  /// - المسار: `/api/v1/products/{id}`
  /// - المعاملات:
  ///   - `id`: المعرف الرقمي أو النصي للمنتج
  /// - الاستجابة: بيانات المنتج الكاملة مع `variations` و `attribute_groups` ومخزون كل خيار
  static String productDetails(String id) => '/api/v1/products/$id';

  /// مراجعات وتقييمات منتج محدد أو إضافة مراجعة جديدة
  /// 
  /// - الطريقة: **GET** (لجلب المراجعات) | **POST** (لإرسال مراجعة جديدة)
  /// - المسار: `/api/v1/products/{id}/reviews`
  /// - المعاملات:
  ///   - `id`: معرف المنتج
  /// - جسم الطلب (POST):
  ///   - `rating`: التقييم من 1 إلى 5
  ///   - `comment`: نص المراجعة أو التعليق
  static String productReviews(String id) => '/api/v1/products/$id/reviews';

  /// قائمة الأقسام والتصنيفات للمتجر
  /// 
  /// - الطريقة: **GET**
  /// - المسار: `/api/v1/categories`
  /// - المعاملات المدعومة (Query Parameters):
  ///   - `is_featured`: الأقسام المميزة فقط
  ///   - `is_top`: الأقسام الرئيسية في أعلى المتجر
  ///   - `parent_id`: معرف القسم الأب (أو null للأقسام الجذرية)
  ///   - `tree`: جلب شجرة التصنيفات الكاملة مع أبنائها
  static const String categories = '/api/v1/categories';

  /// قائمة العلامات التجارية والماركات المتاحة
  /// 
  /// - الطريقة: **GET**
  /// - المسار: `/api/v1/brands`
  /// - المعاملات المدعومة (Query Parameters):
  ///   - `is_featured`: الماركات المميزة فقط
  ///   - `search`: بحث في أسماء الماركات
  static const String brands = '/api/v1/brands';
}
