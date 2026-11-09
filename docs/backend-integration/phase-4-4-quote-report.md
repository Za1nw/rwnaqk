# تقرير إنجاز المرحلة 4.4 — Cart Quote, Dynamic Shipping & Coupon Integration
# Phase 4.4 Completion Report: Cart Quote, Dynamic Shipping & Coupon Integration

**المشروع:** متجر رَوْنَقُك الإلكتروني (Rwnaqk E-Commerce)  
**التاريخ:** 8 نوفمبر 2026  
**الحالة:** مكتمل بنجاح (100% Passed) — جاهز للمرحلة 4.5 (Orders & Payments)  
**المهندسون المسؤولون:** Senior Laravel Architect & Flutter Integration Engineer  

---

## 1. الملخص التنفيذي (Executive Summary)

تم بحمد الله وتوفيقه إنجاز المرحلة 4.4 بالكامل وفق أعلى معايير هندسة البرمجيات والتجارة الإلكترونية، حيث تم:
1. **بناء محرك احتساب الأسعار وعروض السلة المركزي (Single Source of Truth) في Laravel 13:**
   - السيرفر هو المرجع الحصري لأسعار الوحدات، والخصومات المطبقة على المنتجات، وحساب رسوم التوصيل الجغرافي، وصلاحية الكوبونات.
   - منع الثقة في أي أسعار، مجاميع، أو نسب خصم مرسلة من واجهة Flutter.
2. **توفير واجهات API معتمدة ومحمية بـ Sanctum:**
   - `POST /api/v1/customer/cart/quote`: لحساب عرض سعر السلة الشامل (أسعار السطور، خصومات المنتجات، رسوم التوصيل الجغرافي، خيارات الشحن، الكوبونات، والإجمالي النهائي).
   - `POST /api/v1/customer/cart/validate-coupon`: للتحقق الفوري والمسبق من كود الخصم وسقفه المالي والحدود الدنيا للاستخدام.
3. **التكامل مع منظومة الشحن والتسعير الجغرافي الذكي:**
   - الاستفادة المباشرة من `OrderQuoteService` و`GeoDeliveryPricingService` دون تكرار شيفرة التسعير.
   - التحقق الصارم من ملكية عنوان التوصيل للعميل المصادق (`auth:sanctum`).
   - معالجة العناوين غير المغطاة جغرافياً وإعادة `is_serviceable: false` برسائل عربية واضحة دون كسر التدفق.
4. **منظومة كوبونات موثوقة ومحمية:**
   - تطبيق محددات دقيقة: نسبة الخصم، الحد الأدنى للطلب (Min Spend)، السقف الأعلى للخصم (Max Cap)، والحد الأقصى لمرات الاستخدام لكل مستخدم (Max Uses Per User) مفحوصة بدقة في جدول الطلبات (`orders`).
5. **ربط الواجهة الأمامية Flutter دون المساس بالمعمارية المجمدة:**
   - إنشاء نموذج `CartQuoteModel` النقي ومطابقته لعقد Laravel JSON.
   - تحديث `CartService` و`CartController` لإعادة احتساب السعر آلياً من الخادم عند الدخول للدفع أو تغيير العنوان أو تعديل الكميات أو تفعيل الكوبون.
   - الحفاظ على استمرارية وضع الـ Mock والاختبارات السابقة بنسبة نجاح 100%.

---

## 2. سجل الملفات المنفذة والمعدلة (Files Added & Modified)

### أ) جانب Laravel Backend (`rwnaqk-backend`)
| الملف | الحالة | الوظيفة الهندسية |
|---|---|---|
| `Modules/Shop/app/Services/CartQuoteEngineService.php` | جديد | محرك الحسابات المالية للسلة والخصومات والكوبونات والتوصيل الجغرافي |
| `Modules/Shop/app/Http/Requests/Cart/CartQuoteRequest.php` | جديد | التحقق الصارم من صحة طلب عرض السعر، والتحقق من وجود معرّف المنتج أو المتغير والكميات |
| `Modules/Shop/app/Http/Requests/Cart/ValidateCouponRequest.php` | جديد | التحقق من صحة كود الكوبون وإجمالي المشتريات |
| `Modules/Shop/app/Http/Controllers/Api/CartApiController.php` | جديد | المتحكم المسؤول عن مسارات السلة وعرض السعر والتحقق من الكوبونات |
| `Modules/Shop/routes/api.php` | معدّل | تسجيل مسارات `/api/v1/customer/cart/quote` و`validate-coupon` تحت `auth:sanctum` |
| `tests/Feature/Shop/CartQuoteApiTest.php` | جديد | جناح اختبارات Pest المتقدم يغطي 15 حالة اختبارية مالية وجغرافية وأمنية |

