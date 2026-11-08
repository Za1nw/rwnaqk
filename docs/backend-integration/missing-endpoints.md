# Missing Endpoints Specification & Gap Catalog

**المشروع:** متجر رونقك (Rwnaqk Store)  
**المرحلة:** Phase 4.1 — حصر وتوصيف نقاط النهاية الناقصة (Missing Endpoints)  
**التصنيف:** مرتبة حسب الأولويات والتبعيات الهندسية للبدء من الكتالوج وصولاً إلى الطلبات والدفع.

---

## 1. فهرس نقاط النهاية الناقصة مرتبة حسب التبعيات

```text
الأولوية 1: كتالوج المتجر والتصنيفات (Catalog & Taxonomy)
  ├── 1.1 GET /api/v1/categories                      (قائمة التصنيفات العامة والأشجار)
  ├── 1.2 GET /api/v1/brands                          (قائمة العلامات التجارية العامة)
  ├── 1.3 GET /api/v1/products                        (تصفح المنتجات مع الفلترة والترقيم)
  ├── 1.4 GET /api/v1/products/{id}                   (تفاصيل المنتج والسمات والصور)
  └── 1.5 GET /api/v1/products/{id}/reviews           (مراجعات وتقييمات المنتج)

الأولوية 2: العناوين والتغطية الجغرافية (Customer Addresses & Geo)
  ├── 2.1 GET /api/v1/customer/addresses              (جلب عناوين العميل المصادق)
  ├── 2.2 POST /api/v1/customer/addresses             (إضافة عنوان جديد مع فحص التغطية)
  ├── 2.3 PUT /api/v1/customer/addresses/{id}         (تعديل عنوان العميل)
  ├── 2.4 DELETE /api/v1/customer/addresses/{id}      (حذف عنوان العميل)
  └── 2.5 PATCH /api/v1/customer/addresses/{id}/primary (تعيين العنوان كافتراضي)

الأولوية 3: السلة والتسعير وكوبونات الخصم (Cart, Pricing & Coupons)
  ├── 3.1 POST /api/v1/customer/cart/quote            (احتساب تكلفة الشحن والإجمالي لحظياً)
  └── 3.2 POST /api/v1/customer/cart/validate-coupon  (التحقق من صلاحية قسيمة التخفيض)

الأولوية 4: إتمام الطلبات والدفع (Checkout & Orders)
  ├── 4.1 GET /api/v1/settings/payment-wallets        (قائمة حسابات المحافظ المعتمدة للتحويل)
  ├── 4.2 POST /api/v1/customer/orders                (إنشاء وتأكيد الطلب مع X-Idempotency-Key)
  ├── 4.3 GET /api/v1/customer/orders                 (سجل طلبات العميل المصادق)
  ├── 4.4 GET /api/v1/customer/orders/{id}            (تفاصيل طلب العميل ومراحل التتبع)
  └── 4.5 POST /api/v1/customer/orders/{id}/cancel    (إلغاء الطلب قبل التأكيد أو التجهيز)
```

---

## 2. التوصيف الفني التفصيلي لنقاط النهاية الناقصة

---

### 1.1 `GET /api/v1/categories` (قائمة التصنيفات)
- **الغرض:** عرض تصنيفات المتجر في الواجهة الرئيسية وصفحة الأقسام.
- **نوع المصادقة:** عامة (Public).
- **المتحكم المقترح:** `Modules\Shop\Http\Controllers\Api\CategoryApiController@index`.
- **Query Parameters:**
  - `parent_id` (اختياري | numeric): تصفية الأقسام الفرعية التابعة لقسم رئيسي محدد.
  - `tree` (اختياري | boolean): إعادة الأقسام في هيكل شجري متداخل (`children`).
  - `is_featured` (اختياري | boolean): الأقسام المميزة فقط.
- **Response Schema (Status 200 OK):**
  ```json
  {
    "data": [
      {
        "id": 1,
        "name": "أزياء نسائية",
        "slug": "womens-fashion",
        "parent_id": null,
        "sorting_order_level": 1,
        "is_featured": true,
        "is_top": true,
        "feature_image": "https://.../cat1.jpg",
        "children": [
          {
            "id": 5,
            "name": "فساتين",
            "slug": "dresses",
            "parent_id": 1
          }
        ]
      }
    ]
  }
  ```
- **إعادة الاستخدام:** استخدام `CategoryResource` و `CategoryCollection` الموجودين أصلاً.

---

