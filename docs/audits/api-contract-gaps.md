# فحص عقود واجهة برمجة التطبيقات وفجوات الربط (API Contract Gaps)

**المرجع الفعلي:** الفحص الميداني لكود الواجهة الخلفية في `../rwnaqk-backend/` ومقارنته بمتطلبات الواجهة الأمامية `rwnaqk_frontend`.

---

## 1. ملخص الوضع الراهن للـ Backend

كشف الفحص الميداني لمجلد `Modules/` في كود Laravel المرفق عن الواقع التالي:
* **نظام الوحدات المستقلة:** يستخدم الباك إند حزمة `nwidart/laravel-modules`.
* **وحدات المصادقة والعناوين الجغرافية (جاهزة ومكتملة):**
  - مسارات المصادقة للعملاء مكتملة ومفعلة تحت بادئة `/api/v1/customer/auth/*`.
  - مسارات الجغرافيا مكتملة تحت بادئة `/api/v1/geo/*`.
* **وحدات التجارة والكتالوج والطلبات (تتطلب فتح مسارات API موجهة للعملاء):**
  - الكنترولرات الخاصة بالمنتجات والطلبات والتصنيفات موجودة بالكامل في الباك إند (`ProductController`, `OrderController`, `CustomerAddressController`)، ولكنها حالياً مربوطة بمسارات لوحة الإدارة (`admin/hidden/`) وجلسات المتصفح (`web.php`).
  - **المطلوب فوراً من فريق الباك إند:** تصدير نسخ API مخصصة للعميل النهائي تحت مسارات `/api/v1/*` محمية بـ `auth:sanctum` أو مفتوحة للمتصفحين، وسنوضح عقودها الدقيقة أدناه.

---

## 2. مصفوفة العقود المؤكدة والناقصة (API Contracts Matrix)

### 2.1. العقود المؤكدة والجاهزة للربط الفوري (Confirmed Endpoints)

| المسار (Endpoint) | الطريقة (Method) | الحماية (Auth) | الوظيفة في التطبيق | حالة التوافق مع Flutter Model |
|---|---|---|---|---|
| `/api/v1/customer/auth/login` | `POST` | Guest | تسجيل الدخول بالبريد وكلمة المرور | **متوافق 100%** مع `CustomerModel` |
| `/api/v1/customer/auth/register` | `POST` | Guest | إنشاء حساب عميل جديد | **متوافق 100%** |
| `/api/v1/customer/auth/me` | `GET` | Sanctum | جلب الملف الشخصي والتحقق من الجلسة | **متوافق 100%** |
| `/api/v1/customer/auth/logout` | `POST` | Sanctum | إنهاء الجلسة وإبطال التوكن | **متوافق 100%** |
| `/api/v1/customer/auth/forgot-password` | `POST` | Guest | إرسال رابط استعادة كلمة المرور | **متوافق** |
| `/api/v1/customer/auth/reset-password` | `POST` | Guest | إعادة تعيين كلمة المرور | **متوافق** |
| `/api/v1/customer/auth/email/verification-code` | `POST` | Sanctum | إرسال كود التحقق من البريد | **متوافق** |
| `/api/v1/customer/auth/email/verify-code` | `POST` | Sanctum | تأكيد كود البريد وتفعيل الحساب | **متوافق** |
| `/api/v1/geo/countries` | `GET` | Public | قائمة الدول المتاحة للشحن | **متوافق** مع `GeoLookupItem` |
| `/api/v1/geo/governorates` | `GET` | Public | المحافظات حسب الدولة | **متوافق** |
| `/api/v1/geo/yemen/governorates` | `GET` | Public | محافظات اليمن ومدنها الرئيسية | **متوافق** |

---

### 2.2. العقود الناقصة المطلوب تجهيزها في Laravel (Missing Customer Endpoints)

#### أ. الكتالوج والمنتجات (Catalog & Products)
1. **قائمة المنتجات مع الفلترة والترتيب والصفحات:**
   * **المسار المقترح:** `GET /api/v1/products`
   * **معاملات الاستعلام (Query Params):**
     - `page`: رقم الصفحة (افتراضي 1).
     - `per_page`: عدد العناصر (افتراضي 15).
     - `category_id`: معرف القسم (اختياري).
     - `search`: كلمة البحث (اختياري).
     - `sort`: خيارات الترتيب (`newest`, `price_low`, `price_high`, `popular`).
     - `min_price`, `max_price`: نطاق السعر (اختياري).
   * **شكل الاستجابة المتوقع (Pagination Response):**
     ```json
     {
       "success": true,
       "data": [
         {
           "id": 101,
           "title": "فستان مخملي فاخر",
           "description": "وصف تفصيلي للمنتج",
           "price": 18000.0,
           "discount_percent": 15,
           "sale_price": 15300.0,
           "image_url": "https://storage.rwnaqk.com/products/p101.jpg",
           "images": ["https://.../img1.jpg", "https://.../img2.jpg"],
           "brand": "رونقك بريميوم",
           "sku": "RNQ-101",
           "stock": 14,
           "is_in_stock": true,
           "rating": 4.8,
           "reviews_count": 12
         }
       ],
       "meta": {
         "current_page": 1,
         "last_page": 5,
         "per_page": 15,
         "total": 65
       }
     }
     ```

2. **تفاصيل المنتج والخيارات المتاحة (Product Details & Variants):**
   * **المسار المقترح:** `GET /api/v1/products/{id}`
   * **المتطلب الأساسي:** إعادة قائمة الخيارات والمتغيرات (`color`, `size`, `style`) مع المخزون المتاح لكل متغير وسعرها المحدد.

