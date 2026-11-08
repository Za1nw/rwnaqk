# Flutter & Laravel API Contract Matrix

**المشروع:** متجر رونقك (Rwnaqk Store)  
**المرحلة:** Phase 4.1 — مطابقة العقود البرمجية وتكامل Flutter مع Laravel  
**الملفات المفحوصة في Flutter:**
- `lib/core/network/api_endpoints.dart`
- `lib/core/network/api_client.dart`
- `lib/modules/auth/data/repositories/auth_repository.dart` & `auth_repository_impl.dart`
- `lib/modules/catalog/data/repositories/products_repository.dart` & `products_repository_impl.dart`
- `lib/modules/orders/data/repositories/orders_repository.dart` & `orders_repository_impl.dart`
- `lib/modules/customer/controllers/addresses_service.dart` & `shipping_address.dart`
- `lib/modules/checkout/controllers/payment_controller.dart`

---

## 1. جدول مطابقة نقاط النهاية (Endpoints Matrix)

| Endpoint في Flutter | Method | وجوده في Laravel | مسار Laravel الحالي | نوع المصادقة | حالة المطابقة والجاهزية |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`/api/v1/customer/auth/register`** | `POST` | **موجود** | `api/v1/customer/auth/register` | Public | **متطابق بنسبة 100%** مع FormRequest |
| **`/api/v1/customer/auth/login`** | `POST` | **موجود** | `api/v1/customer/auth/login` | Public | **متطابق بنسبة 100%** مع دعم 2FA و Token |
| **`/api/v1/customer/auth/me`** | `GET` | **موجود** | `api/v1/customer/auth/me` | Sanctum (Customer) | **متطابق بنسبة 100%** عبر `CustomerResource` |
| **`/api/v1/customer/auth/logout`** | `POST` | **موجود** | `api/v1/customer/auth/logout` | Sanctum (Customer) | **متطابق بنسبة 100%** مع حذف التوكن |
| **`/api/v1/customer/auth/forgot-password`** | `POST` | **موجود** | `api/v1/customer/auth/forgot-password` | Public | **متطابق** مع خط فورتيفاي للعملاء |
| **`/api/v1/customer/auth/reset-password`** | `POST` | **موجود** | `api/v1/customer/auth/reset-password` | Public | **متطابق** |
| **`/api/v1/customer/auth/email/verification-code`**| `POST` | **موجود** | `.../email/verification-code` | Sanctum (Customer) | **متطابق** (إرسال رمز من 6 أرقام) |
| **`/api/v1/customer/auth/email/verify-code`** | `POST` | **موجود** | `.../email/verify-code` | Sanctum (Customer) | **متطابق** |
| **`/api/v1/temporary-images`** | `POST` | **موجود** | `api/v1/temporary-images` | Public / Api | **متطابق** لرفع سند التحويل المالي |
| **`/api/v1/products`** | `GET` | **غير موجود كـ API** | مسجل فقط كـ `web` إداري | Public المطلوب | **مفقود مسار API** (المنطق موجود في `ListProductsAction`) |
| **`/api/v1/products/{id}`** | `GET` | **غير موجود كـ API** | مسجل فقط كـ `web` إداري | Public المطلوب | **مفقود مسار API** (المنطق موجود في `ProductShowResource`) |
| **`/api/v1/products/{id}/reviews`** | `GET` | **غير موجود** | غير معرّف كمسار | Public المطلوب | **مفقود بالكامل** (جدول `product_reviews` موجود) |
| **`/api/v1/categories`** | `GET` | **غير موجود كـ API** | مسجل فقط كـ `web` إداري | Public المطلوب | **مفقود مسار API** (المنطق موجود في `CategoryCollection`) |
| **`/api/v1/brands`** | `GET` | **غير موجود كـ API** | مسجل فقط كـ `web` إداري | Public المطلوب | **مفقود مسار API** (المنطق موجود في `BrandCollection`) |
| **`/api/v1/customer/cart/quote`** | `POST` | **غير موجود كـ API** | متاح فقط كخدمة داخلية | Sanctum (Customer) | **مفقود مسار API** (`OrderQuoteService` موجود) |
| **`/api/v1/customer/cart/validate-coupon`** | `POST` | **غير موجود** | مدمج داخل كود الطلب | Sanctum (Customer) | **مفقود كـ Endpoint مستقل** |
| **`/api/v1/customer/orders`** (List) | `GET` | **غير موجود كـ API** | مسجل فقط كـ `web` إداري | Sanctum (Customer) | **مفقود مسار API للعميل** (يوجد فقط للأدمن) |
| **`/api/v1/customer/orders/{id}`** (Details) | `GET` | **غير موجود كـ API** | مسجل فقط كـ `web` إداري | Sanctum (Customer) | **مفقود مسار API للعميل** |
| **`/api/v1/customer/orders`** (Create) | `POST` | **غير موجود كـ API** | مسجل فقط كـ `web` إداري | Sanctum (Customer) | **مفقود مسار API للعميل** (`OrdersAction@store` للأدمن) |
| **`/api/v1/customer/orders/{id}/cancel`** | `POST` | **غير موجود كـ API** | مسجل فقط كـ `web` إداري | Sanctum (Customer) | **مفقود مسار API للعميل** |
| **`/api/v1/customer/addresses`** (CRUD) | `ANY` | **غير موجود كـ API** | مسجل فقط كـ `web` إداري | Sanctum (Customer) | **مفقود مسار API للعميل** (`CustomerAddressController` للأدمن) |