### 1.2 `GET /api/v1/brands` (قائمة العلامات التجارية)
- **الغرض:** تصفح والفلترة حسب الماركات في الكتالوج.
- **نوع المصادقة:** عامة (Public).
- **المتحكم المقترح:** `Modules\Shop\Http\Controllers\Api\BrandApiController@index`.
- **Query Parameters:**
  - `is_featured` (اختياري | boolean)
  - `search` (اختياري | string)
- **Response Schema (Status 200 OK):**
  ```json
  {
    "data": [
      {
        "id": 3,
        "name": "زارا",
        "slug": "zara",
        "logo": "https://.../zara.png",
        "products_count": 28
      }
    ]
  }
  ```
- **إعادة الاستخدام:** كلاس `BrandResource` الموجود.

---

### 1.3 `GET /api/v1/products` (قائمة المنتجات والفلترة)
- **الغرض:** تغذية شاشات العرض والبحث والكتالوج في تطبيق Flutter.
- **نوع المصادقة:** عامة (Public).
- **المتحكم المقترح:** `Modules\Shop\Http\Controllers\Api\ProductApiController@index`.
- **Query Parameters المدعومة:**
  - `page` (numeric | default: 1)
  - `limit` (numeric | default: 10 | max: 50)
  - `sort` (enum: `newest`, `priceLowToHigh`, `priceHighToLow`, `popular`, `rating`)
  - `category_id` (numeric)
  - `brand_id` (numeric)
  - `min_price` (numeric)
  - `max_price` (numeric)
  - `search` (string)
  - `is_featured` (boolean)
- **قواعد الاستعلام:**
  - إرجاع المنتجات المفعلة فقط (`where('status', true)`).
  - إخفاء المنتجات المحذوفة تلقائياً (`whereNull('deleted_at')`).
- **Response Schema:**
  ```json
  {
    "data": [
      {
        "id": 101,
        "name": "فستان سهرة كلاسيكي",
        "slug": "classic-evening-dress",
        "min_price": "18000.00",
        "max_price": "22000.00",
        "discount_value": "10.00",
        "discount_type": "percent",
        "stock_qty": 45,
        "is_new": true,
        "is_featured": true,
        "feature_image": "https://.../dress1.jpg",
        "brand": { "id": 3, "name": "زارا" }
      }
    ],
    "meta": {
      "current_page": 1,
      "last_page": 5,
      "per_page": 10,
      "total": 48
    }
  }
  ```
- **إعادة الاستخدام:** استدعاء محرك البحث في `ListProductsAction` مع تخصيص الـ Scope للعميل (`status = 1`).

---

### 1.4 `GET /api/v1/products/{id}` (تفاصيل المنتج والسمات)
- **الغرض:** شاشة تفاصيل المنتج (`ProductDetailsView`) واختيار السمات (اللون والمقاس).
- **نوع المصادقة:** عامة (Public).
- **المتحكم المقترح:** `Modules\Shop\Http\Controllers\Api\ProductApiController@show`.
- **Response Schema (Status 200 OK):**
  - يعتمد 100% على `ProductShowResource` الجاهز بالكامل، والذي يتضمن:
    - بيانات الوصف، دليل المقاسات، سياسة التوصيل.
    - مصفوفة الصور `gallery`.
    - مصفوفة السمات `variations` مع كل سمة (`id`, `sku`, `price`, `combinations`, `stocks`).
- **حالات الخطأ:**
  - `404 Not Found`: إذا كان المعرف غير موجود أو كان المنتج معطلاً (`status = 0`).

---

### 1.5 `GET /api/v1/products/{id}/reviews` (تقييمات ومراجعات المنتج)
- **الغرض:** عرض آراء وتقييمات العملاء في تبويب المراجعات.
- **نوع المصادقة:** عامة (Public).
- **المتحكم المقترح:** `Modules\Shop\Http\Controllers\Api\ProductApiController@reviews`.
- **Query Parameters:** `page`, `limit` (default: 10).
- **Response Schema:**
  ```json
  {
    "data": [
      {
        "id": 12,
        "customer_name": "سارة علي",
        "avatar_url": "https://.../avatar.jpg",
        "rating": 5,
        "comment": "خامة ممتازة وتوصيل سريع جداً",
        "created_at": "2026-11-05T12:00:00.000000Z"
      }
    ],
    "meta": { "total": 14, "average_rating": 4.8 }
  }
  ```

---

