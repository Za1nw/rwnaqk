# أمان مسار الدفع وسلامة المعاملات المالية (Checkout & Transaction Integrity)

**الأولوية القصوى للمشروع (P0 - Release Blocker):** حماية المتجر والعميل من تكرار الطلبات، والخصومات المزدوجة، والطلبات الوهمية، وانقطاع الاتصال أثناء الدفع.

---

## 1. التدفق المتكامل لدورة الشراء (End-to-End Order Flow)

```text
[1. السلة (Cart)]
       │
       ▼ (تجميع العناصر والمتغيرات)
[2. اختيار العنوان والشحن (Address & Shipping)]
       │
       ▼ (طلب عرض سعر إلزامي من الخادم)
[3. عرض السعر المعتمد (Server Quote POST /api/v1/cart/quote)]
       │  - تثبيت الأسعار، الخصومات، والكميات المتوفرة
       ▼
[4. شاشة مراجعة وتأكيد الطلب (Order Confirmation Screen)]
       │
       ├── توليد مفتاح عدم التكرار المنطقي: Idempotency-Key = UUIDv4
       │
       ▼ (الضغط على "تأكيد الطلب نهائياً")
[5. حارس الإرسال الموضعي (Submission Guard)]
       │  - فحص فوري: if (isSubmitting) return;
       │  - إقفال الزر ومؤشر التحميل الفوري
       ▼
[6. الإرسال إلى الخادم (POST /api/v1/orders)]
       ├── Header: X-Idempotency-Key: <UUID>
       ├── الرسوم، صورة السند (إن وجد)، والعناوين
       │
       ├──► في حال فشل الاتصال / Timeout:
       │    - الاحتفاظ بـ UUID نفسه دون توليد مفتاح جديد
       │    - الانتقال لحالة: UNKNOWN_OUTCOME
       │    - الاستعلام: GET /api/v1/orders/check-idempotency/{UUID}
       │
       ├──► في حال استجابة الخادم بنجاح (201 Created):
       │    - الاحتفاظ ببيانات الطلب
       │    - إفراغ السلة محلياً (cart.clearCart())
       │    - الانتقال لشاشة نجاح الطلب (OrderSuccessScreen)
       │
       └──► في حال رفض الخادم (422 / 400):
            - إبقاء السلة كما هي دون تفريغ
            - عرض رسالة الخطأ الدقيقة للعميل
```

---

## 2. آلة حالات الدفع المعتمدة (Checkout State Machine)

لتجنب التعقيد الإضافي مع ضمان عدم تداخل الحالات، تُدار دورة الدفع عبر مخطط الحالات المنضبط:

```text
               ┌──────────┐
               │   idle   │◄───────────────────────┐
               └────┬─────┘                        │
                    │ startCheckout                │
                    ▼                              │
             ┌──────────────┐                      │
             │  validating  │                      │
             └──────┬───────┘                      │
                    │ valid                        │
                    ▼                              │
             ┌──────────────┐                      │
             │   quoting    │                      │
             └──────┬───────┘                      │
                    │ quoteSuccess                 │
                    ▼                              │
             ┌──────────────┐                      │
             │  submitting  │                      │
             └──────┬───────┘                      │
                    │                              │
         ┌──────────┴──────────┐                   │
         │                     │                   │
         ▼ (timeout/loss)      ▼ (200 OK)          ▼ (422/error)
┌────────────────┐     ┌───────────────┐     ┌───────────┐
│ unknownOutcome │     │    success    │     │  failure  │
└───────┬────────┘     └───────────────┘     └───────────┘
        │                      │                   │
        │ checkStatus          │ clearCart         │ keepCart
        ▼                      ▼                   │
 (Verify / Retry)     [OrderSuccessView]           └───────► (عودة للتعديل)
```

### تعريف الحالات (States Definition)
1. **`idle`:** المستخدم يستعرض السلة أو شاشة الدفع دون وجود عمليات معلقة.
2. **`validating`:** التحقق من وجود عناصر، توفر العنوان، وأرقام التواصل.
3. **`quoting`:** جلب الحسبة النهائية لرسوم الشحن والخصومات من السيرفر.
4. **`submitting`:** الطلب قيد الإرسال؛ كافة أزرار الشاشة معطلة تماماً.
5. **`unknownOutcome`:** انقطاع الشبكة أو حدوث SocketTimeout قبل وصول استجابة الخادم.
6. **`success`:** تم تأكيد الطلب وحفظه في قاعدة البيانات؛ هنا فقط يتم استدعاء `cart.clearCart()`.
7. **`failure`:** رفض الخادم للطلب (نفاد مخزون، كود خصم منتهي)؛ تظل السلة كما هي ويُسمح للعميل بالتعديل والمحاولة مجدداً.

