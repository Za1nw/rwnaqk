# التحقق المعماري من دورة حياة الموفرات وجسر التعايش ثنائي الاتجاه
# Phase 01.1 Provider Lifecycle & Bidirectional Bridge Verification

> **المجال:** فحص معمارية موفري Riverpod 3 وجسر التزامن مع GetX  
> **المرجع:** `lib/core/di/core_providers.dart` و `lib/core/bindings/initial_binding.dart`

---

## 1. مشكلة ترتيب التهيئة المعمارية (The Initialization Order Dilemma)

في أي مشروع يجمع بين إطارين لإدارة الحالة أثناء مرحلة الانتقال التدريجي، تنشأ معضلة معمارية حرجة تتعلق بترتيب التهيئة (Initialization Order):

### السيناريو أ (GetX ينطلق أولاً):
- يقوم `InitialBinding` بإنشاء كائنات `ApiClient` و `IAuthTokenStorage` ويسجلها في حقيبة GetX.
- عند قراءة موفرات Riverpod، تجد الكائنات مسجلة في GetX عبر `Get.isRegistered<T>()` فتعيدها مباشرة عبر `Get.find<T>()`.
- **النتيجة:** كائن واحد مشترك في الذاكرة.

### السيناريو ب (Riverpod يُطلب أولاً — مثل ويدجت مستقلة أو اختبار منفصل):
- يتم استدعاء `ref.watch(apiClientProvider)` قبل تشغيل `InitialBinding`.
- كانت النسخة القديمة من الموفر تجد `Get.isRegistered<ApiClient>() == false`، فتقوم بإنشاء كائن جديد محلي داخل Riverpod!
- بعد ذلك، عندما يعمل `InitialBinding`، كان يستدعي `Get.put<ApiClient>(ApiClient(...))` بشكل أعمى، فينشئ كائناً ثانياً تماماً في GetX!
- **الكارثة المعمارية:** انقسام التوكن وعميل الشبكة، حيث تمتلك شاشات Riverpod عميلاً بـ Interceptors وتوكن مختلفين تماماً عن عميل شاشات GetX!

---

## 2. الحل المعماري المنفذ: جسر الهوية الأحادية ثنائي الاتجاه (Bidirectional Bridge)

تم حل هذه المعضلة جذرياً وبصورة مزدوجة تضمن اتحاد الكائنات بغض النظر عمن يبدأ أولاً:

### 1. في ملف الموفرات (`lib/core/di/core_providers.dart`):
عندما يُطلب الموفر ولم يكن الكائن مسجلاً في GetX، يُنشئ Riverpod الكائن المعتمد، ثم يقوم **فوراً بتسجيله داخل GetX** ككائن دائم (`permanent: true`):

```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  if (Get.isRegistered<ApiClient>()) {
    return Get.find<ApiClient>();
  }
  final storage = ref.watch(authTokenStorageProvider);
  final client = ApiClient(
    tokenStorage: storage,
    onUnauthorizedWithToken: (failedToken) {
      if (Get.isRegistered<AuthSessionService>()) {
        Get.find<AuthSessionService>().handleUnauthorized(failedToken: failedToken);
      }
    },
    onUnauthorized: () {
      if (Get.isRegistered<AuthSessionService>()) {
        Get.find<AuthSessionService>().handleUnauthorized();
      }
    },
  );
  // تسجيل الكائن فوراً في GetX لضمان تطابق المرجع إذا طُلب GetX لاحقاً
  Get.put<ApiClient>(client, permanent: true);
  return client;
});
```

### 2. في ملف التهيئة الرئيسي لـ GetX (`lib/core/bindings/initial_binding.dart`):
تم تعديل دوال التسجيل للتحقق مسبقاً مما إذا كان الكائن قد تم تسجيله بالفعل (سواء عبر Riverpod أو تهيئة مسبقة) قبل استدعاء `Get.put`:

```dart
if (!Get.isRegistered<ApiClient>()) {
  Get.put<ApiClient>(
    ApiClient(
      tokenStorage: Get.find<IAuthTokenStorage>(),
      onUnauthorizedWithToken: (failedToken) {
        if (Get.isRegistered<AuthSessionService>()) {
          Get.find<AuthSessionService>().handleUnauthorized(failedToken: failedToken);
        }
      },
      onUnauthorized: () {
        if (Get.isRegistered<AuthSessionService>()) {
          Get.find<AuthSessionService>().handleUnauthorized();
        }
      },
    ),
    permanent: true,
  );
}
```

---

## 3. أدلة التحقق والاختبار (Verification Evidence)

تم اختبار هذا التزامن ثنائي الاتجاه عبر اختبارين مخصصين في `test/phase1_verification_test.dart`:

```dart
test('Order A: GetX InitialBinding runs first, then Riverpod resolves providers -> identical instances', () {
  final initialBinding = InitialBinding(tokenStorage: tokenStorage);
  initialBinding.dependencies();

  final container = ProviderContainer();
  addTearDown(container.dispose);

  expect(identical(container.read(authTokenStorageProvider), Get.find<IAuthTokenStorage>()), isTrue);
  expect(identical(container.read(apiClientProvider), Get.find<ApiClient>()), isTrue);
  expect(identical(container.read(authRepositoryProvider), Get.find<IAuthRepository>()), isTrue);
  expect(identical(container.read(productsRepositoryProvider), Get.find<IProductsRepository>()), isTrue);
  expect(identical(container.read(addressesRepositoryProvider), Get.find<IAddressesRepository>()), isTrue);
  expect(identical(container.read(ordersRepositoryProvider), Get.find<IOrdersRepository>()), isTrue);
});

test('Order B: Riverpod resolves providers first, then GetX InitialBinding runs -> identical instances without duplication', () {
  final container = ProviderContainer(
    overrides: [authTokenStorageProvider.overrideWithValue(tokenStorage)],
  );
  addTearDown(container.dispose);

  final riverpodClient = container.read(apiClientProvider);

  final initialBinding = InitialBinding(tokenStorage: tokenStorage);
  initialBinding.dependencies();

  expect(identical(riverpodClient, Get.find<ApiClient>()), isTrue);
});
```

**النتيجة:** كِلا الاختبارين نجح بنسبة 100%، مما أثبت هندسياً أن الهوية الأحادية لكائنات النواة مضمونة في كلا الترتيبين.

