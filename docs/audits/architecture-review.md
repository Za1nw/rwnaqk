# تقرير التدقيق المعماري الشامل — متجر رونقك (Architecture Review)

**التاريخ:** 2026-11-08  
**الإصدار:** 1.0.0-production-audit  
**النطاق:** تطبيق Flutter (GetX) + تكامل Laravel API  
**الهدف:** إطلاق متجر آمن ومستقر خلال 7–14 يومًا مع ضمان استقلالية طبقة البيانات (`data/domain`) عن GetX لتسهيل الانتقال المستقبلي إلى Riverpod/BLoC.

---

## 1. ملخص تنفيذي (Executive Summary)

تم فحص الكود المصدري للمشروع بالكامل قراءةً فقط، مع التحقق الميداني من ملفات الواجهة الأمامية (`lib/`) وملفات الواجهة الخلفية المكتشفة في المسار المجاور (`../rwnaqk-backend/`). 

### النتائج الرئيسية:
1. **واجهات المستخدم (UI):** مكتملة بنسبة 95% وذات جودة تصميمية عالية، ومتوافقة مع نظام الترجمة العربية ونظام الثيمات (Light/Dark).
2. **جاهزية GetX:** مستقرة في طبقة العرض، لكنها تعاني من بعض تسريبات دورة الحياة (`ever` Workers بدون `onClose`) واعتمادات دائرية في مسار الطلب، إضافة إلى تعشيش زائد في بعض كتل `Obx`.
3. **تكامل Laravel API:** واجهات المصادقة (`/api/v1/customer/auth/*`) وواجهات العناوين الجغرافية (`/api/v1/geo/*`) مكتملة ومطابقة في Backend، بينما مسارات المنتجات والسلة والطلبات للعملاء (`Customer-Facing APIs`) غير معرّفة في مسار الـ API العام وتتطلب تدخلاً سريعاً في Backend خلال أول يومين.
4. **سلامة المعاملات التجارية (Commerce Integrity):** مسار الدفع الحالي ينقصه حارس النقر المزدوج الصارم، ومفتاح عدم التكرار (`X-Idempotency-Key`)، والتأكيد السحابي للأسعار والمخزون.

---

## 2. جدول تصنيف ومراجعة النتائج المعمارية (Audit Findings Verification)

تمت إعادة تقييم جميع الملاحظات المرصودة مسبقاً وتصنيفها بدقة وفق الدليل الفعلي من الكود:

