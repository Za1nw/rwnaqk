# الدقة النقدية وحماية الكوبونات ومنع الجمود — Phase 08.2
## Exact Monetary Math, Coupon Concurrency & Deadlock Prevention

**المسار:** `docs/architecture/phase-08-2-security-hardening/05_MONEY_COUPONS_AND_INVENTORY.md`  
**الحالة:** معتمد ومنفذ  
**المكونات:** `Modules/Shop/app/Services/CustomerOrderService.php`, `Modules/Shop/app/Services/CartQuoteEngineService.php`

---

## 1. الدقة النقدية التامة (Exact Integer Cents Comparison)

### المشكلة السابقة:
كان الكود السابق يستخدم مقارنة الأرقام العشرية مع سماحية قدرها 0.05:
```php
if (abs($expectedGrandTotal - $recalculatedGrandTotal) > 0.05) { ... }
```
في الأنظمة المالية وتطبيقات التجارة الإلكترونية، يفتح التسامح مع الكسور العشرية باباً للتلاعب وسوء التقدير والتراكم الخاطئ للمبالغ أو استغلال ثغرات التقريب.

### المعالجة المنفذة:
تحويل كافة المبالغ إلى وحدات السنتات الدقيقة بمقارنة الأعداد الصحيحة:
```php
$expectedCents = (int) round(((float) $validated['expected_grand_total']) * 100);
$actualCents = (int) round(((float) $quote['grand_total']) * 100);

if ($expectedCents !== $actualCents) {
    $actualFormatted = number_format($quote['grand_total'], 2);
    abort(409, "حدث تغيير في الأسعار أو رسوم التوصيل، يرجى مراجعة الإجمالي ({$actualFormatted} ر.ي) وإعادة التأكيد.");
}
```
**النتيجة:** تم القضاء على أي سماحية تسريب مالي، وأي اختلاف ولو بمقدار فلس/سنت واحد يرفضه النظام فوراً بـ 409 Conflict.

---

## 2. الحماية المتزامنة لحصص الكوبونات (Concurrent Coupon Abuse Guard)

### المشكلة السابقة:
كان فحص عدد مرات استخدام الكوبون للعميل يتم خارج المعاملة أثناء إعداد التسعير الأولي، مما يسمح لعميل بإرسال طلبين متوازيين بكوبون له حد استخدام مرة واحدة (`max_uses_per_user = 1`)، فيمر الطلبان بنجاح.

### المعالجة المنفذة:
1. عند حساب التسعير: إذا كان الكوبون مستنفداً أو غير صالح، يتم رفض الطلب صراحة بـ 409 Conflict بدلاً من إلغاء الكوبون بصمت وفرض السعر الكامل على العميل دون علمه:
   ```php
   if (! empty($validated['coupon_code']) && empty($quote['coupon_code'])) {
       abort(409, $quote['message'] ?? 'كود الكوبون غير صالح أو تم استنفاد الحد الأقصى المسموح لاستخدامه.');
   }
   ```
2. داخل معاملة قاعدة البيانات وبقفل صفي:
   ```php
   if (! empty($quote['coupon_code'])) {
       $couponCode = $quote['coupon_code'];
       $usedCouponCount = Order::query()
           ->where('user_id', $customer->id)
           ->where('applied_coupon_code', $couponCode)
           ->where('delivery_status', '!=', 'cancelled')
           ->lockForUpdate()
           ->count();

       $maxUses = $this->cartQuoteEngine->getCouponMaxUses($couponCode);
       if ($usedCouponCount >= $maxUses) {
           abort(409, "لقد تم استنفاد الحد الأقصى المسموح لاستخدام هذا الكوبون ({$maxUses} مرات).");
       }
   }
   ```
3. يتم استثناء الطلبات الملغاة (`delivery_status = 'cancelled'`) من عداد الكوبونات، بحيث يستعيد العميل حقه في الكوبون إذا ألغى طلبه السابق.

---

## 3. منع حدوث الاختناق المتبادل للأقفال (Deadlock Prevention by Ascending Sorting)

عند طلب منتجات متعددة في نفس السلة، قد يقوم عميلان بطلب نفس المنتجين بترتيب معكوس:
- العميل (أ) يطلب [منتج 1، منتج 2].
- العميل (ب) يطلب [منتج 2، منتج 1].
إذا قام العميل (أ) بقفل منتج 1 وقام العميل (ب) بقفل منتج 2، فسيحدث **Deadlock** فوري في قاعدة البيانات ويسقط أحد الطلبين.

### المعالجة المنفذة:
قبل حجز الأقفال، يتم فرز عناصر السلة تصاعدياً وبشكل قطعي حسب معرف المتغير `product_variation_id`:
```php
usort($items, fn ($a, $b) => ((int) $a['product_variation_id']) <=> ((int) $b['product_variation_id']));
```
بهذا الإجراء الرياضي الصارم، يضمن النظام دائماً أن جميع المعاملات تحجز الأقفال بنفس الترتيب، مما يستحيل معه حدوث Deadlock دائري في InnoDB.

---

## 4. إثبات التحقق بالاختبارات الآلية

- `it rejects order with 409 conflict when expected_grand_total has minor fractional discrepancy (strict integer cents comparison)`: نجح.
- `it enforces atomic coupon usage limit per user under transaction lock`: نجح.
- `it prevents deadlocks by sorting variation IDs in ascending order during multi-item lock`: نجح.
- `it prevents overselling when two customers race to purchase the last item on MySQL`: نجح.

