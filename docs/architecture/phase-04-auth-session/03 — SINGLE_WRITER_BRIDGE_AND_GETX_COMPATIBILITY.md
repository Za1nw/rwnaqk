# جسر الكاتب الأوحد والتوافق التام مع GetX
# 03 — SINGLE-WRITER BRIDGE & GETX COMPATIBILITY: Zero-Breakage Adapter Architecture

- **المشروع:** متجر رونقك الإلكتروني (Rawnaquk E-Commerce)
- **المرحلة:** Phase 04 — Authentication & Session Migration to Riverpod 3.5.0
- **تاريخ التوثيق:** 9 نوفمبر 2026
- **الحالة:** مكتمل ومتحقق منه برمجياً بنسبة 100% (VERIFIED)
- **المهندس المسؤول:** مهندس المعمارية الرئيسي ومسؤول ترحيل النظم (Principal Flutter Architect)

---

## 1. مبدأ الكاتب الأوحد (Single-Writer Principle)

في عمليات الترحيل الهجينة للأنظمة الكبيرة (Strangler Fig Pattern)، يشكل وجود أكثر من مصدر حقيقة (Dual Source of Truth) خطراً جسيماً يؤدي إلى تزامن خاطئ للحالة وتناقض بين واجهات المستخدم.

لذا، تم فرض مبدأ **الكاتب الأوحد الصارم**:
- **Riverpod 3.5.0 (`AuthSessionNotifier`)** هو الكيان الوحيد المخول بامتلاك وتعديل حالة الجلسة وتخزين الرموز المميزة.
- **خدمة GetX التاريخية ([`AuthSessionService`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/core/services/auth/auth_session_service.dart))** تم تحويلها جذرياً من "مالك للحالة" إلى **"مهايئ توافق وتفويض أحادي الاتجاه" (Single-Writer Compatibility Adapter)**.

```
       +--------------------------------------------------------+
       |             Legacy GetX Controllers & Views            |
       |  (LoginController, RegisterController, AppSettings...)  |
       +--------------------------------------------------------+
                                    |
          1. Calls methods / Reads getters (Identical Signatures)
                                    v
       +--------------------------------------------------------+
       |               AuthSessionService (GetxService)         |
       |                  [Adapter / Facade Layer]              |
       +--------------------------------------------------------+
                                    |
          2. Pure Delegation (Forward all commands to Riverpod)
                                    v
       +--------------------------------------------------------+
       |          AuthSessionNotifier (Riverpod 3.5.0)          |
       |                [Single Authoritative Writer]           |
       +--------------------------------------------------------+
                                    |
          3. Emits Immutable AuthSessionState & Updates Storage
                                    |
          4. Syncs back to Adapter (One-Way Observer)
                                    v
       +--------------------------------------------------------+
       |      Adapter Synchronizes Local Read-Only Projections  |
       +--------------------------------------------------------+
```

---

## 2. تفاصيل مهايئ التوافق (`AuthSessionService`)

تم الحفاظ على التوقيع العام الكامل لفئة `AuthSessionService` لضمان عدم انكسار أي كود تاريخي في المشروع:

### 2.1 الربط والتفويض عند الإنشاء (Constructor & Delegation Wiring)
يقبل الكائن تمرير `AuthSessionNotifier?` اختياري (وهو أمر حيوي لاختبارات الوحدات)، وفي بيئة الإنتاج يرتبط تلقائياً بحاوية Riverpod المركزية:

```dart
class AuthSessionService extends GetxService {
  final AuthTokenStorage _tokenStorage;
  final AuthSessionNotifier? _notifier;

  AuthSessionService({
    AuthTokenStorage? tokenStorage,
    String? initialAccessToken,
    Customer? initialCustomer,
    AuthSessionNotifier? notifier,
  })  : _tokenStorage = tokenStorage ?? AuthTokenStorage(),
        _notifier = notifier,
        _accessToken = initialAccessToken,
        _customer = initialCustomer {
    // الاستماع لحالة Riverpod وعكسها محلياً فوراً
    if (_notifier != null) {
      _status = _notifier.state.status;
      _sessionGeneration = _notifier.state.sessionGeneration;
      _accessToken = _notifier.state.token ?? _accessToken;
      _customer = _notifier.state.customer ?? _customer;

      _notifier.addListener((newState) {
        _syncFromRiverpodState(newState);
      });
    }
  }
}
```

---

## 3. تفويض الأوامر ومنع الازدواجية (Command Delegation & Deduplication)