---

## 3. المعايير الهندسية لسلامة المعاملة (Integrity Requirements)

### 3.1. حارس الإرسال المانع للنقر المزدوج (Client Submission Guard)
* **المشكلة السابقة في الكود:** في [payment_controller.dart:166](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/checkout/controllers/payment_controller.dart#L166)، لا يوجد فحص لحالة `isSubmitting.value` في بداية `confirmAndSubmitOrder()`.
* **الإصلاح الإلزامي:**
  ```dart
  Future<void> confirmAndSubmitOrder() async {
    // 1. حارس فوري غير قابل للتجاوز
    if (isSubmitting.value) return;
    
    // 2. التحقق من الشروط
    if (!validateCheckoutPrerequisites()) return;

    try {
      isSubmitting.value = true;
      // توليد أو استخدام مفتاح المحاولة الحالية
      final idempotencyKey = _currentCheckoutIdempotencyKey ??= const Uuid().v4();
      
      final order = await _orderRepository.createOrder(
        dto: buildOrderDto(),
        idempotencyKey: idempotencyKey,
      );

      // نجاح مؤكد: تصفير السلة والمفتاح والانتقال لشاشة النجاح
      _currentCheckoutIdempotencyKey = null;
      cart.clearCart();
      Get.offNamed(AppRoutes.orderSuccess, arguments: order);
    } catch (e) {
      _handleCheckoutError(e);
    } finally {
      isSubmitting.value = false;
    }
  }
  ```

---

### 3.2. معيار الـ Idempotency وإعادة المحاولة (Idempotency Key Reuse Policy)
* **القاعدة الذهبية:** عند فشل الاتصال بشبكة الإنترنت أثناء عملية إرسال الطلب، **يُمنع منعاً باتاً توليد مفتاح جديد عند الضغط على "إعادة المحاولة" لنفس الطلب**.
* **السبب:** إذا كان السيرفر قد استلم الطلب وأنشأ الفاتورة بالفعل قبل انقطاع الخط عن العميل، فإن إرسال مفتاح جديد سيؤدي إلى إنشاء طلب ثانٍ مكرر!
* **السلوك الإلزامي:**
  1. يُولد المفتاح مرة واحدة عند دخول مرحلة التأكيد (`OrderConfirmationScreen`).
  2. يُعاد إرسال نفس المفتاح في حال ضغط المستخدم على زر "إعادة المحاولة" بعد انقطاع الاتصال.
  3. على جانب Laravel: عند استقبال طلب بنفس `X-Idempotency-Key` المنفذ مسبقاً، لا يتم إنشاء سجل جديد في جدول `orders`، بل يُعاد الرد المسجل مسبقاً بنفس رقم الطلب والإجمالي.

---

### 3.3. حظر تفريغ السلة المسبق (No Optimistic Cart Clearing)
* في الكود السابق [cart_controller.dart:451](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/cart/controllers/cart_controller.dart#L451)، كان يتم استدعاء `cartItems.clear()` لحظياً ومحلياً دون انتظار تأكيد الخادم.
* **القاعدة المعتمدة:** تظل عناصر السلة موجودة حتى يصل رد `HTTP 201 Created` بنجاح من Laravel API. في حال حدوث أي خطأ على الشبكة أو في السيرفر، تظل منتجات العميل محفوظة في سلته دون أن يفقد اختياراته.

---

### 3.4. إثبات الدفع والتحقق البنكي (Payment Verification Policy)
* اختيار الدفع عبر المحفظة وإرفاق صورة السند **لا يعني اكتمال الدفع المالي**.
* في استجابة الخادم وقاعدة البيانات:
  - يُنشأ الطلب بحالة دفع: `payment_status: "pending_verification"`.
  - حالة الطلب العامة: `order_status: "pending"`.
  - يتم إشعار العميل في شاشة النجاح: *"تم استلام طلبك وسند التحويل، وسيتم تأكيد الطلب فور مطابقة العملية من الإدارة المالية"*.
* هذا يمنع أي احتيال عبر رفع صور وهمية أو فارغة لاعتبار الطلب مسدداً تلقائياً.