---

#### ب. السلة وحساب عرض السعر السحابي (Server-Side Cart Quote)
* **المسار المقترح:** `POST /api/v1/cart/quote`
* **الحماية:** اختياري (يدعم الزوار والمسجلين).
* **بيانات الطلب (Request Payload):**
  ```json
  {
    "items": [
      { "product_id": 101, "variant_id": 402, "quantity": 2 },
      { "product_id": 105, "variant_id": null, "quantity": 1 }
    ],
    "coupon_code": "RWNAQK",
    "shipping_zone_id": 1
  }
  ```
* **استجابة الخادم الملزمة (Authoritative Quote Response):**
  ```json
  {
    "success": true,
    "data": {
      "items_subtotal": 35000.0,
      "discount_amount": 5250.0,
      "coupon_applied": true,
      "coupon_message": "تم تطبيق خصم 15%",
      "shipping_fee": 1500.0,
      "shipping_title": "توصيل قياسي",
      "tax_amount": 0.0,
      "final_total": 31250.0,
      "out_of_stock_items": []
    }
  }
  ```

---

#### ج. إنشاء وتأكيد الطلب (Order Creation & Idempotency)
* **المسار المقترح:** `POST /api/v1/orders`
* **الحماية:** `auth:sanctum`
* **الرؤوس الإلزامية (Mandatory Headers):**
  - `Authorization: Bearer <token>`
  - `X-Idempotency-Key: <UUID>` *(لمنع تكرار إنشاء الفاتورة)*
* **نوع المحتوى (Content-Type):** `multipart/form-data` (لإمكانية إرفاق صورة سند التحويل إن وجد).
* **الحقول المطلوبة (Form Fields):**
  - `items`: JSON سلسلة لعناصر الطلب والكميات.
  - `shipping_address_id`: معرف العنوان المسجل (أو بيانات العنوان الجديد).
  - `shipping_method_id`: معرّف طريقة الشحن المختارة.
  - `payment_method`: نوع الدفع (`cod` أو `wallet`).
  - `wallet_account_id`: معرّف الحساب المحول إليه (في حال كان الدفع بالمحفظة).
  - `receipt_image`: ملف صورة السند (File).
  - `order_notes`: ملاحظات العميل للمندوب (اختياري).
* **الاستجابة الناجحة:**
  ```json
  {
    "success": true,
    "message": "تم تأكيد طلبك بنجاح",
    "data": {
      "order_id": "ORD-10255",
      "status": "pending",
      "created_at": "2026-11-08T15:30:00Z",
      "total": 31250.0,
      "items_count": 3,
      "payment_status": "pending_verification"
    }
  }
  ```

---

#### د. دفتر عناوين العميل (Customer Addresses API)
* تتوفر منطق العناوين بالفعل في `CustomerAddressController.php` داخل الباك إند، والمطلوب ربطه بالمسارات:
  - `GET /api/v1/customer/addresses` (قائمة العناوين).
  - `POST /api/v1/customer/addresses` (إضافة عنوان جديد).
  - `PUT /api/v1/customer/addresses/{id}` (تعديل عنوان).
  - `DELETE /api/v1/customer/addresses/{id}` (حذف عنوان).
  - `PATCH /api/v1/customer/addresses/{id}/primary` (تحديد العنوان كافتراضي).

---

## 3. توافق أنواع البيانات وقواعد الأخطاء (Data Types & Error Contracts)

### 3.1. توافق المعرفات والأسعار
* **المعرفات (IDs):** في الباك إند تكون أرقاماً صحيحة `int` (Auto Increment)، وفي واجهة Flutter الحالية بعض النماذج تتعامل معها كـ `String` (مثل `ORD-10241` أو `'101'`).
  - **الحل:** اعتماد محول آمن في `fromJson`: `id: json['id'].toString()`.
* **الأسعار والعملات:** يتم تمثيلها كـ `double` أو `num` في Flutter مع التقريب لخانة عشرية واحدة أو اثنتين (`.toStringAsFixed(2)`). يجب ألا يرسل الخادم قيم نصية مدمجة برمز العملة (مثل `"15000 YER"` بل `15000.0`).

### 3.2. معيار أخطاء التحقق (Validation Errors 422)
* يعتمد Laravel النمط المعياري:
  ```json
  {
    "message": "The given data was invalid.",
    "errors": {
      "email": ["البريد الإلكتروني مستخدم مسبقاً."],
      "mobile": ["رقم الهاتف غير صالح."]
    }
  }
  ```
* يدعم كود Flutter الحالي في [exceptions.dart](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/core/errors/exceptions.dart) استخراج خريطة `validationErrors` وعرض التنبيه الدقيق للمستخدم، وهو مطابق 100%.

---

## 4. أسئلة حاسمة للتنسيق مع فريق الـ Backend

1. **طريقة تسعير الشحن:** هل يتم احتساب تكلفة الشحن كقيمة ثابتة حسب المحافظة/المنطقة، أم عبر معادلة وزن وحجم؟
2. **سندات الدفع بالمحافظ:** ما هي أنواع الملفات والحد الأقصى لحجم صورة السند المقبول على الخادم؟ (يُقترح `jpeg, png, pdf` بحد أقصى `5MB`).
3. **دعم Idempotency:** هل تم تثبيت حزمة أو Middleware مخصص لمعالجة `X-Idempotency-Key` وحفظ الاستجابة في كاش Redis/Database؟ (سنوفر كود الـ Middleware الجاهز لفريق الباك إند في خطة التنفيذ).