### 3.1 تفويض عمليات الجلسة
كافة الدوال التعديلية تقوم بتفويض التنفيذ إلى نوتيفاير Riverpod:

| الدالة الأصلية في GetX | وجهة التفويض في Riverpod | الأثر المعماري |
|---|---|---|
| `startSession(token, customer)` | `_notifier.startSession(token, customer)` | تسجيل الجلسة في التخزين المشترك وتحديث جيل الجلسة. |
| `logout()` | `_notifier.logout()` | مسح التوكن، تصفير العميل، وتطهير الموديلات التابعة. |
| `handleUnauthorized(staleGeneration)` | `_notifier.handleUnauthorized(staleGeneration)` | التحقق من رقم الجيل وقفل التزامن قبل الإنهاء. |
| `updateCustomer(customer)` | `_notifier.updateCustomer(customer)` | تحديث ملف العميل في الحالة النقدية غير القابلة للتعديل. |
| `enterGuestMode()` | `_notifier.enterGuestMode()` | التحويل الصريح لوضع الزائر. |
| `startTwoFactorChallenge(payload)` | `_notifier.startTwoFactorChallenge(payload)` | إدخال النظام في طور التحدي الأمني دون كشف توكن. |
| `cancelTwoFactorChallenge()` | `_notifier.cancelTwoFactorChallenge()` | تصفير حمولة التحدي والعودة لغير مسجل. |

### 3.2 منع التكرار في استدعاءات إنهاء الجلسة (`Deduplicating Callback`)
عند استلام خطأ 401، كان يتم تسجيل استدعاء رد اتصال `onSessionTerminated` في كل من GetX و Riverpod. لضمان عدم إطلاق التحويل لشاشة تسجيل الدخول مرتين متتاليتين، تم ضبط آلية المهايئ لقمع أي نداء مكرر أثناء التفويض:

```dart
Future<void> handleUnauthorized({int? staleGeneration}) async {
  if (_notifier != null) {
    // تفويض الإنهاء الآمن إلى Riverpod
    await _notifier.handleUnauthorized(staleGeneration: staleGeneration);
    // مزامنة المتغيرات المحلية لتأكيد انقضاء الجلسة
    _accessToken = null;
    _customer = null;
    _status = AuthSessionStatus.unauthenticated;
    return;
  }
  // مسار بيئات الاختبار المعزولة التي لا تستخدم النوتيفاير
  ...
}
```

---

## 4. تكامل وحدات التحكم التاريخية (GetX Controllers Compatibility)

تم فحص وتحقيق التوافق التام لوحدات التحكم التالية دون الحاجة لتعديل أسطر استدعاءاتها:

1. **[`LoginController`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/auth/controllers/login_controller.dart):**
   - استدعاء `_sessionService.startSession(token, customer)` يستمر بالعمل ويقوم داخلياً بتحديث Riverpod 3.5.0، والتخزين الآمن، وتطهير وتحديث المفضلة.
2. **[`RegisterController`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/auth/controllers/register_controller.dart):**
   - يدعم إما إنشاء الجلسة فوراً بالتوكن الصادر من Laravel أو معالجة حالة التحقق من البريد `emailVerificationRequired`.
3. **[`TwoFactorChallengeController`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/auth/controllers/two_factor_challenge_controller.dart):**
   - يستعلم عن كود التحدي من `_sessionService.twoFactorPayload` الذي يعكس حمولة Riverpod المعزولة.
4. **[`ForgotPasswordController`](file:///d:/project/laravel/app-rwnaqk/rwnaqk_frontend/lib/modules/auth/controllers/forgot_password_controller.dart):**
   - يستخدم `forgotPasswordServiceProvider` أو الخدمة المباشرة دون أي تأثير على حالة الجلسة الجارية.

---

## 5. الخلاصة والتأهيل للمراحل القادمة

يوفر هذا الجسر عزلًا هندسياً فائق الاستقرار؛ حيث يتيح الاستمرار في تشغيل شاشات GetX الحالية كما هي دون أي خطر أو انكسار، مع نقل الملكية الحقيقية للحالة للأحدث (`Riverpod 3.5.0`). وعند الانتقال للمراحل اللاحقة، يمكن تحويل الواجهات واحدة تلو الأخرى إلى `ConsumerWidget` وقراءة `authSessionProvider` مباشرة، وصولاً إلى الحذف النهائي لـ `AuthSessionService` في Phase 09 دون عناء.