| # | الملاحظة المعمارية | الملف والسطر | التصنيف | مستوى الخطورة | التأثير |
|---|---|---|---|---|---|
| 1 | عدم تحرير Worker مراقبة العناوين | `lib/modules/cart/controllers/cart_controller.dart:467` | **Confirmed Issue** | **HIGH** | تسرب ذاكرة وتكرار استجابة الأحداث عند إعادة تعيين الجلسة أو الاختبارات |
| 2 | عدم تحرير Worker مراقبة حسابات المحافظ | `lib/modules/checkout/controllers/payment_controller.dart:196` | **Confirmed Issue** | **HIGH** | بقاء المستمع معلقاً في الذاكرة دون `onClose` |
| 3 | غياب حارس النقر المزدوج في تأكيد الطلب | `lib/modules/checkout/controllers/payment_controller.dart:166` | **Confirmed Issue** | **P0 (CRITICAL)** | خطر تكرار خصم المحفظة أو إنشاء طلبين متطابقين عند النقر السريع |
| 4 | الاعتماد الدائري بين Cart و Payment | `lib/modules/cart/controllers/cart_controller.dart:420,449` بالتكامل مع `payment_controller.dart:173` | **Confirmed Issue** | **HIGH** | تعقيد التتبع البرمجي وصعوبة عزل واختبار مسار الدفع |
| 5 | عدم تصفير السلة والعناوين عند تسجيل الخروج | `lib/modules/customer/controllers/app_settings_controller.dart:200` | **Confirmed Issue** | **P0 (SECURITY)** | انتهاك خصوصية: بقاء بيانات العميل السابق معروضة للمستخدم الجديد |
| 6 | دمج متغيرات المنتج في سطر واحد بالسلة | `lib/modules/cart/controllers/cart_controller.dart:367` | **Confirmed Issue** | **P1 (COMMERCE)** | مسح خيارات المقاس/اللون عند إضافة نفس المنتج بمتغيرين مختلفين |
| 7 | عدم حذف مستمع السكرول في قائمة المنتجات | `lib/modules/catalog/controllers/products_listing_controller.dart:75` | **Confirmed Issue** | **MEDIUM** | استهلاك ذاكرة واحتمال انهيار ScrollController عند إعادة فتح الشاشة |
| 8 | اعتماد خدمات الشبكة على `GetConnect` | `lib/core/services/auth/customer_auth_api_service.dart:40` | **Confirmed Issue** | **P1 (PORTABILITY)** | تسرب أنواع GetX إلى طبقة البيانات وعرقلة الانتقال إلى BLoC/Riverpod |
| 9 | ملفات مستودعات الكتالوج فارغة (0 بايت) | `lib/modules/catalog/data/repositories/products_repository.dart` | **Confirmed Issue** | **P1 (DATA)** | توقف شاشات الكتالوج عند إيقاف البيانات التجريبية |
| 10 | تعشيش كتل `Obx` في شاشتي المنتج والدفع | `lib/modules/catalog/views/product_details_view.dart:34,150,278` | **Potential Risk** | **LOW/MEDIUM** | إعادة بناء الـ Scaffold بالكامل عند أي تحديث تفاعلي بسيط؛ لا تسبب عطلاً برمجياً فورياً |
| 11 | حفظ توكن الدخول بنص غير مشفر | `lib/core/services/auth/auth_session_service.dart:140` | **Potential Risk** | **MEDIUM** | استخدام SharedPreferences بدلاً من Keystore/Keychain؛ مقبول للإطلاق الأولي إذا فُعل التشفير لاحقاً |
| 12 | غياب `onClose()` في المتحكمات الخالية من الموارد | `lib/modules/home/controllers/home_controller.dart` | **False Positive** | **NONE** | الكنترولر لا يملك Stream أو Worker أو FocusNode وبالتالي عدم وجود `onClose` ليس تسريباً |
| 13 | فرض أن عدم الربط بالـ API يعني نقص الموديلز | `lib/data/models/api_response_model.dart` | **False Positive** | **NONE** | بنية مغلفات الـ API والـ Pagination جاهزة ونقية ولا تتطلب إعادة بناء |

---

## 3. التحليل المعماري التفصيلي للمشكلات المؤكدة

### 3.1. تسريبات Workers ودورة حياة الكنترولرات
* **الواقع البرمجي:**
  في `CartController`:
  ```dart
  ever<List<dynamic>>(_profileStore.addresses, (_) {
    shippingAddress.value = _service.seedShippingAddress();
    fillShippingFormFromState();
  });
  ```
  وفي `PaymentController`:
  ```dart
  ever<List<WalletTransferAccount>>(walletAccounts, (accounts) { ... });
  ```
* **المشكلة:**
  دالة `ever` تُنشئ `Worker` يستمع لمجرى بيانات تفاعلي خارجي (`_profileStore.addresses`). نظراً لأن `CartController` مسجل كـ `permanent: true` في `InitialBinding`، فإن المستمع لا يُمحى أبداً طوال دورة تشغيل التطبيق. وإذا أُعيد استدعاء `InitialBinding` أو تم تنفيذ `Get.reset()` في بيئة الاختبار، يظل الـ Worker نشطاً ومحكوماً بكائنات قديمة في الذاكرة.
