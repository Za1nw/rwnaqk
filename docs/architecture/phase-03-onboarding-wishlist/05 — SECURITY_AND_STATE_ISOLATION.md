# وثيقة الأمان وعزل حالة الجلسات والمستخدمين
# 05 — SECURITY & STATE ISOLATION: Cross-Account Protection & Session Scoping

- **المشروع:** متجر رونقك الإلكتروني (Rawnaquk E-Commerce)
- **المرحلة:** Phase 03 — Onboarding & Wishlist Migration
- **تاريخ التوثيق:** 9 نوفمبر 2026
- **الحالة:** مدقق ومختبر بنجاح 100% (VERIFIED)

---

## 1. التهديدات الأمنية ومخاطر تسرب البيانات (Threat Model)

في تطبيقات التجارة الإلكترونية التي تشهد تبديلاً للحسابات (تسجيل دخول وخروج على نفس الجهاز)، أو استخداماً بصفة زائر (Guest Mode)، توجد عدة ثغرات أمنية شائعة تتعلق بإدارة الحالة المحلية:

1. **تسرب بيانات العميل السابق للعميل اللاحق (Cross-Account Data Leakage):**
   - عندما يسجل المستخدم (أ) خروجه ويدخل المستخدم (ب)، بقاء عناصر المفضلة الخاصة بـ (أ) في الذاكرة يعرض خصوصية مشتريات واهتمامات العميل الأول للخطر.
2. **الاستجابات الشبكية المتأخرة والقديمة (Stale Network Responses / Race Conditions):**
   - إذا تم إرسال طلب استرجاع أو تفريغ للمفضلة للمستخدم (أ)، وتأخر الرد في الشبكة حتى دخل المستخدم (ب)، فإن معالجة الرد المتأخر قد تؤدي إلى مسح أو تلويث بيانات المستخدم (ب).
3. **أخطاء تفريغ الجلسة عند الانتقال إلى وضع الزائر (Guest Transition Flaws):**
   - عند تسجيل خروج المستخدم والعودة للتصفح كزائر، يجب ألا تظل العناصر الحساسة السابقة معروضة في التطبيق.

---

## 2. آليات الحماية المعمارية المطبقة (Architectural Defenses)

لمواجهة هذه المخاطر في وحدة المفضلة بـ Riverpod 3، تم تطبيق الآليات التالية في [`WishlistState`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/wishlist/models/wishlist_state.dart) و [`WishlistNotifier`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/wishlist/providers/wishlist_providers.dart):

### 2.1 وسم الحالة بمعرف العميل وجيل الجلسة (User ID & Session Generation Tagging)
تحتفظ حالة المفضلة دائماً بحقلين أمنيين:
- `activeUserId`: هوية العميل المسجل حالياً (أو `null` للزائر).
- `sessionGeneration`: رقم تسلسلي أحادي الاتجاه (Monotonic Integer) يزيد مع كل عملية تسجيل دخول أو خروج جديدة.

### 2.2 الحماية ضد الاستجابات المتأخرة في التفريغ والتعديل
عند استدعاء تفريغ المفضلة، يدعم النوتيفاير فحص هوية العميل وجيل الجلسة المتوقع:
```dart
void clearWishlist({String? expectedUserId, int? expectedGeneration}) {
  // التحقق من هوية الجلسة لمنع الاستجابات المتأخرة من تفريغ حساب مستخدم آخر
  if (expectedUserId != null &&
      state.activeUserId != null &&
      expectedUserId != state.activeUserId) {
    return;
  }

  // رفض الاستجابات ذات الأجيال القديمة
  if (expectedGeneration != null &&
      expectedGeneration < state.sessionGeneration) {
    return;
  }

  state = state.copyWith(items: const []);
}
```

### 2.3 التطهير التلقائي عند تبديل الحساب (`syncWithSession`)
عند حدوث أي تغير في هوية العميل، يقوم النوتيفاير بتطهير القائمة تماماً لمنع أي تسرب:
```dart
void syncWithSession({required String? userId, required int generation}) {
  // إذا تبدل الحساب يجب مسح عناصر العميل السابق تماماً لمنع التسرب
  if (state.activeUserId != null && state.activeUserId != userId) {
    state = state.copyWith(
      items: const [],
      activeUserId: userId,
      clearActiveUserId: userId == null,
      sessionGeneration: generation,
    );
    return;
  }

  state = state.copyWith(
    activeUserId: userId,
    clearActiveUserId: userId == null,
    sessionGeneration: generation,
  );
}
```

---

## 3. الثغرة المكتشفة وتصحيحها أثناء التدقيق (Defect & Surgical Fix)

أثناء كتابة واختبار السيناريو السادس (الانتقال من مستخدم مسجل إلى زائر)، تم اكتشاف خلل في دالة `copyWith`:
- **المشكلة الأصلية:**
  ```dart
  activeUserId: activeUserId ?? this.activeUserId
  ```
  عند تمرير `userId: null` في دالة `syncWithSession` لتسجيل الخروج، كان التعبير `activeUserId ?? this.activeUserId` يعيد القيمة القديمة `this.activeUserId`، مما أبقى معرف المستخدم مسجلاً ومنع تفريغ الحالة!
- **التصحيح المعماري الصارم:**
  تم إضافة راية صريحة `bool clearActiveUserId = false` لدعم التصفير الكامل:
  ```dart
  activeUserId: clearActiveUserId ? null : (activeUserId ?? this.activeUserId),
  ```
  وتم تمرير `clearActiveUserId: userId == null` في النوتيفاير، مما ضمن التطهير التام والمثالي.

---

## 4. نتائج الاختبارات المعتمدة لعزل الجلسات (Test Evidence)

تم اختبار والتحقق من كافة السيناريوهات بنجاح 100% داخل [`test/phase3_onboarding_wishlist_test.dart`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/test/phase3_onboarding_wishlist_test.dart):

| السيناريو | الغرض والهدف الأمني | النتيجة |
|---|---|---|
| **Scenario 1 & 2** | مسح عناصر المستخدم (أ) تماماً عند تسجيل الخروج، ورؤية المستخدم (ب) لحالة نظيفة خالية من عناصر (أ). | **PASSED** |
| **Scenario 3** | الاستجابات المتأخرة للمستخدم (أ) لا يمكنها تفريغ أو تلويث بيانات المستخدم (ب) النشط حالياً. | **PASSED** |
| **Scenario 4** | رفض الاستجابات الشبكية ذات أرقام الأجيال القديمة (`expectedGeneration < state.sessionGeneration`). | **PASSED** |
| **Scenario 5** | التبديل المباشر بين حسابين مختلفين يؤدي إلى مسح وتطهير فوري للبيانات دون الحاجة لاستدعاء يدوي إضافي. | **PASSED** |
| **Scenario 6** | خروج المستخدم والانتقال لوضع الزائر (`userId: null`) يطهر العناصر الخاصة بالكامل ويصفر معرف المستخدم. | **PASSED** |
| **Container Isolation** | استقلال حاويات `ProviderContainer` المنفصلة وعدم تشارك أو تداخل الحالات بينها. | **PASSED** |

---

## 5. الخلاصة الأمنية

تم إغلاق كافة منافذ تسرب البيانات في وحدتي التهيئة والمفضلة بنجاح، وأصبح نظام إدارة الحالة مؤمناً ومقاوماً للسباقات الزمنية وتداخل الجلسات، مما يمهد الطريق الآمن للانتقال إلى وحدة المصادقة والجلسات (Phase 04).