### 2.1-2.5 نقاط نهاية عناوين العميل (`/api/v1/customer/addresses`)
- **الغرض:** إدارة عناوين التوصيل للعميل المسجل وربطها بنطاق التغطية الجغرافي.
- **نوع المصادقة:** `auth:sanctum` (Customer Guard).
- **المتحكم المقترح:** `Modules\Customer\Http\Controllers\Api\CustomerAddressApiController`.
- **المسارات:**
  1. `GET /api/v1/customer/addresses`: جلب عناوين العميل المصادق فقط (`$request->user()->addresses`).
  2. `POST /api/v1/customer/addresses`: إضافة عنوان جديد.
     - **Request Payload:**
       ```json
       {
         "label": "المنزل",
         "description": "حي المسبح، شارع جمال، عمارة الأمل الدور الثاني",
         "governorate_id": 1,
         "district_id": 4,
         "latitude": 13.5789,
         "longitude": 44.0123,
         "contact_phone": "777123456",
         "contact_name": "أحمد المتوكل",
         "is_primary": true
       }
       ```
     - **المنطق المعاد استخدامه:** استدعاء `GeoCoverageService::applyCoverageToAddress($address)` تلقائياً للتحقق من التغطية وتخزين حالة `coverage_status` و `delivery_tier`.
  3. `PUT /api/v1/customer/addresses/{id}`: تعديل بيانات العنوان مع التحقق من ملكية العميل له.
  4. `DELETE /api/v1/customer/addresses/{id}`: حذف العنوان وضمان بقاء عنوان افتراضي إذا وُجدت عناوين أخرى.
  5. `PATCH /api/v1/customer/addresses/{id}/primary`: تعيين العنوان كافتراضي وإلغاء الافتراضي عن باقي العناوين.

---

### 3.1 `POST /api/v1/customer/cart/quote` (احتساب عرض السعر والشحن)
- **الغرض:** حساب الإجمالي ورسوم التوصيل والخصم وتحديد خيارات الشحن المتاحة قبل الانتقال للدفع.
- **نوع المصادقة:** `auth:sanctum`.
- **المتحكم المقترح:** `Modules\Shop\Http\Controllers\Api\CheckoutApiController@quote`.
- **Request Payload:**
  ```json
  {
    "address_id": 12,
    "items": [
      { "product_variation_id": 44, "qty": 2 }
    ],
    "coupon_code": "DISCOUNT10" // اختياري
  }
  ```
- **المنطق المعاد استخدامه:**
  - استدعاء `OrderQuoteService::quoteForAddress($address)`.
  - حساب المجموع الفرعي للبضائع، تطبيق الكوبون إن وجد، ورسوم الشحن.
- **Response Schema (Status 200 OK):**
  ```json
  {
    "is_serviceable": true,
    "distance_km": 4.5,
    "subtotal": 36000.0,
    "shipping_fee": 1500.0,
    "discount_amount": 3600.0,
    "grand_total": 33900.0,
    "delivery_hours": 24,
    "shipping_options": [
      {
        "id": 1,
        "name": "توصيل رونقك القياسي",
        "cost": 1500.0,
        "estimated_hours": 24
      }
    ]
  }
  ```

---

### 3.2 `POST /api/v1/customer/cart/validate-coupon` (فحص الكوبون)
- **الغرض:** زر تطبيق الكوبون في شاشة السلة.
- **نوع المصادقة:** `auth:sanctum`.
- **Request Payload:**
  ```json
  {
    "coupon_code": "PROMO2026",
    "subtotal": 25000.0
  }
  ```
- **Response Schema (Status 200 OK):**
  ```json
  {
    "valid": true,
    "code": "PROMO2026",
    "discount_type": "percent",
    "discount_value": 10.0,
    "discount_amount": 2500.0,
    "message": "تم تطبيق الخصم بنجاح"
  }
  ```

---

### 4.1 `GET /api/v1/settings/payment-wallets` (حسابات المحافظ المعتمدة)
- **الغرض:** تزويد تطبيق Flutter بقائمة الحسابات البنكية والمحافظ الإلكترونية التي يمكن للعميل التحويل إليها عند اختيار الدفع بالمحفظة (`wallet`).
- **نوع المصادقة:** عامة أو مصادقة.
- **المتحكم المقترح:** `Modules\Settings\Http\Controllers\Api\PaymentSettingsApiController@wallets`.
- **Response Schema:**
  ```json
  {
    "data": [
      {
        "id": "onecash",
        "company_name": "ون كاش (OneCash)",
        "receiver_name": "متجر رونقك التجاري",
        "wallet_number": "775987654",
        "instructions": "يرجى كتابة رقم هاتفك في خانة الملاحظات أثناء التحويل"
      },
      {
        "id": "jib",
        "company_name": "جيب (Jib)",
        "receiver_name": "متجر رونقك التجاري",
        "wallet_number": "777123456",
        "instructions": "يرجى إرفاق صورة السند بعد إتمام العملية"
      }
    ]
  }
  ```