### ب) جانب Flutter Frontend (`rwnaqk_frontend`)
| الملف | الحالة | الوظيفة الهندسية |
|---|---|---|
| `lib/modules/cart/data/models/cart_quote_model.dart` | جديد | نماذج `CartQuoteModel`, `CartQuoteItemModel`, `CartShippingOptionModel` لتحليل استجابة السيرفر |
| `lib/modules/cart/controllers/cart_service.dart` | معدّل | تزويد الخدمة بدوال `requestCartQuote` و`validateCouponOnline` عبر `ApiClient` |
| `lib/modules/cart/controllers/cart_controller.dart` | معدّل | إدارة حالة `serverQuote` وإعادة التسعير التلقائي ودمج خيارات الشحن من السيرفر |
| `lib/core/bindings/initial_binding.dart` | معدّل | تمرير `ApiClient` المحقون إلى `CartService` |
| `test/network_and_repositories_test.dart` | معدّل | إضافة جناح اختبارات للتحقق من نماذج السلة وربط استدعاءات API |

---

## 3. عقود البيانات الرسمية (API Contracts)

### 3.1. عرض سعر السلة (Cart Quote API)
- **المسار:** `POST /api/v1/customer/cart/quote`
- **المصادقة:** مطلوبة (`Authorization: Bearer <sanctum_token>`)
- **Headers:** `Accept: application/json`, `Content-Type: application/json`

#### نموذج الطلب (Request Payload):
```json
{
  "address_id": 12,
  "items": [
    {
      "product_variation_id": 45,
      "qty": 2
    },
    {
      "product_id": 8,
      "qty": 1
    }
  ],
  "coupon_code": "RAWNAQ",
  "shipping_option_id": "1"
}
```

#### نموذج الاستجابة الناجحة (Success Response 200 OK):
```json
{
  "status": "success",
  "message": "تم احتساب عرض سعر السلة بنجاح.",
  "data": {
    "currency": "YER",
    "currency_symbol": "ر.ي",
    "is_serviceable": true,
    "address_id": 12,
    "items": [
      {
        "product_id": 5,
        "product_variation_id": 45,
        "name": "فستان سهرة فاخر",
        "sku": "EVE-RED-S",
        "qty": 2,
        "unit_price": 10000.0,
        "unit_discount": 2000.0,
        "effective_unit_price": 8000.0,
        "line_subtotal": 20000.0,
        "line_product_discount": 4000.0,
        "line_total": 16000.0
      },
      {
        "product_id": 8,
        "product_variation_id": 80,
        "name": "حقيبة يد كلاسيكية",
        "sku": "BAG-BLK",
        "qty": 1,
        "unit_price": 6000.0,
        "unit_discount": 0.0,
        "effective_unit_price": 6000.0,
        "line_subtotal": 6000.0,
        "line_product_discount": 0.0,
        "line_total": 6000.0
      }
    ],
    "subtotal": 26000.0,
    "product_discount_total": 4000.0,
    "net_subtotal": 22000.0,
    "coupon_code": "RAWNAQ",
    "coupon_discount_total": 3300.0,
    "shipping_fee": 1500.0,
    "grand_total": 20200.0,
    "shipping_options": [
      {
        "id": "1",
        "name": "التوصيل المباشر (التسعير الذكي)",
        "zone_name": "نطاق الأمانة الداخلي",
        "fee": 1500.0,
        "formatted_fee": "1,500 ر.ي",
        "duration_minutes": 35,
        "duration_text": "35 دقيقة تقريباً"
      }
    ],
    "selected_shipping_option": {
      "id": "1",
      "name": "التوصيل المباشر (التسعير الذكي)",
      "zone_name": "نطاق الأمانة الداخلي",
      "fee": 1500.0,
      "formatted_fee": "1,500 ر.ي",
      "duration_minutes": 35,
      "duration_text": "35 دقيقة تقريباً"
    },
    "message": "تم تفعيل كود الخصم (RAWNAQ) بنجاح (خصم 15%)."
  }
}
```

---

### 3.2. التحقق من الكوبون (Coupon Validation API)
- **المسار:** `POST /api/v1/customer/cart/validate-coupon`
- **المصادقة:** مطلوبة (`Authorization: Bearer <sanctum_token>`)

#### نموذج الطلب (Request Payload):
```json
{
  "coupon_code": "RAWNAQ",
  "subtotal": 12000.0
}
```

