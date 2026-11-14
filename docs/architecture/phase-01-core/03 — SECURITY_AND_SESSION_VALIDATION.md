# التحقق الأمني واستقرار الجلسات وتطهير الكاش
# Security & Session Validation — 401 Flow & Logout Isolation

## 1. الثغرات المعمارية التي تم رصدها في التدقيق (Phase 00 Audit)

خلال تدقيق المرحلة 00، تم تشخيص ثلاث فجوات أمنية وتشغيلية حرجة في النواة:
1. **انقطاع مسار رد النداء لـ HTTP 401 (Broken 401 Callback Path):**
   - كان `ApiClient` يدعم في معامله الاختياري رد نداء `onUnauthorized` لمعالجة أخطاء 401 من خادم Laravel.
   - ولكن في ملف التجميع الرئيسي `lib/core/bindings/initial_binding.dart`، تم إنشاء `ApiClient` دون تمرير هذا المعامل! مما أدى إلى تجاهل انتهاء صلاحية التوكن مركزياً، وعدم طرد المستخدم المنتهية جلسته أو مسح بياناته.
2. **سباق التزامن عند ورود استجابات 401 متعددة (Concurrent 401 Race Condition):**
   - عند فتح شاشة معقدة تطلق عدة طلبات متزامنة (مثل تفاصيل السلة، عناوين المستخدم، وسجل الطلبات)، يؤدي انتهاء الصلاحية إلى إرجاع 3 أو 4 أخطاء 401 في نفس اللحظة، مما كان سيتسبب في استدعاءات متكررة لمسح التوكن، وتوجيهات تنقل متعاقبة قد تدخل التطبيق في حلقة مفرغة (Infinite Navigation Loop).
3. **تسرب حالة المفضلة بين الحسابات عند تسجيل الخروج (Wishlist State Leakage):**
   - في دالة `_clearLocalUserData()` داخل `AppSettingsController`، كان يتم تطهير السلة والطلبات والعناوين، ولكن تم إغفال `WishlistController` بالكامل!
   - هذا كان يؤدي إلى بقاء منتجات المفضلة الخاصة بالمستخدم السابق معروضة للمستخدم الجديد أو الزائر التالي.

---

## 2. الحلول الهندسية المنفذة في المرحلة 01

### أولاً: تأمين وإحكام معالج 401 في `AuthSessionService`
تم تحديث كلاس `AuthSessionService` بإضافة قفل تزامن ذري ودورة معالجة آمنة:

```dart
bool _isHandlingUnauthorized = false;
void Function()? onSessionTerminated;

Future<void> handleUnauthorized() async {
  if (_isHandlingUnauthorized) return;
  _isHandlingUnauthorized = true;

  try {
    await _tokenStorage.clearToken();
    token.value = null;
    _isAuthenticated.value = false;

    onSessionTerminated?.call();

    // توجيه المستخدم لصفحة تسجيل الدخول بأمان إذا لم يكن فيها بالفعل
    if (Get.currentRoute != AppRoutes.login) {
      Get.offAllNamed(AppRoutes.login);
    }
  } finally {
    _isHandlingUnauthorized = false;
  }
}
```

### ثانياً: ربط مسار 401 وتطهير الكاش في `InitialBinding`
تم تحديث `InitialBinding` ليقوم بـ:
1. تمرير `onUnauthorized: () => authSession.handleUnauthorized()` لعميل `ApiClient`.
2. ربط `authSession.onSessionTerminated` بدوال التطهير المحلية:

```dart
authSession.onSessionTerminated = () {
  if (Get.isRegistered<CartController>()) {
    Get.find<CartController>().clearCart();
  }
  if (Get.isRegistered<OrdersController>()) {
    Get.find<OrdersController>().clearOrders();
  }
  if (Get.isRegistered<ProfileStoreService>()) {
    Get.find<ProfileStoreService>().addresses.clear();
  }
  if (Get.isRegistered<WishlistController>()) {
    Get.find<WishlistController>().clearWishlist();
  }
};
```

### ثالثاً: عزل وتطهير المفضلة في `AppSettingsController`
تم استيراد `WishlistController` وتضمين استدعاء `clearWishlist()` داخل دالة `_clearLocalUserData()`:

```dart
if (Get.isRegistered<WishlistController>()) {
  Get.find<WishlistController>().clearWishlist();
}
```

---

## 3. أدلة التحقق والاختبار (Verification Evidence)

تم اختبار هذه المعالجات عبر 4 سيناريوهات اختبارية دقيقة في ملف `test/phase1_core_stabilization_test.dart`:

1. **اختبار رد النداء لـ HTTP 401:**
   - تم إطلاق استجابة 401 حقيقية من `Dio`، وتم التأكد من استدعاء `onUnauthorized` وحذف التوكن من مخزن `IAuthTokenStorage` وتحويل `isAuthenticated` إلى `false`.
2. **اختبار حماية التزامن (Concurrency Gate):**
   - تم إطلاق 5 استدعاءات متزامنة في نفس اللحظة عبر `Future.wait([handleUnauthorized(), ...])`.
   - النتيجة: تم تنفيذ دورة التطهير **مرة واحدة فقط** (`terminationCalls == 1`) دون أي تكرار أو انهيار.
3. **اختبار استقرار الجلسة مع الأخطاء الأخرى:**
   - تم إطلاق استجابة خطأ 500 Server Error وخطأ 422 Validation Error.
   - النتيجة: بقيت الجلسة نشطة ومصادق عليها ولم يتم استدعاء مسار 401 أو مسح التوكن.
4. **اختبار تطهير كاش الحساب بالكامل وعزل المفضلة:**
   - تم حشو السلة والطلبات والعناوين والمفضلة ببيانات المستخدم أ.
   - تم استدعاء `handleUnauthorized()` و `logout()`.
   - النتيجة: أصبحت جميع القوائم فارغة تماماً (`isEmpty == true`)، مما ضمن عزل البيانات بنسبة 100%.

