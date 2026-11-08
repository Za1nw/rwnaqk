# دليل جاهزية المعمارية والانتقال المستقبلي (GetX Portability Guide)

**المبدأ الأساسي:** استخدام GetX اليوم للإطلاق السريع والآمن خلال 7–14 يومًا، مع حماية حدود الأعمال وطبقة البيانات لتمكين الانتقال إلى Riverpod أو BLoC مستقبلاً بأقل كلفة برمجية.

---

## 1. خريطة الحدود المعمارية (Architectural Boundaries)

```text
┌────────────────────────────────────────────────────────────────────────┐
│ 1. Presentation Layer (خاص بـ GetX حالياً - قابل للاستبدال مستقبلاً)    │
│    - Flutter Screens & Widgets (تعتمد على القيم الصرفة والأحداث)        │
│    - GetxController / Presentation Adapters                            │
│      (يدير RxBool, RxList, Obx, TextEditingControllers, ومؤشرات التحميل)│
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Constructor Injection (عقود مجردة)
┌───────────────────────────────────▼────────────────────────────────────┐
│ 2. Domain Layer (Pure Dart - خالٍ تماماً من أي إشارة لـ GetX)          │
│    - Entities / Data Models (HomeProductItem, OrderModel, Customer)    │
│    - Repository Contracts (IAuthRepository, IProductsRepository...)    │
│    - Pure Domain Exceptions / Failures                                 │
└───────────────────────────────────▲────────────────────────────────────┘
                                    │ يعتمد ويطبق
┌───────────────────────────────────┴────────────────────────────────────┐
│ 3. Data Layer (Pure Dart - قابل لإعادة الاستخدام بنسبة 100% مع أي مدير)│
│    - Network Client: Dio + Interceptors                                │
│    - Repository Implementations (تتواصل مع Laravel REST API)           │
│    - DTOs & JSON Deserializers                                         │
│    - Local Storage Contracts (SharedPreferences / Secure Storage)      │
└────────────────────────────────────────────────────────────────────────┘
```

---

## 2. القواعد الصارمة لعزل GetX (Strict Isolation Rules)

### القاعدة 1: حظر استيراد GetX في طبقات البيانات والأعمال
* **المسارات الممنوعة:**
  - `lib/data/**`
  - `lib/domain/**`
  - `lib/core/network/**`
  - `lib/core/errors/**`
* **الممنوعات:**
  - يمنع منعاً باتاً استيراد `package:get/get.dart` أو أي جزء منه.
  - يمنع استخدام المتغيرات التفاعلية `Rx<T>`, `RxList<T>`, `Rxn<T>` أو `.obs` داخل الـ Repositories أو الـ Data Models.
  - يمنع استخدام `Get.find()`, `Get.to()`, `Get.snackbar()`, `Get.dialog()` داخل طبقة البيانات.
  - يمنع إرجاع `GetConnect.Response` في أي عقد أو مستودع.

### القاعدة 2: حصر GetX في طبقة العرض وحقن التبعيات
* يُسمح باستخدام GetX حصراً في:
  - `lib/modules/*/views/**`
  - `lib/modules/*/controllers/**`
  - `lib/modules/*/bindings/**`
  - `lib/routes/**`
* الكنترولر يعمل كـ **Presentation Adapter**:
  - يستقبل المستودع النقي `Repository` عبر المشيد (`Constructor Injection`).
  - يستدعي المستودع عبر `Future` نقي.
  - يقوم بتحديث متغيراته التفاعلية `Rx` لتعكس حالة الواجهة (`isLoading.value = true`, `items.assignAll(...)`).

### القاعدة 3: الـ Bindings هي نقطة التركيب الوحيدة (Composition Root)
* المكان الوحيد المسموح له باستدعاء `Get.find()` لربط الاعتماديات هو ملفات الـ `Bindings`.
* مثال على التكوين الصحيح للمستودع والكنترولر:
  ```dart
  class ProductsListingBinding extends Bindings {
    @override
    void dependencies() {
      // 1. حقن المستودع النقي (يمكن لاحقاً استبداله بـ Provider في Riverpod)
      Get.lazyPut<IProductsRepository>(
        () => ProductsRepositoryImpl(Get.find<ApiClient>()),
        fenix: true,
      );
      
      // 2. حقن الكنترولر مع تمرير المستودع في المشيد
      Get.lazyPut<ProductsListingController>(
        () => ProductsListingController(Get.find<IProductsRepository>()),
        fenix: true,
      );
    }
  }
  ```

