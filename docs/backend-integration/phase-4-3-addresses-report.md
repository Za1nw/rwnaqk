# تقرير المرحلة 4.3: عناوين العملاء والتغطية الجغرافية والتكامل مع فلاتر
**مشروع متجر رونقك الإلكتروني**  
**التاريخ:** 8 نوفمبر 2026  
**الحالة:** مكتمل ومُختبَر بنجاح بنسبة 100%  
**المرجع:** `docs/backend-integration/phase-4-3-addresses-report.md`

---

## 1. ملخص تنفيذي للمرحلة

تم في هذه المرحلة (Phase 4.3) بناء وتفعيل منظومة **عناوين العملاء ونطاقات التغطية الجغرافية والتوصيل (Customer Addresses & Geographic Coverage API)** على **Laravel 13** وتكاملها بشكل كامل وآمن مع تطبيق **Flutter (GetX)**.

أهم النتائج المحققة:
1. **عزل صارم لبيانات العملاء (Tenant & User Isolation):** تعتمد جميع العمليات حصرياً على علاقة المستخدم المصادق عبر Sanctum (`$request->user()->addresses()`)، مع حظر كامل لأي هجوم تجاوز صلاحيات معرف الكائن (IDOR)، وإعادة `404` عند محاولة أي مستخدم الوصول لعنوان لا يملكه.
2. **منظومة التغطية الجغرافية الحقيقية (Geo Coverage Engine):** استخدام خدمة `GeoCoverageService` الموجودة مسبقاً وتطويرها لتغطي سيناريوهات الإحداثيات (خوارزمية Ray-Casting للمضلعات والدوائر ونصف القطر وحلقات Delivery Tiers) وسيناريوهات الاختيار الإداري (المحافظة والمديرية)، مع تجاهل تام لأي قيم يرسلها العميل لـ `is_serviceable` أو `delivery_tier`.
3. **إدارة العنوان الافتراضي (Primary Address Lifecycle):** ضمان وجود عنوان افتراضي واحد فقط للعميل دائماً عبر `DB::transaction`، والتعيين التلقائي لأول عنوان مضاف كرئيسي، وترقية العنوان التالي تلقائياً عند حذف العنوان الرئيسي الحالي.
4. **عقد فلاتر المتوافق والمستودع النقي (Repository Pattern):** إنشاء `IAddressesRepository` و `AddressesRepositoryImpl` المستند إلى `ApiClient` مع دعم التبديل للوضع الوهمي `FakeAddressesRepository` فقط عند تفعيل `ENABLE_MOCK_DATA=true` صراحةً، وإلغاء أي Fallback صامت.
5. **جاهزية الدفع والتوصيل (Checkout Readiness):** فحص صلاحية التوصيل `isServiceable` في شاشات العناوين وإيقاف متابعة عملية الدفع في `PaymentController` إذا كان العنوان خارج التغطية.
6. **اجتياز جميع الاختبارات:**
   - **Laravel Pest:** 18 اختباراً جديداً للعناوين (70 توكيداً) و 33 اختباراً تراكمياً (197 توكيداً) بنجاح 100%.
   - **Flutter Test:** 49 اختباراً متكاملاً لاختبارات الوحدات والواجهات والمستودعات بنجاح 100%.
   - **Flutter Analyze:** 0 مشاكل أو تحذيرات (`No issues found!`).

---

## 2. الملفات المضافة والمعدلة

### أ. ملفات Laravel Backend المضافة والمعدلة (`rwnaqk-backend`)
1. **`Modules/Customer/app/Http/Controllers/Api/CustomerAddressApiController.php` (جديد)**
   - كنترولر مخصص لـ API العناوين المصادق عبر Sanctum: `index`, `store`, `show`, `update`, `destroy`, `setPrimary`.
2. **`Modules/Customer/routes/api.php` (معدل)**
   - تسجيل المسارات الستة تحت بادئة `v1/customer/addresses` وحمايتها بواسطة `auth:sanctum`.
3. **`Modules/Geo/routes/api.php` (معدل)**
   - تسجيل مسارات الاستعلام الجغرافي العامة للهواتف: `countries`, `governorates`, `districts`, `yemen/governorates`.
4. **`Modules/Customer/app/Transformers/Address/AddressResource.php` (معدل)**
   - إزالة الـ Wrapping التلقائي (`$wrap = null;`) وإضافة أسماء ومفاتيح الحقول المتوافقة مع فلاتر (`address`, `city`, `postcode`, `country`, `is_default`, `isDefault`, `is_serviceable`, `coverage_status`).
5. **`Modules/Customer/app/Http/Requests/Address/StoreCustomerAddressRequest.php` (معدل)**
   - دعم مفاتيح `address` أو `description`، والتحقق الصارم من انتماء `district_id` إلى `governorate_id` عبر `Validator::after`.