* **الحل الأدنى المطلوب:**
  تعريف كائن العامل وتفريغه داخل `onClose()`:
  ```dart
  Worker? _addressWorker;
  
  @override
  void onInit() {
    super.onInit();
    _addressWorker = ever<List<dynamic>>(_profileStore.addresses, (_) { ... });
  }

  @override
  void onClose() {
    _addressWorker?.dispose();
    super.onClose();
  }
  ```

---

### 3.2. مشكلة الاعتماد الدائري في مسار الدفع
* **الواقع البرمجي:**
  1. شاشة التأكيد تستدعي `PaymentController.confirmAndSubmitOrder()`.
  2. دالة `confirmAndSubmitOrder()` تستدعي `CartController.payNow()`.
  3. دالة `payNow()` داخلياً تستدعي:
     ```dart
     final payment = Get.find<PaymentController>();
     if (payment.isWalletPayment) { ... }
     final order = _service.buildCheckoutOrder(... paymentMethodKey: payment.paymentMethodLabel ...);
     Get.find<OrdersController>().addOrder(order);
     ```
* **المشكلة:**
  تشابك غير مبرر يجعل السلة مسؤولة عن معرفة تفاصيل الدفع وإنشاء الطلب وتخزينه في قائمة الطلبات، مما يمنع فصل مسار الدفع إلى معالج مستقل (Checkout Flow).
* **الحل الأدنى المطلوب:**
  نقل مسؤولية إرسال الطلب وحالته إلى `PaymentController` الذي يستلم سلة المنتجات كمدخلات خالصة (`DTO`)، ويرسلها إلى مستودع الطلبات `IOrdersRepository`، وبمجرد تأكيد الخادم يطلب من `CartController` إفراغ السلة محلياً عبر `cart.clearCart()`.

---

### 3.3. عزل الجلسة وأمان بيانات المستخدم
* **الواقع البرمجي:**
  في `AppSettingsController`:
  ```dart
  Future<void> logout() async {
    ...
    _authSession.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
  ```
* **المشكلة:**
  `AuthSessionService.clearSession()` تقوم فقط بتصفير التوكن والمتغير `customer.value`. ولكن:
  - `CartController.cartItems` تظل ممتلئة بعناصر المستخدم السابق.
  - `ProfileStoreService.addresses` تظل محتفظة بعناوين ومواقع المستخدم السابق.
  - `OrdersController.orders` تظل محتفظة بطلبات وتفاصيل فواتير المستخدم السابق.
  - في حال قام مستخدم جديد بتسجيل الدخول أو استخدم زائر نفس الهاتف، يتم عرض معلومات العميل السابق فوراً.
* **الحل الأدنى المطلوب:**
  توسيع دالة `clearSession()` أو دالة `logout()` لتشمل:
  ```dart
  if (Get.isRegistered<CartController>()) Get.find<CartController>().clearCart();
  if (Get.isRegistered<OrdersController>()) Get.find<OrdersController>().orders.clear();
  if (Get.isRegistered<ProfileStoreService>()) Get.find<ProfileStoreService>().addresses.clear();
  ```

---

## 4. المبادئ المعمارية المعتمدة للإطلاق (7–14 يوماً)

1. **الاستقرار أولاً (Zero-Breakage UI):** لا يتم تغيير أي اسم كائن أو دالة عامة مستخدمة في واجهات العرض الحالية.
2. **عزل النواة (Pure Core):** لا يجوز لأي كلاس داخل `lib/data/` أو `lib/domain/` أن يستورد `package:get/get.dart` أو يستخدم `Rx` أو `Get.find`.
3. **تدرج الحقن (Constructor Injection):** يتم حقن الـ Repositories في مشيدات الـ Controllers داخل ملفات الـ `Bindings`، مع اعتبار الـ `Bindings` هي منطقة التكوين الوحيدة المسموح لها باستدعاء `Get.find()`.
4. **سلطة الخادم (Server Authority):** لا يعتمد التطبيق على الحسابات الرياضية المحلية للخصومات والشحن إلا كعرض تقديري، ويكون الاعتماد النهائي على استجابة الخادم السحابي (`Server Quote`).