#### الاستجابة في حالة الصلاحية (200 OK):
```json
{
  "status": "success",
  "message": "تم تفعيل كود الخصم (RAWNAQ) بنجاح (خصم 15%).",
  "data": {
    "valid": true,
    "coupon_code": "RAWNAQ",
    "discount_percent": 15,
    "discount_amount": 1800.0,
    "message": "تم تفعيل كود الخصم (RAWNAQ) بنجاح (خصم 15%)."
  }
}
```

#### الاستجابة في حالة عدم استيفاء الشروط (422 Unprocessable Entity):
```json
{
  "status": "error",
  "message": "قيمة مشترياتك أقل من الحد الأدنى لتطبيق هذا الكوبون (5,000 ر.ي).",
  "errors": {
    "coupon_code": [
      "قيمة مشترياتك أقل من الحد الأدنى لتطبيق هذا الكوبون (5,000 ر.ي)."
    ]
  },
  "data": {
    "valid": false,
    "discount_amount": 0.0,
    "message": "قيمة مشترياتك أقل من الحد الأدنى لتطبيق هذا الكوبون (5,000 ر.ي)."
  }
}
```

---

## 4. القواعد الحسابية والمالية (Pricing Engine & Financial Precision)

1. **مصدر الأسعار الحصري:**
   - يتم أخذ السعر من جدول `product_variations.price` وإذا كان صفراً يُؤخذ من `products.min_price`.
   - لا يُعتد بأي سعر قادم من العميل نهائياً.
2. **الخصومات الزمنية للمنتج (Active Product Discounts):**
   - يُفحص نوع الخصم (`percent` أو `fixed`) ومجال التفعيل الزمني (`discount_start_at` و `discount_end_at`).
   - إذا انتهت فترة الخصم أو لم تبدأ بعد، تُحسب قيمة الخصم كـ `0.0`.
3. **المعادلات الرياضية الصارمة:**
   - `Effective Unit Price = max(0, Base Unit Price - Unit Discount)`
   - `Line Subtotal = Base Unit Price × Qty`
   - `Line Product Discount = Unit Discount × Qty`
   - `Line Total = Effective Unit Price × Qty`
   - `Cart Subtotal = Σ Line Subtotal`
   - `Product Discount Total = Σ Line Product Discount`
   - `Net Subtotal = Cart Subtotal - Product Discount Total`
   - `Coupon Discount = min(Max Discount Cap, Net Subtotal × Coupon Percent)`
   - `Grand Total = max(0, Net Subtotal - Coupon Discount + Shipping Fee)`
4. **منع الأخطاء التراكمية (Floating Point Drift Prevention):**
   - يتم تدوير كافة المبالغ إلى منزلتين عشريتين (`round($val, 2)`) عند كل مرحلة حسابية.
5. **دمج التكرار (Deduplication):**
   - في حال إرسال نفس المتغير (`product_variation_id`) في عدة أسطر، يقوم المحرك تلقائياً بدمج الكميات وحساب سطر واحد موحد بدقة.

---

## 5. قواعد احتساب التوصيل الجغرافي (Geographic Shipping Calculation)

1. **التحقق من ملكية العنوان:**
   - يتم فحص `$customer->addresses()->find($addressId)`، وإذا كان العنوان لعميل آخر أو غير موجود يُرفض بـ 422.
2. **فحص الإحداثيات والتغطية:**
   - تمرير العنوان لـ `OrderQuoteService::quoteForAddress($address)`.
   - إن كانت الإحداثيات مفقودة أو خارج نطاق المديريات المعتمدة، يتم تعيين `is_serviceable = false` و `shipping_fee = 0` مع رسالة إرشادية.
3. **خيارات الشحن الديناميكية:**
   - استخراج شركات الشحن واللوجستيات المتاحة للنطاق الجغرافي (`eligible_logistics`).
   - تحديد تكلفة الشحن الأساسية لكل خيار مع الوقت المتوقع للتوصيل بالدقائق.
   - احترام الخيار المفضل للمستخدم (`shipping_option_id`) أو اعتماد الخيار الأنسب افتراضياً.

---

## 6. قواعد الكوبونات والحدود (Coupon Limits & Policies)

تم تسجيل الكوبونات النظامية مع محدداتها المالية في `CartQuoteEngineService`:

| كود الكوبون | نسبة الخصم | الحد الأدنى للشراء | السقف الأعلى للخصم | الحد الأقصى للاستخدام لكل عميل | الغرض |
|---|---|---|---|---|---|
| `RAWNAQ` | 15% | 5,000 ر.ي | 10,000 ر.ي | 3 مرات | كوبون ترحيبي دائم |
| `RWNAQK` | 15% | 5,000 ر.ي | 10,000 ر.ي | 3 مرات | كوبون المتجر المميز |
| `RWNAQK15` | 15% | 5,000 ر.ي | 10,000 ر.ي | 3 مرات | خصم خاص |
| `WELCOME` | 20% | 3,000 ر.ي | 5,000 ر.ي | 1 مرة واحدة | خصم الطلب الأول للعملاء الجدد |
| `EID2026` | 10% | 10,000 ر.ي | 15,000 ر.ي | 5 مرات | عرض موسمي |

**آلية التحقق من الاستخدام:**
- يتم احتساب مرات الاستخدام عبر الاستعلام المباشر من جدول `orders`:
  `Order::where('user_id', $customer->id)->where('applied_coupon_code', $code)->count()`
- في حال تجاوز العميل للحد الأقصى أو عدم بلوغ الحد الأدنى، يُرفض الكوبون مع رسالة توضيحية دون تعطيل عرض السعر الإجمالي للسلة.

---

## 7. نتائج الاختبارات وضمان الجودة (Test Results & QA)

### أ) اختبارات Laravel Pest (`CartQuoteApiTest.php`):
```text
   PASS  Tests\Feature\Shop\CartQuoteApiTest
  ✓ it rejects unauthenticated requests to cart quote endpoints with 401
  ✓ it validates required fields for cart quote request with 422
  ✓ it rejects quote request when items array is empty or lacks variation/product id
  ✓ it strictly rejects address belonging to another customer with 422
  ✓ it calculates accurate unit prices, product discounts, line totals, and grand total
  ✓ it automatically deduplicates and merges repeated product variations in cart items
  ✓ it rejects quote request containing draft, unpublished, or soft-deleted products with 422
  ✓ it applies valid coupon with percentage discount up to cap correctly in quote
  ✓ it rejects coupon when net subtotal is below minimum spend requirement without failing quote
  ✓ it enforces coupon per-customer usage limit against orders table
  ✓ it handles invalid coupon code gracefully without breaking quote calculation
  ✓ it handles out-of-coverage address gracefully with is_serviceable false
  ✓ it validates coupon successfully via standalone validate-coupon endpoint
  ✓ it returns 422 for invalid coupon on standalone validate-coupon endpoint
  ✓ it returns 422 on standalone validate-coupon endpoint when subtotal is below minimum spend

  Tests:    15 passed (72 assertions)
```

**إجمالي اختبارات الموديولات ذات العلاقة:**
- `CustomerAddressApiTest`: 18 passed.
- `CartQuoteApiTest`: 15 passed.
- `PublicCatalogApiTest`: 15 passed.
- **المجموع في Laravel:** 48 اختبار ناجح بالكامل (269 تأكيداً برمجياً).

### ب) اختبارات وتحليلات Flutter Frontend:
- أمر الفحص الساكن: `flutter analyze`
  - **النتيجة:** `No issues found!` (0 أخطاء، 0 تحذيرات).
- أمر اختبارات الوحدة والواجهات: `flutter test`
  - **النتيجة:** `All tests passed!` (52 اختباراً ناجحاً بنسبة 100%).

---

## 8. الحدود الفاصلة والمهام المؤجلة للمرحلة 4.5 (Deferred to Phase 4.5)

وفق التوجيهات الصارمة، تم قصر العمل على المرحلة 4.4 فقط وتأجيل الآتي للمرحلة 4.5:
1. **إنشاء الطلبات الفعلية في قاعدة البيانات (`POST /api/v1/customer/orders`):** لم يتم تسجيل أي طلبات فعلية في جدول `orders` أثناء طلبات عرض السعر.
2. **معالجة الدفع المالي وسندات التحويل:** سندات المحافظ والحوالات مؤجلة بالكامل للمرحلة 4.5.
3. **خصم المخزون الفعلي (Stock Reservation / Deduction):** يتم فقط في مرحلة إنشاء الطلب النهائي وليس أثناء احتساب عرض السعر.
4. **مفاتيح منع التكرار (`X-Idempotency-Key`):** جاهزة في `ApiClient` وتنتظر تطبيقها مع مسار إنشاء الطلبات النهائي.

---

## 9. إقرار الجاهزية (Readiness Decision)

✅ **المرحلة 4.4 مكتملة بنجاح وجاهزة بنسبة 100%.**  
نظام احتساب أسعار السلة، ورسوم التوصيل الجغرافي، والكوبونات يعمل الآن بتزامن كامل وموثوق بين Laravel 13 و Flutter GetX.  
نحن بانتظار توجيهكم للانتقال إلى **المرحلة 4.5 — Orders Creation & Payments Integration**.