6. **`Modules/Customer/app/Http/Requests/Address/UpdateCustomerAddressRequest.php` (معدل)**
   - جعل الحقول اختيارية للتحديث الجزئي مع الحفاظ على قاعدة تطابق المديرية مع المحافظة.
7. **`Modules/Geo/app/Services/GeoCoverageService.php` (معدل)**
   - دعم التحديد التلقائي للتغطية عند غياب الإحداثيات اعتماداً على حالة نشاط المحافظة والمديرية وحلقات التسعير المرتبطة بها.
8. **`tests/Feature/Customer/CustomerAddressApiTest.php` (جديد)**
   - 18 اختبار Pest شامل للعناوين والأمان الجغرافي وصلاحيات المستخدمين.

### ب. ملفات Flutter Frontend المضافة والمعدلة (`rwnaqk_frontend`)
1. **`lib/core/network/api_endpoints.dart` (معدل)**
   - إضافة مسارات `customerAddresses`, `customerAddressDetails(id)`, `customerAddressPrimary(id)`.
2. **`lib/core/network/api_client.dart` (معدل)**
   - إضافة دالة `patch<T>` لدعم تحديث العناوين الافتراضية عبر HTTP PATCH.
3. **`lib/modules/customer/data/models/shipping_address.dart` (معدل)**
   - إضافة حقول التغطية الجغرافية: `isServiceable`, `coverageStatus`, `governorateId`, `districtId`, `latitude`, `longitude`, `phone`, `contactName`, `deliveryTier`.
   - إضافة محولات `fromJson` و `toJson`.
4. **`lib/modules/customer/data/repositories/addresses_repository.dart` (جديد)**
   - واجهة مستودع العناوين النقية `IAddressesRepository`.
5. **`lib/modules/customer/data/providers/fake_addresses_remote_data_source.dart` (جديد)**
   - مستودع وهمي `FakeAddressesRepository` يحافظ على البيانات التجريبية لاختبارات Mock.
6. **`lib/modules/customer/data/repositories/addresses_repository_impl.dart` (جديد)**
   - تطبيق المستودع المتصل بخادم Laravel API عبر `ApiClient`، مع تمرير الأخطاء الحقيقية (`rethrow;`).
7. **`lib/modules/customer/controllers/addresses_service.dart` (معدل)**
   - ربط الخدمة بمستودع `IAddressesRepository` ودعم استدعاءات الخادم غير المتزامنة.
8. **`lib/modules/customer/controllers/addresses_controller.dart` (معدل)**
   - إضافة حالة `isLoading`، والتكامل مع الخادم في `loadAddresses`, `saveFromSheet`, `setDefault`, `deleteAddress`.
9. **`lib/modules/checkout/controllers/payment_controller.dart` (معدل)**
   - فحص `isServiceable` ومنع إتمام الطلب في حالة اختيار عنوان خارج نطاق التوصيل مع إشعار المستخدم.
10. **`lib/modules/customer/widgets/addresses/address_card.dart` (معدل)**
    - إضافة شارة تحذيرية فاخرة "خارج التغطية" باللون الأحمر عند عدم قابلية العنوان للتوصيل.
11. **`lib/core/bindings/initial_binding.dart` و `lib/modules/customer/bindings/addresses_binding.dart` (معدل)**
    - تسجيل `IAddressesRepository` وحقنه في التبعيات العامة والخاصة بشاشة العناوين.
12. **`test/network_and_repositories_test.dart` (معدل)**
    - إضافة 4 اختبارات متكاملة لمستودع العناوين ونموذج `ShippingAddress` والتغطية الجغرافية.

---

## 3. مسارات API المنفذة (Implemented Endpoints)

| المسار (Endpoint) | الطريقة (Method) | المصادقة (Auth) | الوصف |
| :--- | :--- | :--- | :--- |
| `/api/v1/customer/addresses` | `GET` | `auth:sanctum` | جلب كافة عناوين العميل المصادق مرتبة حسب العنوان الافتراضي أولاً ثم الأحدث |
| `/api/v1/customer/addresses` | `POST` | `auth:sanctum` | إضافة عنوان جديد مع التحقق الجغرافي وتعيين الافتراضي إذا كان الأول |
| `/api/v1/customer/addresses/{id}` | `GET` | `auth:sanctum` | جلب تفاصيل عنوان محدد مع التحقق الصارم من ملكية العميل له |
| `/api/v1/customer/addresses/{id}` | `PUT` | `auth:sanctum` | تعديل العنوان وإعادة حساب نطاق التغطية الجغرافية وحالة الافتراضي |
| `/api/v1/customer/addresses/{id}` | `DELETE` | `auth:sanctum` | حذف العنوان وترقية العنوان التالي ليكون افتراضياً إذا حُذف الرئيسي |
| `/api/v1/customer/addresses/{id}/primary` | `PATCH` | `auth:sanctum` | تعيين العنوان كعنوان افتراضي وإلغاء صفة الافتراضي عن العناوين السابقة |
| `/api/v1/geo/governorates` | `GET` | عام (Public) | استعلام المحافظات النشطة مع دعم الفلترة بالدولة |
| `/api/v1/geo/districts` | `GET` | عام (Public) | استعلام المديريات النشطة مع دعم الفلترة بالمحافظة |

