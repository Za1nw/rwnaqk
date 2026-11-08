# جرد البيانات الوهمية وخطة الانتقال للإنتاج (Mock Data Inventory)

**الهدف:** حصر كافة مصادر البيانات التجريبية (`Mock / Seed Data`) الموزعة داخل التطبيق، وتحديد آلية استبدالها تدريجياً بـ Laravel API مع ضمان عدم ظهور أي بيانات وهمية في بيئة الإنتاج (`Production`).

---

## 1. جدول حصر البيانات الوهمية (Mock Data Inventory)

| الفئة (Category) | الملف ومكان الاستدعاء | المصدر الفعلي للبيانات الوهمية | الأثر في الواجهة | خطة الاستبدال بـ Laravel API |
|---|---|---|---|---|
| **منتجات الكتالوج** | `lib/modules/catalog/controllers/products_listing_controller.dart:102,133` | `ProductsListingService.mockProducts()` و `AppMockProductUtils` | شبكة المنتجات في شاشة Listing | استبدالها بـ `ProductsRepository.getProducts(page, filter)` |
| **تفاصيل المنتج والمراجعات** | `lib/modules/catalog/controllers/product_details_controller.dart:250` | `ProductDetailsService.resolveReviews()` و `AppMockContentUtils.previewReviews` | كروت المراجعات وتقييمات المنتج | استبدالها بـ `GET /api/v1/products/{id}` مع مصفوفة `reviews` |
| **منتجات الصفحة الرئيسية** | `lib/modules/home/controllers/home_controller.dart:40` | `HomeService.seedBanners()` و `seedSections()` | البانرات المتحركة، العروض، والأقسام الأكثر مبيعاً | ربطها بـ `GET /api/v1/home` أو استدعاء أقسام المنتجات مباشرة |
| **عناصر السلة الافتراضية** | `lib/modules/cart/controllers/cart_controller.dart:477` | `CartService.seedCartItems()` | ملء السلة تلقائياً بـ 2–3 عناصر عند فتح التطبيق | **إلغاء التعبئة التلقائية فوراً**؛ تبدأ السلة فارغة أو تُحمل من LocalStorage |
| **عناوين الشحن التجريبية** | `lib/modules/customer/controllers/profile_store_service.dart:124` | `ProfileStoreService.seedAddressesIfNeeded()` (صنعاء، الرياض) | العناوين الافتراضية في شاشتي السلة والحساب | جلبها من `GET /api/v1/customer/addresses` |
| **قائمة الطلبات السابقة** | `lib/modules/orders/controllers/orders_controller.dart:87` | `OrdersService.seedMockOrders()` (ORD-10241) | شاشة "طلباتي" وخطوات التتبع | جلبها من `GET /api/v1/orders` للمستخدم المسجل |
| **حسابات المحافظ الإدارية** | `lib/modules/customer/controllers/profile_store_service.dart:18` | مصفوفة ثابتة (جيب، ون كاش، الكريمي) | خيارات الدفع بالمحفظة الإلكترونية | جلبها من `GET /api/v1/wallet/accounts` عبر الباك إند |
| **بيانات المستخدم التجريبي** | `lib/core/services/auth/auth_session_service.dart:31` | `enterGuestMode()` ("مستخدم تجريبي") | وضع الضيف لتجاوز شاشة الدخول أثناء التصميم | حصر وضع الضيف كـ `Guest / Unauthenticated` حقيقي |

---

## 2. استراتيجية الاستبدال التدريجي (Phased Migration Strategy)

تتم عملية الاستبدال على 3 مراحل وفق جاهزية الـ Endpoints في Laravel:

```text
[المرحلة 1: التعطيل الفوري لبيانات السلة والعناوين]
  ├── إيقاف cart.seedCartItems() إلا إذا كان AppEnv.enableMockData == true
  └── جعل السلة تبدأ فارغة دائماً لجميع المستخدمين

[المرحلة 2: تفعيل المنتجات والتصنيفات من الخادم]
  ├── تشغيل IProductsRepository.getProducts()
  └── في حال انقطاع السيرفر: عرض شاشة الخطأ وزر "إعادة المحاولة" بدلاً من إظهار منتجات وهمية

[المرحلة 3: تفعيل الطلبات وحسابات المحافظ الحقيقية]
  ├── استبدال قائمة المحافظ بحسابات المتجر الرسمية من قاعدة البيانات
  └── ربط تتبع الطلب بحالة الطلب الفعلية في جدول orders
```

---

## 3. حارس بيئة الإنتاج الموحد (Production Environment Guards)

لضمان عدم تسرب أي بيانات وهمية للمتجر عند رفعه للمتاجر:

1. **التحكم عبر `.env`:**
   في ملف `.env`:
   ```properties
   APP_ENV=production
   ENABLE_MOCK_DATA=false
   ENABLE_DEBUG_LOGS=false
   ```
2. **الحارس البرمجي الصارم:**
   تعديل دوال التعبئة لتعتمد حصرياً على `AppEnv.enableMockData`:
   ```dart
   void seedMockData() {
     // في بيئة الإنتاج: يمنع منعاً باتاً استدعاء البيانات الوهمية
     if (!AppEnv.enableMockData) {
       cartItems.clear();
       itemQuantities.clear();
       return;
     }

     // وضع التطوير والتصميم فقط
     cartItems.assignAll(_service.seedCartItems());
     ...
   }
   ```
3. **حماية وضع الضيف (Guest Mode Hardening):**
   عند اختيار الزائر "المتابعة كزائر"، لا يتم منحه ملف مستخدم وهمي (`guest@rawnaqk.com`) ولا رصيد محفظة، بل يُسجل كـ `Guest` خاضع للقيود الطبيعية (يطلب منه إدخال اسمه وهاتفه عند الوصول لمرحلة الدفع).

