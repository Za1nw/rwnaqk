# سجل المهام المتبقية لوحدة المصادقة
# 04 — AUTH RESIDUAL BACKLOG: Precise Migration Inventory & Future Roadmap

- **المشروع:** متجر رونقك الإلكتروني (`Rawnaquk E-Commerce`)
- **المرحلة:** Phase 04.1 — Security Gate & Vulnerability Closure
- **تاريخ التوثيق:** 9 نوفمبر 2026
- **الحالة:** جرد دقيق وشفاف بنسبة 100% (AUDITED & INVENTORIED)

---

## 1. بيان الشفافية المعمارية (Architectural Transparency Statement)

تأكيداً لمبدأ النزاهة الهندسية، نوضح بجلاء أنه **لم يتم ترحيل كافة شاشات ووحدات تحكم المصادقة إلى Riverpod بالكامل بعد**؛ بل ما تم ترحيله في المرحلة 04 هو:
**"طبقة النواة وإدارة الجلسة المركزية ومخزن الرموز المميزة ومزودات الخدمات" (Core Session Ownership & Service Providers)**، مع توفير مهايئ توافقية متين (`AuthSessionService`) يتيح لوحدات تحكم GetX الحالية العمل بسلاسة وأمان.

---

## 2. جدول الجرد المعماري لمكونات المصادقة (Auth Component Inventory)

| المكون البرمجي | المسار في المشروع | الحالة الحالية | المالك التشغيلي | موعد الترحيل الكامل لـ Riverpod |
|---|---|---|---|---|
| **حالة ونماذج الجلسة** | `lib/core/services/auth/models/auth_session_state.dart` | **مرحل بالكامل** | Riverpod 3 | منجز في Phase 04 |
| **نوتيفاير الجلسة المركزي** | `lib/core/services/auth/providers/auth_session_providers.dart` | **مرحل بالكامل** | Riverpod 3 | منجز في Phase 04 |
| **التخزين الآمن للرموز** | `lib/core/services/auth/auth_token_storage.dart` | **مرحل بالكامل** | Riverpod 3 | منجز في Phase 01 / 04 |
| **مزودات خدمات المصادقة** | `lib/modules/auth/providers/auth_providers.dart` | **مرحل بالكامل** | Riverpod 3 | منجز في Phase 04 |
| **مهايئ التوافقية مع GetX** | `lib/core/services/auth/auth_session_service.dart` | **مرحل كمهايئ تفويض** | Riverpod 3 (يدير GetX) | سيتم حذفه في Phase 09 |
| **مستودع المصادقة النقي** | `lib/modules/auth/data/repositories/auth_repository.dart` | **مرحل بالكامل** | Riverpod 3 | منجز في Phase 01 |
| **وحدة تحكم تسجيل الدخول** | `lib/modules/auth/controllers/login_controller.dart` | **في GetX** | GetX Controller | مستهدف في خطة الترحيل المتبقية |
| **وحدة تحكم إنشاء الحساب** | `lib/modules/auth/controllers/register_controller.dart` | **في GetX** | GetX Controller | مستهدف في خطة الترحيل المتبقية |
| **وحدة تحكم استعادة كلمة المرور**| `lib/modules/auth/controllers/forgot_password_controller.dart` | **في GetX** | GetX Controller | مستهدف في خطة الترحيل المتبقية |
| **وحدة تحكم التحقق بخطوتين** | `lib/modules/auth/controllers/two_factor_challenge_controller.dart` | **في GetX** | GetX Controller | مستهدف في خطة الترحيل المتبقية |
| **روابط ومزودات GetX** | `lib/modules/auth/bindings/*.dart` | **في GetX** | GetX Bindings | مستهدف في خطة الترحيل المتبقية |
| **شاشات واجهات المصادقة** | `lib/modules/auth/views/*.dart` (7 شاشات) | **في GetX** | `GetView` | مستهدف في خطة الترحيل المتبقية |
| **وسيط مسارات التوجيه** | `lib/routes/auth_middleware.dart` | **في GetX** | GetMiddleware | سيتم استبداله في Phase 09 |

---

## 3. التوصية المعمارية للترحيل النهائي لوحدات تحكم الواجهة (Recommendation)

يوصى بالإبقاء على وحدات تحكم GetX وشاشات المصادقة الحالية كما هي خلال المراحل القادمة (Phase 05 للعناوين، Phase 06 للكتالوج، Phase 07 للسلة، Phase 08 للدفع)؛ نظراً لأنها معزولة تماماً وتعتمد على مهايئ التفويض الآمن دون أي خلل، على أن يتم ترحيل واجهات المصادقة إما في مرحلة مخصصة تسبق مرحلة الحذف النهائي (Phase 08.5) أو بالتزامن مع ترحيل نظام التوجيه في **Phase 09**.

