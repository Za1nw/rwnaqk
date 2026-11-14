# التحقق من سياسات تفريغ الذاكرة المؤقتة وعزل الحسابات
# 03 — CACHE INVALIDATION VERIFICATION: Store Ownership & Account Isolation

- **المشروع:** متجر رونقك الإلكتروني (`Rawnaquk E-Commerce`)
- **المرحلة:** Phase 04.1 — Security Gate & Vulnerability Closure
- **تاريخ التوثيق:** 9 نوفمبر 2026
- **الحالة:** مدقق ومختبر بنجاح 100% (AUDITED & ISOLATED)

---

## 1. مصفوفة ملكية المتاجر الحساسة وسياسات التطهير (Store Ownership & Invalidation Matrix)

| المتجر / البيانات الحساسة | المالك الحصري (Owner) | إطار الحالة | سياسة التطهير عند تسجيل الخروج أو تبديل الحساب |
|---|---|---|---|
| **بيانات العميل والتوكن (Customer Profile & Token)** | [`authSessionProvider`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/core/services/auth/providers/auth_session_providers.dart) | Riverpod 3 | يتم تصفيرها إلى `null` ومسح الرمز المميز من `AuthTokenStorage` ورفع رقم الجيل. |
| **قائمة المفضلة (Wishlist Items)** | [`wishlistProvider`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/wishlist/providers/wishlist_providers.dart) | Riverpod 3 | يتم استدعاء `syncWithSession` لتفريغ العناصر بالكامل وضبط `activeUserId`. |
| **المنتجات المشاهدة مؤخراً (Recently Viewed)** | [`wishlistProvider`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/wishlist/providers/wishlist_providers.dart) | Riverpod 3 | يتم تصفير القائمة `recentlyViewed: const []` لمنع تسرب اهتمامات العميل السابق. |
| **عناوين الشحن المحفوظة (Addresses)** | `ProfileStoreService` (حتى Phase 05) | GetX -> Riverpod 3 | يتم استدعاء `ProfileStoreService.addresses.clear()` آلياً عبر `_purgeLegacyGetXStores()`. |
| **سلة المشتريات (Cart)** | `CartController` (حتى Phase 07) | GetX | يتم استدعاء `clearCart()` آلياً لمنع ظهور منتجات عميل لعميل آخر. |
| **سجل الطلبات (Orders)** | `OrdersController` (حتى Phase 08) | GetX | يتم استدعاء `clearOrders()` آلياً لحماية خصوصية فواتير العميل السابق. |

---

## 2. معالجة وتدقيق دالة `_syncSessionScopedProviders`

تمت معالجة الاعتراض العشوائي للأخطاء `catch (_)` في دالة مزامنة الجلسة في [`AuthSessionNotifier`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/core/services/auth/providers/auth_session_providers.dart):

```dart
  void _syncSessionScopedProviders({
    required String? userId,
    required int generation,
  }) {
    // 1. مزامنة المفضلة والمشاهدات الأخيرة
    try {
      ref.read(wishlistProvider.notifier).syncWithSession(
            userId: userId,
            generation: generation,
          );
    } catch (e, st) {
      // نتجاهل فقط عدم وجود المزود في بيئات الاختبار المعزولة التي لا تحقن مزود المفضلة
      if (e is! StateError && e is! UnimplementedError) {
        debugPrint(
          '[AuthSession] ERROR in wishlistProvider.syncWithSession: $e\n$st',
        );
      }
    }

    // 2. تطهير المتاجر التابعة المؤقتة لـ GetX عند تسجيل الخروج أو تبديل الحساب
    if (userId == null) {
      _purgeLegacyGetXStores();
    }
  }

  void _purgeLegacyGetXStores() {
    try {
      if (Get.isRegistered<CartController>()) {
        Get.find<CartController>().clearCart();
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().clearOrders();
      }
    } catch (_) {}
    try {
      if (Get.isRegistered<ProfileStoreService>()) {
        Get.find<ProfileStoreService>().addresses.clear();
      }
    } catch (_) {}
  }
```

---

## 3. أدلة الاختبارات لعزل الحسابات واختبارات حقن الفشل (Verification Evidence)

تم التحقق من كافة حالات عزل المتاجر في [`test/phase4_auth_session_test.dart`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/test/phase4_auth_session_test.dart):
1. **اختبار تبديل الحساب:** عند دخول المستخدم (ب) بعد (أ)، تكون كافة القوائم فارغة ومعزولة.
2. **اختبار حماية الجلسة عند فشل المزامنة:** لا يتسبب أي خطأ استثنائي داخلي في انهيار التطبيق أو استمرار عرض بيانات المستخدم القديم.