---

## 2. التدقيق التفصيلي لكل عقد (Contract-by-Contract Deep Dive)

---

### عقد 1: تسجيل حساب عميل جديد (`POST /api/v1/customer/auth/register`)

- **وجود المسار:** موجود ومفعل في `Modules/Customer/routes/auth-api.php`.
- **المصادقة:** عامة (Public / Unauthenticated).
- **Request Payload:**
  ```json
  {
    "first_name": "أحمد",                  // Required | string | max:255
    "last_name": "المتوكل",                // Required | string | max:255
    "mobile": "777123456",                 // Required | string | max:30
    "email": "ahmed@example.com",          // Required | string | email | max:255 | unique:users,email
    "country": "اليمن",                    // Required | string | max:100
    "governorate": "تعز",                  // Required | string | max:100
    "password": "Password123!",            // Required | string | min:8 | confirmed
    "password_confirmation": "Password123!", // Required | string
    "terms_accepted": true,                // Required | accepted (1, true, "1")
    "privacy_policy_accepted": true,       // Required | accepted (1, true, "1")
    "device_name": "rwnaqk-mobile"         // Optional | string | max:255
  }
  ```
- **Response Payload (Status 201 Created):**
  ```json
  {
    "message": "Customer registered successfully.",
    "customer": {
      "id": 15,
      "full_name": "أحمد المتوكل",
      "first_name": "أحمد",
      "last_name": "المتوكل",
      "email": "ahmed@example.com",
      "mobile": "777123456",
      "gender": null,
      "avatar_url": null,
      "is_banned": false,
      "email_verified_at": null,
      "wallet_balance": 0.0,
      "created_at": "2026-11-08T15:30:00.000000Z"
    },
    "token": "1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
    "token_type": "Bearer",
    "requires_email_verification": false,
    "auth_stage": "authenticated"
  }
  ```
- **حالة التوافق مع Flutter:** تطابق كامل بين ما يرسله `AuthRepositoryImpl.register` ونموذج `CustomerModel.fromJson`.

---

### عقد 2: تسجيل الدخول (`POST /api/v1/customer/auth/login`)

- **وجود المسار:** موجود ومفعل.
- **Request Payload:**
  ```json
  {
    "email": "ahmed@example.com",      // Required | string | email
    "password": "Password123!",        // Required | string
    "code": "123456",                  // Optional | string | digits:6 (إذا كان 2FA مفعلاً)
    "recovery_code": "xxxxx-xxxxx",    // Optional | string (رمز استرداد للطوارئ)
    "device_name": "rwnaqk-mobile"     // Optional | string
  }
  ```