---

## 4. عقود الطلب والاستجابة (Request & Response Contracts)

### أ. إنشاء عنوان جديد (`POST /api/v1/customer/addresses`)
#### Request:
```json
{
  "label": "المنزل",
  "address": "صنعاء - حي حدة - شارع الستين الجنوبي، عمارة الأمل",
  "contact_name": "أحمد الشامي",
  "contact_phone": "777123456",
  "country_id": 1,
  "governorate_id": 1,
  "district_id": 3,
  "latitude": 15.3450,
  "longitude": 44.1850,
  "is_primary": true
}
```

#### Response (`201 Created`):
```json
{
  "message": "تمت إضافة العنوان بنجاح.",
  "data": {
    "id": "105",
    "label": "المنزل",
    "description": "صنعاء - حي حدة - شارع الستين الجنوبي، عمارة الأمل",
    "address": "صنعاء - حي حدة - شارع الستين الجنوبي، عمارة الأمل",
    "contact_phone": "777123456",
    "contact_name": "أحمد الشامي",
    "country_id": 1,
    "governorate_id": 1,
    "district_id": 3,
    "country": "اليمن",
    "country_name": "اليمن",
    "city": "أمانة العاصمة",
    "governorate_name": "أمانة العاصمة",
    "postcode": "الوحدة",
    "district_name": "الوحدة",
    "latitude": 15.345,
    "longitude": 44.185,
    "is_primary": true,
    "is_default": true,
    "isDefault": true,
    "is_serviceable": true,
    "coverage_status": "in_district",
    "delivery_tier": {
      "tier": 1,
      "name": "حي حدة والسبعين",
      "radius": 5000,
      "price": 1000
    },
    "boundary_checked_at": "2026-11-08T20:00:00+03:00"
  }
}
```

### ب. خطأ عدم تطابق المديرية مع المحافظة (`422 Unprocessable Entity`):
```json
{
  "message": "المديرية المحددة لا تنتمي إلى هذه المحافظة.",
  "errors": {
    "district_id": [
      "المديرية المحددة لا تنتمي إلى هذه المحافظة."
    ]
  }
}
```

### ج. محاولة الوصول لعنوان يخص مستخدماً آخر (`404 Not Found`):
```json
{
  "message": "العنوان غير موجود أو لا تملك صلاحية الوصول إليه."
}
```

---

## 5. قواعد ملكية البيانات والأمان الجغرافي

1. **عزل الصلاحيات ومنع ثغرات IDOR:**
   - لا يقبل الكنترولر أي `customer_id` قادم من جسد الطلب أو الاستعلام.
   - يعتمد حصرياً على هوية المستخدم من التوكن: `$user = $request->user();`.
   - الاستعلام يتم دائماً عبر علاقة العناوين الخاصة بالعميل: `$user->addresses()->find($id)`.
   - عند محاولة الوصول لعنوان لا يملكه المستخدم، تعاد استجابة `404` بدلاً من `403` لحجب وجود السجل ومنع هجمات التخمين وتعداد المعرفات (User Enumeration).
2. **استخدام خدمة `GeoCoverageService` كمصدر وحيد للحقيقة:**
   - الحقول الحساسة `is_serviceable` و `coverage_status` و `delivery_tier` يتم تجريدها واستبعادها بالكامل من أي مدخلات عميل.
   - يتم حساب التغطية عبر `GeoCoverageService::applyCoverageToAddress($address)` التي تطبق خوارزمية **Ray-Casting Algorithm** على المضلعات الجغرافية والدوائر وحلقات التسعير، مما يمنع التلاعب برسوم التوصيل أو قابلية الخدمة.
3. **سلامة المعاملات المتزامنة للعنوان الافتراضي:**
   - جميع عمليات تعديل أو حذف أو تعيين العنوان الافتراضي تجري داخل `DB::transaction`.
   - عند ترقية أي عنوان ليكون افتراضياً، يتم إزالة الصفة عن كافة عناوين العميل الأخرى فوراً لضمان عدم وجود أكثر من عنوان افتراضي في أي لحظة.

---

## 6. نتائج اختبارات Pest (Laravel Backend)

