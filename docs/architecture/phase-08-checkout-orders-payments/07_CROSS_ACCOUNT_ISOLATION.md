# عزل الحسابات والبيانات المالية بين الجلسات
# Cross-Account Data Isolation & Session Boundary Security

## 1. التحدي الأمني (Security Threat Model)

في تطبيقات التجارة الإلكترونية، يمثل انتقال الهاتف من مستخدم لآخر أو تسجيل خروج المستخدم A وتسجيل دخول المستخدم B خطراً جسيماً إذا بقيت بيانات الطلبات السابقة أو تفاصيل السلة أو سندات التحويل البنكية مخزنة في الذاكرة.

### المخاطر المحتملة:
1. رؤية المستخدم B لقائمة طلبات وعناوين وأرقام هواتف المستخدم A (Privacy Breach).
2. استغلال المستخدم B لمفتاح تحصين مالي `idempotencyKey` أو سند تحويل بنكي سابق يخص المستخدم A.
3. اعتماد عرض سعر أو سلة تخص المستخدم السابق في جلسة المستخدم الجديد.

---

## 2. بروتوكول التطهير الثلاثي (Triple-Purge Protocol)

عند انتهاء جلسة المستخدم في `AuthSessionNotifier`:

```dart
void _syncSessionScopedProviders({
  required String? userId,
  required int generation,
}) {
  ...
  // 1. مزامنة وتطهير موفر الطلبات في Riverpod
  ref.read(ordersProvider.notifier).syncWithSession(
    userId: userId,
    generation: generation,
  );

  if (isAccountBoundary) {
    _purgeLegacyGetXStores(nextGen: generation);
  }
}
```

وخلال `_purgeLegacyGetXStores()`:
1. **تطهير موفرات Riverpod (SSOT):**
   - تفريغ سلة Riverpod: `ref.read(cartProvider.notifier).clearCart()`.
   - تصفير عرض السعر: `ref.read(cartQuoteProvider.notifier).reset()`.
   - تصفير سياق إتمام الشراء وسند التحويل: `ref.read(checkoutFlowProvider.notifier).reset()`.
   - تفريغ موفر الطلبات وعزل المعرف: `ref.read(ordersProvider.notifier).syncWithSession(userId: null, generation: nextGen)`.
2. **تطهير كنترولرات GetX القديمة:**
   - تفريغ سلة GetX: `cart.clearCart()` ومسح الـ RxLists صراحة.
   - تفريغ طلبات GetX: `orders.clearOrders()` ومسح الـ `orders.clear()`.
   - تفريغ عنوان وسياق الدفع: `shippingAddress.value = ShippingAddress.empty()`.

---

## 3. التحقق العملي عبر الاختبارات المؤتمتة

أثبت الاختبار رقم 6 في حزمة `test/phase8_checkout_orders_test.dart`:
- أن إنشاء المستخدم A لطلب برقم `ORD-USER-A` يظهر في قائمة طلباته.
- فور استدعاء `clearSession()`، يتم محو الطلبات وعودة `orders.isEmpty == true`.
- عند دخول المستخدم B برقم جيل جديد `generation: 2`، تكون قائمة طلباته فارغة تماماً مع استحالة الوصول لطلبات المستخدم A.
- النتيجة: **صفر تسريب مالي أو بياني بين الحسابات (Zero Data Leakage).**

