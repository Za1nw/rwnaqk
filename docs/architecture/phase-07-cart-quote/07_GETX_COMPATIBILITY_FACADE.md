# واجهة تفويض GetX التوافقية أحادية الكتابة
# GetX Compatibility Facade (Single-Writer Delegation)

**المرحلة:** Phase 07 Cart Migration  
**المكونات:** `CartController`, `cartProvider`, `cartQuoteProvider`

---

## 1. المبدأ المعماري

وفق وثيقة قواعد الهجرة الآمنة، يُمنع منعاً باتاً كسر أو تعديل شاشات الشراء `CheckoutController` أو الدفع `PaymentController` أو تأكيد الطلب `OrderConfirmationView` قبل مرحلتها المحددة (Phase 08).
لذلك، تحوّل `CartController` القديم من كونه مصدر الحقيقة (State Owner) إلى **واجهة تفويض وإسقاط للقراءة فقط (Single-Writer Delegation Facade)**:

```mermaid
graph TD
    subgraph Riverpod Layer [طبقة Riverpod 3.5.0 - المصدر المعتمد SSOT]
        CP["cartProvider (CartNotifier)"]
        CQP["cartQuoteProvider (CartQuoteNotifier)"]
    end

    subgraph GetX Facade [CartController - GetxController]
        CI["cartItems.obs"]
        IQ["itemQuantities.obs"]
        SQ["serverQuote.obs"]
        QL["isQuoteLoading.obs"]
        QE["quoteError.obs"]
    end

    subgraph Unmigrated Consumers [الشاشات والمتحكمات غير المهاجرة]
        CHK["CheckoutController"]
        PAY["PaymentController"]
        VIEW["CartScreen / PaymentView"]
    end

    CP -- "مزامنة تفاعلية لحظية (listen)" --> CI
    CP -- "مزامنة تفاعلية لحظية (listen)" --> IQ
    CQP -- "مزامنة تفاعلية لحظية (listen)" --> SQ
    CQP -- "مزامنة تفاعلية لحظية (listen)" --> QL
    CQP -- "مزامنة تفاعلية لحظية (listen)" --> QE

    VIEW -- "قراءة الحالات" --> CI
    CHK -- "قراءة الحسابات" --> SQ
    PAY -- "قراءة الإجمالي" --> SQ

    VIEW -- "استدعاء addToCart()" --> GetX Facade
    GetX Facade -- "تفويض حصري للكتابة" --> CP
    VIEW -- "استدعاء refreshServerQuote()" --> GetX Facade
    GetX Facade -- "تفويض حصري للكتابة" --> CQP
```

---

## 2. آليات المزامنة ثنائية الاتجاه (Bidirectional Interoperability)

1. **إسقاط القراءة (Read Projection):**
   - في `onInit()`، يشترك `CartController` في مراقبة `cartProvider` و `cartQuoteProvider` عبر `_effectiveContainer.listen()`.
   - أي تعديل يحدث في حالة Riverpod يُحدّث مجموعات GetX التفاعلية فورياً (`cartItems.assignAll`, `itemQuantities.assignAll`, `serverQuote.value`).
2. **تفويض الكتابة (Write Delegation):**
   - عندما تستدعي أي شاشة قديمة `cartController.addToCart()`, `removeFromCart()`, `incrementQuantity()`, `decrementQuantity()`, أو `clearCart()`، يتم تفويض العملية مباشرة إلى `_cartNotifier`.
   - لا توجد أي طفرات حالة محلية مستقلة في GetX، مما يمنع انحراف الحالة (Zero State Drift).