تم تشغيل الاختبارات باستخدام قاعدة بيانات اختبار SQLite منعزلة في الذاكرة عبر الأمر:  
`php artisan test --filter="PublicCatalogApiTest|CustomerAddressApiTest"`

```text
   PASS  Tests\Feature\Customer\CustomerAddressApiTest
  ✓ it rejects unauthenticated requests to customer addresses endpoints with 401
  ✓ it returns only authenticated customer addresses ordered by is_primary desc
  ✓ it handles empty customer addresses gracefully without errors
  ✓ it creates a new address and automatically marks first address as primary
  ✓ it creates a second address without is_primary and leaves the first address as primary
  ✓ it sets new address as primary and unsets primary from previous address
  ✓ it validates required address fields and rejects invalid data with 422
  ✓ it validates district and governorate consistency and rejects mismatch with 422
  ✓ it applies geographic coverage validation via GeoCoverageService and strips client-provided is_serviceable
  ✓ it marks address out_of_coverage when coordinates are outside serviceable areas
  ✓ it shows single address details for owner and returns 404 for another user
  ✓ it updates address data and recalculates geographic coverage
  ✓ it prevents user from updating another users address with 404
  ✓ it deletes address and promotes next address to primary if deleted address was primary
  ✓ it deletes the only address leaving empty list cleanly
  ✓ it prevents user from deleting another users address with 404
  ✓ it sets primary address via dedicated PATCH route and unsets previous primary
  ✓ it prevents setting primary on another users address with 404

   PASS  Tests\Feature\Shop\PublicCatalogApiTest
  ✓ it lists published products only and hides inactive or draft products (15 tests)

  Tests:    33 passed (197 assertions)
  Duration: 12.93s
```

---

## 7. نتائج اختبارات Flutter Frontend

### أ. فحص الأكواد والتوافق (`flutter analyze`):
```text
Analyzing rwnaqk_frontend...
No issues found! (ran in 9.9s)
```

### ب. اختبارات الوحدات والواجهات والمستودعات (`flutter test`):
```text
00:17 +49: All tests passed!
```
- اجتياز جميع اختبارات فلاتر الـ 49 بالكامل بنجاح.
- التحقق من عمل `AddressesRepositoryImpl` في وضع Mock ووضع Live API.
- التحقق من تفعيل التوكن والتنصت وتمرير الأخطاء دون Fallback صامت.

---

## 8. المشكلات المكتشفة والإصلاحات المطبقة

| المشكلة | الأثر | الحل المطبق |
| :--- | :--- | :--- |
| **غياب دالة `patch` في `ApiClient`** | عدم إمكانية استدعاء مسار تعيين العنوان الافتراضي `PATCH /primary`. | تمت إضافة دالة `patch<T>` كاملة في `ApiClient` مع معالجة أخطاء الشبكة والتوكن. |
| **غياب التغطية عند عدم توفر إحداثيات GPS** | في حال اختيار العميل المحافظة والمديرية فقط بدون خريطة، كانت خدمة التغطية تترك الحقول فارغة. | تم تطوير `applyCoverageToAddress` لتفحص حالة نشاط المحافظة والمديرية وحلقات التسعير المرتبطة بها في حال كانت الإحداثيات فارغة. |
| **احتمال عدم تطابق المحافظة والمديرية** | العميل قد يرسل محافظة معينة مع مديرية تابعة لمحافظة أخرى. | إضافة قاعدة تحقق تلقائية في `StoreCustomerAddressRequest` ترفض التناقض وتعيد كود `422`. |
| **التفاف الـ JSON في استجابات العناوين** | كان موديل `AddressResource` يستخدم `$wrap = 'address'` مما سبب تعارضاً مع توحيد استجابة `data`. | تم ضبط `public static $wrap = null;` وتوحيد الاستجابات وفق معيار `{"data": ...}`. |

---

## 9. الأعمال المؤجلة إلى المرحلة 4.4 (Phase 4.4)

المرحلة القادمة ستكون مخصصة لـ:
1. **Cart Quote API:**
   - احتساب إجمالي السلة بناءً على المنتجات والخيارات ومخزونها اللحظي.
2. **Dynamic Shipping Calculation:**
   - حساب تكلفة الشحن الفعلية بناءً على العنوان المختار (`governorate_id`, `district_id`, `delivery_tier`) ووزن السلة.
3. **Coupon Validation:**
   - تطبيق كوبونات الخصم والتحقق من صلاحيتها وحدودها الزمنية والمادية.

---

## 10. معيار الجاهزية (Readiness Decision)

- **حالة منظومة العناوين والتغطية الجغرافية:** مكتملة وجاهزة للإنتاج بنسبة **100%**.
- **جاهزية الانتقال إلى Phase 4.4:** **معتمدة بالكامل (GO).**