---

## 3. تصحيح أنماط GetX الحالية (Refining GetX Usage)

### 3.1. التخلص من الاعتماد على `GetConnect`
* **الوضع الحالي:**
  `CustomerAuthApiService` يرث من `GetConnect` ويعيد استجابات خاصة بـ GetX:
  ```dart
  class CustomerAuthApiService extends GetConnect { ... }
  ```
* **خطة التصحيح دون لمس الواجهات:**
  1. إنشاء عميل الشبكة النقي `ApiClient` المعتمد على `Dio` في `lib/core/network/api_client.dart`.
  2. إنشاء `AuthRepositoryImpl` الذي يستخدم `Dio` ويعيد كائنات Dart النقية (`CustomerModel`, `AuthResult`).
  3. تعديل `CustomerAuthApiService` أو توجيهه لاستخدام `AuthRepositoryImpl` داخلياً، بحيث لا يتأثر `LoginController` ولا تنكسر أي شاشة في التطبيق.

### 3.2. تحسين نطاق إعادة البناء في `Obx` (Scoping Rebuilds)
* **المشكلة الحالية:**
  في [product_details_view.dart:34](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/catalog/views/product_details_view.dart#L34):
  يتم تغليف الـ `Scaffold` كاملاً بكتلة `Obx`:
  ```dart
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        appBar: _ProductDetailsAppBar(...),
        bottomNavigationBar: _BottomBar(...),
        body: ListView(...),
      );
    });
  }
  ```
  هذا النمط يؤدي إلى:
  - إعادة بناء شجرة الـ Widgets بالكامل (شريط التطبيق، المعرض، كروت المواصفات، المراجعات، القوائم) عند تغيير متغير فرعي مثل عداد الكمية (`quantity`) أو الصورة المصغرة (`selectedThumb`).
  - فقدان موضع السكرول ومسح كاش الصور أثناء التفاعل السريع.
* **النمط المستهدف المحايد:**
  حصر `Obx` في الودجتات التفاعلية الدقيقة فقط:
  - شريط التطبيق: `Obx` صغير حول أيقونة المفضلة وعداد السلة.
  - الكارت الرئيسي: `Obx` حول منتقي الألوان والمقاسات.
  - الشريط السفلي: `Obx` حول زر الإضافة وإجمالي السعر.
  هذا التغيير يحسن أداء الرسم على أجهزة الفئات المتوسطة والضعيفة بنسبة تتجاوز 40%.

---

## 4. سيناريو الانتقال المستقبلي (Future Migration Playbook)

عند الرغبة في الانتقال إلى **Riverpod** أو **BLoC** بعد إطلاق المتجر واستقراره:

1. **ما الذي سيبقى دون تغيير بنسبة 100%؟**
   - كافة كلاسات الـ Models والـ Entities والـ DTOs.
   - كافة ملفات الـ Repositories وواجهات البيانات (`lib/data/`).
   - كود شبكة الاتصال بالكامل `Dio` والـ Interceptors.
   - قواعد التحقق من صحة المدخلات والحسابات المالية.
   - اختبارات الوحدة المنطقية الصرفة (Pure Unit Tests).

2. **ما الذي سيتم تغييره فقط؟**
   - استبدال `GetxController` بـ `Notifier` (في Riverpod) أو `Cubit / Bloc` (في BLoC).
   - استبدال `Obx(() => ...)` بـ `Consumer` أو `BlocBuilder`.
   - استبدال `Bindings` بـ `ProviderScope` أو `MultiBlocProvider`.
   - استبدال التنقل عبر `Get.toNamed` بـ `GoRouter` أو `AutoRoute`.

> [!TIP]
> بفضل عزل `data/domain` المخطط له الآن، ستتحول عملية الترحيل المستقبلية من إعادة كتابة كاملة للمشروع إلى مجرد استبدال طبقة العرض (View Adapters) دون أي مخاطرة بتعطيل قواعد التجارة أو تكامل السيرفر.

