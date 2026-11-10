# أمان عمليات الدفع والتحصين المالي ضد التكرار
# Payment Security, Idempotency & Double-Submission Guards

## 1. حارس النقر المزدوج الفوري (Double-Submission Guard)

يمثل النقر المتكرر أو السريع على زر "تأكيد الطلب" مخاطرة مالية رئيسية قد تسفر عن إنشاء طلبين مكررين وخصم المخزون مرتين.

في `CheckoutFlowNotifier`:
```dart
Future<OrderModel?> submitCheckout(...) async {
  // 1. حارس فوري مانع للنقر المزدوج والتزامن
  if (state.isSubmitting) return null;
  ...
  state = state.copyWith(submissionStatus: CheckoutSubmissionStatus.submitting);
  ...
}
```
وفي `PaymentController` (واجهة GetX):
```dart
Future<void> confirmAndSubmitOrder() async {
  if (isSubmitting.value) return;
  ...
}
```
تم التحقق في الاختبار رقم 2 من حزمة `phase8_checkout_orders_test.dart` أن إطلاق طلبين متزامنين تماماً في نفس الـ Event Loop يسفر عن إرسال طلب HTTP واحد فقط ورفض الآخر فوراً.

---

## 2. بروتوكول مفتاح التحصين المالي المستقر (Stable Idempotency Key Protocol)

تعتمد البنية على ترويسة HTTP القياسية `X-Idempotency-Key`:

1. **توليد المفتاح لأول محاولة:**
   ```dart
   final idempotencyKey = customIdempotencyKey ??
       state.activeIdempotencyKey ??
       const Uuid().v4();
   ```
2. **تثبيت المفتاح في حالة `CheckoutState` أثناء الإرسال:**
   ```dart
   state = state.copyWith(
     submissionStatus: CheckoutSubmissionStatus.submitting,
     activeIdempotencyKey: () => idempotencyKey,
   );
   ```
3. **الحفاظ على المفتاح أثناء إعادة المحاولة (Retry Preservation):**
   إذا فشل الطلب بسبب انقطاع اتصال أو مهلة شبكية (Timeout)، يظل `activeIdempotencyKey` محفوظاً كما هو. وعند نقر المستخدم على "إعادة المحاولة"، يُعاد إرسال نفس المفتاح تماماً، مما يضمن لخادم Laravel التعرف على الطلب وعدم خصم المبلغ مرتين.
4. **تطهير المفتاح فور النجاح (Post-Success Invalidation):**
   عند استلام رد النجاح واعتماد الطلب، يتم تصفير `activeIdempotencyKey` لمنع استخدامه في أي طلب لاحق:
   ```dart
   state = state.copyWith(
     submissionStatus: CheckoutSubmissionStatus.success,
     activeIdempotencyKey: () => null,
   );
   ```

---

## 3. دورة حياة الدفع وسند التحويل اليدوي (Unconfirmed Payment Safety)

في حالة الدفع عبر المحافظ الإلكترونية اليمنية (الكريمي، جيب، جوال، ون كاش):
- يتم رفع صورة سند أو إشعار التحويل إلى خادم Laravel عبر مسار الصور المؤقتة `POST /api/v1/temporary-images`.
- يُنشأ الطلب بحالة `pending` (قيد المراجعة والتحقق) وليس `paid`.
- يُمنع منعاً باتاً وسم الطلب كـ `paid` أو تسليم الخدمة للعميل حتى يقوم مسؤول النظام في لوحة الإدارة بمطابقة الإشعار واعتماد الدفعة في قاعدة البيانات.