- **Response Payload (Status 200 OK):**
  ```json
  {
    "message": "Customer logged in successfully.",
    "customer": { /* كائن العميل كما في العقد 1 */ },
    "token": "2|yyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy",
    "token_type": "Bearer",
    "requires_email_verification": false,
    "auth_stage": "authenticated"
  }
  ```
- **استجابة التحقق الثنائي (Status 202 Accepted):**
  ```json
  {
    "message": "Two factor authentication code required.",
    "two_factor_required": true,
    "auth_stage": "two_factor_required",
    "challenge_methods": ["authenticator_code", "recovery_code"]
  }
  ```
- **حالة التوافق مع Flutter:** تطابق كامل؛ يتعامل `AuthRepositoryImpl.login` مع كود الحالة 202 وخاصية `two_factor_required`.

---

### عقد 3: بيانات الملف الشخصي للعميل (`GET /api/v1/customer/auth/me`)

- **وجود المسار:** موجود ومفعل.
- **المصادقة:** `Authorization: Bearer {token}` (Sanctum).
- **Response Payload (Status 200 OK):**
  ```json
  {
    "customer": {
      "id": 15,
      "full_name": "أحمد المتوكل",
      "first_name": "أحمد",
      "last_name": "المتوكل",
      "email": "ahmed@example.com",
      "mobile": "777123456",
      "gender": "male",
      "avatar_url": "https://.../avatar.jpg",
      "is_banned": false,
      "email_verified_at": "2026-11-08T15:35:00.000000Z",
      "wallet_balance": 15000.0
    }
  }
  ```
- **حالة التوافق مع Flutter:** `AuthRepositoryImpl.me` يقرأ `data['customer']` عبر `CustomerModel.fromJson`. متطابق 100%.

---

### عقد 4: جلب قائمة المنتجات (`GET /api/v1/products`)

- **وجود المسار في API:** **غير موجود كمسار API حالياً**. (متاح فقط كمسار ويب في لوحة التحكم الإدارية).
- **المصادقة المطلوبة في المتجر:** عامة (Public).
- **Query Parameters المتوقعة من Flutter:**
  - `page`: رقم الصفحة (افتراضي: 1).
  - `limit`: عدد العناصر في الصفحة (افتراضي: 10، ويطابق `per_page` في Laravel).
  - `sort`: خيار الترتيب (`newest`, `priceLowToHigh`, `priceHighToLow`, `rating`, `popular`).
  - `min_price`: تصفية الحد الأدنى للسعر.
  - `max_price`: تصفية الحد الأعلى للسعر.
  - `category_id`: تصفية حسب الصنف.
  - `brand_id`: تصفية حسب العلامة التجارية.
  - `search`: بحث بالاسم والوصف.
- **المنطق الموجود في Laravel:**
  - كلاس `ListProductsAction` جاهز تماماً في `Modules/Shop/Action/Product/ListProductsAction.php`.
  - كلاس التحويل `ProductResource` جاهز ويعيد:
    ```json
    {
      "id": 101,
      "name": "فستان سهرة كلاسيكي",
      "status": true,
      "is_featured": true,
      "has_variation": true,
      "stock_qty": 45,
      "min_price": "18000.00",
      "max_price": "22000.00",
      "feature_image": "https://.../img.jpg",
      "brand": { "id": 3, "name": "زارا" }
    }
    ```
- **التوافق مع Flutter `HomeProductItem.fromJson`:**
  - Flutter يدعم: `name` أو `title`، `feature_image` أو `imageUrl`، `min_price` أو `price`، `stock_qty`، `brand`.
  - **فجوة:** المسار يحتاج تسجيل في `Modules/Shop/routes/api.php` مع متحكم عام لا يطلب صلاحيات لوحة التحكم (`permission:view_products`) ويُرجع المنتجات المفعلة فقط (`status = 1`).

---

### عقد 5: تفاصيل المنتج مع السمات والمخزون (`GET /api/v1/products/{id}`)

