# عقود Laravel الحقيقية وهوية المتغيرات
# Real Laravel Backend Contracts & Variant Identity Mapping

## 1. الفحص الميداني لمستودع Laravel Backend (`rwnaqk-backend`)

بناءً على التوجيه الصارم بفحص الشيفرة الحقيقية في المستودع المحلي للواجهة الخلفية (`d:\project\laravel\app-rwnaqk\rwnaqk-backend`), تم فحص المسارات والنماذج ومتحكمات الـ API:

### نتائج الفحص الميداني:
1. **ملف المسارات `routes/api.php`:**
   يحتوي حالياً فقط على:
   - `GET /user`
   - `POST /api/v1/temporary-images`
   - `DELETE /api/v1/temporary-images`
2. **المسارات المفقودة في الباك إند حالياً (Missing Backend Endpoints):**
   - `POST /api/v1/customer/cart/quote` (عرض أسعار السلة)
   - `POST /api/v1/customer/cart/validate-coupon` (فحص الكوبون)
   - `POST /api/v1/customer/orders` (إنشاء الطلب وإتمام الدفع)
   - `GET /api/v1/customer/orders` (قائمة الطلبات)
   - `GET /api/v1/customer/orders/{id}` (تفاصيل الطلب)
3. **الاستنتاج المعماري:**
   الواجهة الخلفية ما زالت في المراحل الأولى لتطوير منظومة التجارة الإلكترونية. تطبيق Flutter يتضمن طبقة `CartRepositoryImpl` و `OrdersRepositoryImpl` مجهزة بعقود REST متكاملة ومتحصنة برؤوس أمان (`X-Idempotency-Key`، `Bearer Token`) وتعتمد مؤقتاً على Fallback / Mock Data منضبط في وضع التطوير حتى انتهاء فريق الباك إند من تفعيل هذه المسارات.

---

## 2. معالجة هوية المتغيرات (Variant Identity Mapping)

### التحدي بين الواجهة والخادم:
- في Flutter، يتميز كل منتج متغير بمفتاح مستقر لغوياً مثل:
  `stableVariantId: color:black|size:54`
- بينما في قاعدة بيانات Laravel، يُخزن كل متغير في جدول `product_variations` بمعرف رقمي:
  `product_variation_id: 105`

### الحل المنفذ في Phase 07.1:
تم تحديث نموذج `CartLineItem` ليدعم المعرفين معاً:
```dart
class CartLineItem {
  final String id; // prod_10_color:black|size:54
  final String productId; // '10'
  final String? stableVariantId; // 'color:black|size:54'
  final int? productVariationId; // 105 (معرف المتغير في قاعدة بيانات Laravel)
  ...
}
```

وعند تجميع عناصر السلة لإرسالها إلى خادم Laravel:
```dart
final quoteItems = cart.items.map((line) {
  final prodId = int.tryParse(line.productId) ??
      int.tryParse(line.productId.replaceAll(RegExp(r'[^0-9]'), ''));
  final varId = line.productVariationId ?? int.tryParse(line.id);
  return <String, dynamic>{
    if (varId != null && varId > 0) 'product_variation_id': varId,
    if (prodId != null && prodId > 0) 'product_id': prodId,
    'qty': line.quantity,
  };
}).toList();
```

بهذا الشكل:
1. تحافظ واجهة المستخدم على ثبات الاختيارات وألوانها ومقاساتها بصرف النظر عن لغة التطبيق (`stableVariantId`).
2. يتلقى خادم Laravel المعرف الرقمي الصريح `product_variation_id: 105` للخصم من المخزون وتحديد السعر المعتمد.