---

### 4.2 `POST /api/v1/customer/orders` (إنشاء وتأكيد الطلب)
- **الغرض:** اعتماد الطلب النهائي من شاشة التأكيد في تطبيق Flutter (`PaymentController.confirmAndSubmitOrder`).
- **نوع المصادقة:** `auth:sanctum` (Customer Guard).
- **الهيدر الأمني الإلزامي:** `X-Idempotency-Key` (UUID لمنع التكرار).
- **Request Payload:**
  ```json
  {
    "address_id": 12,                     // Required | exists:addresses,id
    "logistic_id": 1,                     // Required | exists:logistics,id
    "payment_method": "wallet",           // Required | in:cash_on_delivery,wallet
    "wallet_account_id": "jib",           // Required if payment_method == 'wallet'
    "payment_receipt_url": "https://...", // Required if payment_method == 'wallet' | url
    "notes": "يرجى التواصل قبل التسليم",  // Optional | string | max:500
    "coupon_code": "PROMO2026",           // Optional | string
    "items": [                            // Required | array | min:1
      {
        "product_variation_id": 44,       // Required | exists:product_variations,id
        "qty": 2                          // Required | integer | min:1
      }
    ]
  }
  ```
- **خطوات التنفيذ داخل DB Transaction:**
  1. التحقق من مفتاح منع التكرار (`X-Idempotency-Key`).
  2. التحقق من ملكية العنوان للعميل وصلاحيته للتوصيل.
  3. التحقق من توفر المخزون لكل سمة في عناصر الطلب.
  4. احتساب المبالغ والشحن والكوبون مطابقة لعرض السعر.
  5. إنشاء `OrderGroup` وحفظ تفاصيل الدفع وسند التحويل.
  6. إنشاء `Order` و `OrderItem` و `OrderUpdate`.
  7. خصم كميات المخزون من `product_variation_stocks`.
  8. ربط الطلب تلقائياً بخدمة العناقيد المكانية `CentroidBatchingService`.
  9. تخزين الاستجابة في الكاش لمنع التكرار لمدة 24 ساعة.
- **Response Schema (Status 201 Created):**
  ```json
  {
    "message": "تم تأكيد طلبك بنجاح",
    "data": {
      "id": 108,
      "order_code": "RW-2026-00108",
      "created_at": "2026-11-08T16:00:00.000000Z",
      "status": "order_placed",
      "delivery_status": "order_placed",
      "payment_status": "unpaid",
      "payment_method": "wallet",
      "total": 33900.0,
      "sub_total": 36000.0,
      "shipping_cost": 1500.0,
      "discount": 3600.0,
      "items_count": 2,
      "delivery_name": "أحمد المتوكل",
      "delivery_phone": "777123456",
      "address_line": "حي المسبح، شارع جمال، تعز"
    }
  }
  ```

---

### 4.3 & 4.4 `GET /api/v1/customer/orders` و `GET /api/v1/customer/orders/{id}`
- **الغرض:** عرض قائمة طلبات العميل وتتبع تفاصيل وحالة الطلب في شاشات `OrdersView` و `OrderDetailsView`.
- **نوع المصادقة:** `auth:sanctum`.
- **المتحكم المقترح:** `Modules\Shop\Http\Controllers\Api\CustomerOrderApiController`.
- **Response Schema:**
  - يعيد مصفوفة من الطلبات التابعة للمستخدم المصادق، متضمنة عناصر الطلب ومراحل التتبع وعنوان التوصيل وسعر كل بند وحالة الدفع.

---

### 4.5 `POST /api/v1/customer/orders/{id}/cancel` (إلغاء الطلب)
- **الغرض:** زر إلغاء الطلب من قِبل العميل.
- **نوع المصادقة:** `auth:sanctum`.
- **القواعد:**
  - يسمح بالإلغاء فقط إذا كانت حالة التسليم `order_placed`.
  - يتم تحديث الحالة إلى `cancelled`.
  - إعادة كميات المنتجات إلى المخزون تلقائياً.
  - تسجيل حركة في `OrderUpdate` تشير إلى أن الإلغاء تم من قِبل العميل.