- **وجود المسار في API:** **غير موجود كمسار API حالياً**.
- **المنطق الموجود في Laravel:**
  - كلاس `ProductShowResource` غني وشامل للغاية ويعيد:
    - البيانات الأساسية: الاسم، السلاج، الوصف، الوصف المختصر، ساعات التوصيل، نقاط المكافأة، دليل المقاسات (`size_guide`).
    - المعرض (`gallery`): مصفوفة الصور كاملة.
    - العلامة التجارية (`brand`)، الوحدة (`unit`)، التصنيفات (`categories`)، الوسوم (`tags`).
    - السمات والخيارات (`variations`): معرف الـ SKU، السعر، التركيبات (`combinations`: اللون، القيمة، المقاس)، والمخزون في المواقع (`stocks`: location_id, stock_qty).
- **التوافق مع Flutter:**
  - `HomeProductItem.fromJson` يستخرج `gallery` / `images`، والسمات `availableColors` و `availableSizes` ودليل المقاسات `sizeGuide`.
  - **فجوة:** توفير مسار `api/v1/products/{id}` بدون قيد على هوية العميل.

---

### عقد 6: عرض سعر السلة والتوصيل (`POST /api/v1/customer/cart/quote`)

- **وجود المسار في API:** **غير موجود كمسار API حالياً**.
- **المصادقة المطلوبة:** Sanctum (Customer).
- **المنطق الموجود في Laravel:**
  - خدمة `OrderQuoteService::quoteForAddress(Address $address)` تحسب المسافة بدقة، فحص نطاق الخدمة، واحتساب رسوم التوصيل وفق `GeoDeliveryPricingService`.
- **Request Payload المقترح:**
  ```json
  {
    "address_id": 12,                    // معرف عنوان العميل المحفوظ
    "items": [
      { "product_variation_id": 44, "qty": 2 }
    ],
    "coupon_code": "PROMO2026"          // اختياري
  }
  ```
- **Response Payload المتوقع:**
  ```json
  {
    "is_serviceable": true,
    "distance_km": 4.8,
    "delivery_fee": 1500.0,
    "subtotal": 36000.0,
    "discount_amount": 3600.0,
    "grand_total": 33900.0,
    "estimated_delivery_hours": 24,
    "eligible_logistics": [
      { "logistic_id": 1, "logistic_name": "توصيل رونقك السريع", "shipping_cost": 1500.0 }
    ]
  }
  ```

---

### عقد 7: إنشاء وتأكيد الطلب (`POST /api/v1/customer/orders`)

- **وجود المسار في API:** **غير موجود كمسار API حالياً**.
- **المصادقة:** Sanctum (Customer).
- **الهيدر الأمني الإلزامي المرسل من Flutter:**
  `X-Idempotency-Key: c9b8f2d1-91a0-4e3a-b83c-1d8f7e2c90a1` (UUID v4 لمنع التكرار).
- **Request Payload:**
  ```json
  {
    "address_id": 12,
    "logistic_id": 1,
    "payment_method": "cash_on_delivery", // أو "wallet"
    "wallet_account_id": "jib",            // إذا كانت طريقة الدفع محفظة
    "payment_receipt_url": "https://.../storage/temp/receipt_xxx.jpg", // رابط سند التحويل
    "notes": "يرجى الاتصال قبل الوصول",
    "coupon_code": "PROMO2026",
    "items": [
      {
        "product_variation_id": 44,
        "qty": 2
      }
    ]
  }
  ```
- **المنطق الموجود في Laravel:**
  - `OrdersAction@store` ينشئ `OrderGroup` و `Order` و `OrderItem` و `OrderUpdate`، ويربط الطلب تلقائياً بنظام التجميع والعناقيد `CentroidBatchingService`.
  - **فجوة:** يحتاج إلى نقطة نهاية خاصة بالعميل تستخرج العميل تلقائياً من الجلسة `$request->user()` وتتحقق من صحة توفر المخزون وتطبق فحص `X-Idempotency-Key`.

---

### عقد 8: رفع صورة سند التحويل البنكي (`POST /api/v1/temporary-images`)

- **وجود المسار في API:** **موجود ومفعل بالكامل** (`App\Http\Controllers\Api\TemporaryImageController@store`).
- **المصادقة:** Public / API.
- **Request Format:** `multipart/form-data`
  - Field: `image` (ملف صورة مسموح: jpg, jpeg, png, webp, gif, avif، حد أقصى: 5120 كيلوبايت).
- **Response Format (Status 201 Created):**
  ```json
  {
    "url": "http://127.0.0.1:8000/storage/temporary-images/xxxxx.jpg"
  }
  ```
- **حالة التوافق مع Flutter:** متوافق تماماً. يمكن لـ `PaymentController` رفع صورة السند عبر هذا المسار واستلام الرابط لإرفاقه بحمولة إنشاء الطلب.

---

### عقد 9: إدارة عناوين العميل (`api/v1/customer/addresses`)

- **وجود المسار في API:** مسجل حالياً فقط كمسار إداري للوحة التحكم تحت `admin/hidden/customers/{customer}/addresses`.
- **المطلوب لتطبيق Flutter:**
  - `GET /api/v1/customer/addresses`: جلب عناوين العميل الحالي.
  - `POST /api/v1/customer/addresses`: إضافة عنوان جديد (مع فحص التغطية الجغرافية عبر `GeoCoverageService`).
  - `PUT /api/v1/customer/addresses/{id}`: تعديل عنوان.
  - `DELETE /api/v1/customer/addresses/{id}`: حذف عنوان.
  - `PATCH /api/v1/customer/addresses/{id}/primary`: تعيين كعنوان افتراضي.
- **المنطق الموجود في Laravel:**
  - كلاس `CustomerAddressController` وكلاس `AddressResource` جاهزان ومصممان بدقة عالية، ويحتاجان فقط لنقلهما إلى مسارات API مخصصة للعميل المصادق عبر Sanctum.

---

## 3. معالجة الأخطاء وهيكل الاستجابة (Error Envelope & Exception Handling)

يتوافق `ApiClient` في Flutter بدقة مع استجابات Laravel الافتراضية:

| كود الحالة | استجابة Laravel | تعامل `ApiClient` و `ApiException` |
| :--- | :--- | :--- |
| **401 Unauthorized** | `{"message": "Unauthenticated."}` | يطلق `UnauthorizedException` ويستدعي `_onUnauthorized` لمسح الجلسة وتوجيه المستخدم لتسجيل الدخول. |
| **403 Forbidden** | `{"message": "This action is unauthorized."}` | يطلق `ForbiddenException`. |
| **404 Not Found** | `{"message": "Resource not found."}` | يطلق `NotFoundException`. |
| **422 Validation Error** | `{"message": "The given data was invalid.", "errors": {"email": ["..."]}}` | يطلق `ValidationException` ويقوم بتفكيك مصفوفة الحقول `errors` إلى `Map<String, List<String>>`. |
| **429 Too Many Requests** | `{"message": "Too Many Attempts."}` | يطلق `RateLimitException`. |
| **500 Server Error** | `{"message": "Server error", "exception": "..."}` | يطلق `ServerException`. |

---

## 4. نموذج الترقيم وتعدد الصفحات (Pagination Standard)

- **نمط Laravel:**
  ```json
  {
    "data": [ ... ],
    "links": { "first": "...", "last": "...", "prev": null, "next": "..." },
    "meta": {
      "current_page": 1,
      "from": 1,
      "last_page": 5,
      "path": "...",
      "per_page": 10,
      "to": 10,
      "total": 48
    }
  }
  ```
- **نمط Flutter المقروء في `products_repository_impl.dart` و `orders_repository_impl.dart`:**
  ```dart
  final rawList = data is Map<String, dynamic> && data['data'] is List
      ? data['data'] as List
      : data is List
          ? data
          : const [];
  ```
- **النتيجة:** قراءة Flutter مرنة وتدعم نمط `data['data']` الخاص بـ Laravel Resources و LengthAwarePaginator دون أي تعارض.
