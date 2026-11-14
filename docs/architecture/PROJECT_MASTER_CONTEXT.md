# MASTER PROJECT HANDOFF — RAWNAQUK E-COMMERCE

## 1. هوية المشروع والهدف العام

أنت تعمل على مشروع متجر إلكتروني حقيقي باسم:

**رونقك (Rawnaquk E-Commerce)**

المشروع يتكون من تطبيق Flutter للعميل وخلفية Laravel REST API.

الهدف الحالي هو تحديث المعمارية القديمة المبنية على GetX إلى معمارية حديثة تعتمد على Riverpod 3.5.0، مع الحفاظ على جميع الوظائف الحالية، ورفع جودة الأمان والأداء وقابلية الصيانة والتوسع.

المشروع يبنيه المطور حاليًا بشكل أساسي بمفرده، مع احتمالية وجود فريق عمل مستقبلًا.

لذلك يجب أن تكون المعمارية مفهومة، واضحة المسؤوليات، قابلة للاختبار، وقابلة لتوزيع العمل بين عدة مطورين مستقبلًا.

### الهدف النهائي

الوصول إلى تطبيق:

- يعتمد Riverpod 3 لإدارة الحالة المشتركة.
- لا يحتوي على اعتماد مباشر على GetX في كود التطبيق.
- يمتلك نظام Navigation مستقلًا عن GetX.
- يمتلك نظام Localization مستقلًا عن GetX.
- يتصل بـ Laravel من خلال API موحد وآمن.
- يحافظ على سلامة المعاملات المالية والمخزون والطلبات.
- لا يحتوي على ازدواجية في ملكية الحالة.
- يمتلك اختبارات حقيقية وتوثيقًا معماريًا شاملًا.

---

# 2. بيئة التطوير والمستودعات

نظام التشغيل: Windows 11.

استخدم PowerShell عند تقديم أوامر Terminal.

### Flutter Repository

```text
D:\project\laravel\app-rwnaqk\rwnaqk_frontend
```

### Laravel Repository

```text
D:\project\laravel\app-rwnaqk\rwnaqk-backend
```

### الإصدارات الموثقة في تقارير المشروع

| التقنية | الإصدار |
|---|---|
| Flutter | 3.47.3 |
| Dart | 3.13.3 |
| Riverpod | 3.5.0 |
| Laravel Backend | 11 |
| PHP | 8.5.7 |
| Database | MySQL 8 / InnoDB |
| Flutter HTTP | Dio |
| Testing | Pest / PHPUnit / Flutter Test |

هذه إصدارات موثقة تاريخيًا، وليست ضمانًا بأنها الإصدارات المثبتة حاليًا. تحقق منها قبل أي تعديل.

### المعمارية

Flutter يعتمد تقسيمًا Feature-First مع وحدات مستقلة.

Laravel يعتمد الوحدات والمكونات الموجودة بالفعل، ومنها:

```text
Modules/Shop/app/
    Models/
    Services/
    Http/
    ...
```

لا تعِد تصميم بنية المشروع دون مبرر معماري واضح.

---

# 3. الوحدات الأساسية للتطبيق

التدقيق الأولي Phase 00 حصر 11 وحدة أساسية و335 ملف Dart تقريبًا.

الوحدات:

1. Auth — المصادقة والتسجيل والتحقق بخطوتين.
2. Cart — السلة والأسعار والكوبونات.
3. Catalog — المنتجات والتصنيفات والتفاصيل.
4. Checkout — إتمام الشراء وطرق الدفع.
5. Customer — الملف الشخصي والعناوين والإعدادات.
6. Home — الصفحة الرئيسية والتبويبات.
7. Onboarding — التعريف بالتطبيق.
8. Orders — الطلبات والتتبع.
9. Search — البحث والتصفية.
10. Support — الدعم والمساعدة.
11. Wishlist — المفضلة.

هذه قائمة التدقيق الأصلية؛ يجب إعادة فحص الملفات الحالية وعدم اعتبار أعداد الملفات أو الوحدات ثابتة بعد التعديلات.

---

# 4. تاريخ ترحيل GetX إلى Riverpod

تم اعتماد استراتيجية ترحيل تدريجية تعتمد على فصل ملكية الحالة عن الواجهات القديمة، ثم إزالة جسور التوافق في المرحلة النهائية.

لم يكن الهدف حذف GetX دفعة واحدة؛ بل نقل المسؤوليات تدريجيًا دون كسر التطبيق.

## Phase 00 — Comprehensive Architecture Audit

الحالة: مكتملة.

تم تنفيذ تدقيق معماري شامل شمل:

- تحليل الوحدات الـ 11.
- حصر اعتماديات GetX.
- تحليل التشابك بين Controllers.
- تحليل رحلات العميل الـ 13.
- دراسة المخاطر المالية والأمنية.
- تحديد التوافق مع Riverpod 3.5.0.
- وضع خارطة طريق من تسع مراحل.

التوثيق:

`docs/architecture/phase-00-audit/`

الملفات الأساسية:

- PROJECT_AUDIT.md
- GETX_DEPENDENCY_MATRIX.md
- ARCHITECTURE_DEPENDENCY_MAP.md
- ECOMMERCE_CRITICAL_FLOWS.md
- RIVERPOD3_COMPATIBILITY.md
- MIGRATION_ROADMAP.md
- TESTING_BASELINE.md
- RISK_REGISTER.md
- PHASE_00_GATE.md

## Phase 01 — Core Stabilization

الحالة: مكتملة.

تم تأسيس Riverpod في جذر التطبيق وإنشاء ProviderScope، وتطوير طبقة الاعتماديات الأساسية ومعالجة مشكلات API والجلسة.

## Phase 02 — Support Module Pilot

الحالة: مكتملة.

ترحيل وحدة الدعم باعتبارها أول وحدة تجريبية منخفضة المخاطر.

## Phase 03 — Onboarding & Wishlist

الحالة: مكتملة.

ترحيل حالة المفضلة والتعريف بالتطبيق إلى Riverpod.

## Phase 04 — Authentication & Session Core

الحالة: مكتملة جزئيًا على مستوى إزالة GetX، ومكتملة على مستوى ملكية الجلسة المركزية.

تم نقل ملكية الجلسة إلى:

`authSessionProvider`

كما تم نقل تخزين الرموز والمستودعات ومزودات خدمات المصادقة إلى Riverpod.

لكن لا تزال بعض Controllers الخاصة بالمصادقة تعتمد على GetX كطبقة توافق.

المكونات المتبقية الموثقة:

- LoginController
- RegisterController
- ForgotPasswordController
- TwoFactorChallengeController
- AuthSessionService
- Auth Bindings

لا تفترض أنها أزيلت لاحقًا دون فحص المصدر الحالي.

## Phase 05 — Addresses & Geographic Coverage

الحالة: مكتملة وفق تقارير المشروع.

تم ترحيل إدارة العناوين وخدمات التغطية الجغرافية المطلوبة للشحن وإتمام الشراء.

## Phase 06 — Catalog & Search

الحالة: مكتملة.

تم ترحيل:

- المنتجات.
- التصنيفات.
- تفاصيل المنتج.
- البحث.
- Pagination.
- Dynamic Variants.
- الفلاتر والترتيب.

استخدم المشروع Providers وNotifiers مكتوبة يدويًا، مع Dio CancelToken وإلغاء الطلبات القديمة والتحقق من تسلسل نتائج البحث.

اختبارات المرحلة الموثقة:

168/168 ناجحة.

`flutter analyze`: صفر مشاكل.

## Phase 07 — Cart & Server Quote

الحالة: CONDITIONAL PASS.

تم ترحيل ملكية السلة وحسابات التسعير إلى Riverpod.

المبدأ الأساسي:

Laravel هو المرجع النهائي للأسعار والمخزون والخصومات والكوبونات ورسوم التوصيل والإجمالي.

لا يجوز اعتبار السعر القادم من Flutter سعرًا موثوقًا.

نتيجة الاختبارات الموثقة:

192/192 ناجحة.

تمت إضافة بوابة مالية Phase 07.1 قبل الدخول في Checkout.

## Phase 07.1 — Financial Integrity Gate

تم التركيز على:

- هوية المنتج والمتغير.
- صحة الأسعار.
- الكوبونات.
- المخزون.
- التزامن.
- منع التلاعب بالبيانات المالية.

## Phase 08 — Checkout, Payment & Orders

الحالة: مكتملة على مستوى ترحيل منطق المعاملات إلى Riverpod، مع بقاء جسور GetX التي تحتاج إزالة نهائية.

تم نقل المسؤوليات المتعلقة بـ:

- Checkout.
- Payment.
- Orders.
- Server Quote.
- Idempotency.
- Receipt Upload.
- Order Recovery.

## Phase 08.1 — Laravel Backend & Real E2E Integration

الحالة: PASS وفق التقرير الرسمي.

تم توثيق تنفيذ وتكامل واجهات Laravel الأساسية:

- Cart Quote.
- Coupon Validation.
- Order Creation.
- Order Listing.
- Order Details.
- Order Cancellation.

كما تم اختبار التكامل على MySQL InnoDB وStaging.

النتائج الموثقة:

| الاختبار | النتيجة |
|---|---|
| Laravel | 50/50 |
| Assertions | 298 |
| MySQL Concurrency | 8/8 |
| HTTP Staging E2E | 15/15 |
| Flutter | 215/215 |
| Flutter Analyze | 0 issues |

لم يتم حذف GetX في هذه المرحلة.

التوثيق:

`docs/architecture/phase-08-1-backend-integration/`

## Phase 08.2 — Security Hardening

الحالة الرسمية في تقرير البوابة: GO / APPROVED.

التوثيق:

`docs/architecture/phase-08-2-security-hardening/`

تم توثيق عشرة ملفات تشمل:

1. Independent Security Audit.
2. Receipt Ownership & Upload Security.
3. Receipt Concurrency & Uniqueness.
4. Idempotency & Crash Recovery.
5. Money, Coupons & Inventory.
6. Flutter Production Fallback Audit.
7. Laravel Security Test Results.
8. Android Staging E2E.
9. Security & Risk Register.
10. Phase 08.2 Gate.

### الإصلاحات التي يوثقها التقرير

**أولًا: سندات التحويل**

تم إنشاء نموذج:

`CustomerReceiptUpload`

وجدول:

`customer_receipt_uploads`

مع ربط السند بالمستخدم وحالته وملفه الفعلي وتاريخ انتهاء صلاحيته.

تم إضافة التحقق من:

- ملكية السند.
- وجود الملف.
- صلاحيته.
- حالته.
- منع الاستخدام المكرر.
- قفل السند عند استهلاكه.

**ثانيًا: Idempotency**

تم التحقق من قيد UNIQUE على:

`(user_id, key)`

وإضافة آلية CAS للتعامل مع الأقفال القديمة.

مهلة استرداد القفل الموثقة في Phase 08.2 هي 60 ثانية.

**ثالثًا: Financial Integrity**

تم إلغاء سماحية مقارنة الإجمالي القديمة 0.05 واستبدالها بمقارنة وحدات نقدية صحيحة.

لكن التطبيق الموثق ما زال يحوّل المبالغ عبر float قبل ضربها في 100؛ لذلك يجب عدم اعتبار ذلك إثباتًا كافيًا للدقة العشرية المطلقة.

**رابعًا: Coupon Concurrency**

تم إضافة `lockForUpdate` أثناء التحقق من حد استخدام الكوبونات.

لكن يجب مراجعة هذا التنفيذ مستقلًا؛ لأن قفل نتائج COUNT لا يثبت وحده تسلسل أول استخدامين متزامنين عندما لا توجد سجلات سابقة.

**خامسًا: Production Mock Guard**

تم توثيق تعطيل Mock Financial Success في Release/Production.

### نتائج Phase 08.2 الموثقة

- Laravel: 60/60.
- Laravel Assertions: 341.
- Flutter: 215/215.
- Flutter Analyze: 0 issues.
- HTTP Staging: 15/15.
- Android Emulator: Pixel 6 / Android 16 / API 36.

مهم جدًا:

اختبار شراء Staging الموثق تم عبر سكربت PHP:

`test_staging_e2e_real_http.php`

أما Android فتم إثبات تشغيل المحاكي واتصاله بالخادم. لا تخلط بين ذلك وبين تنفيذ رحلة شراء فعلية من واجهات Flutter على Android.

---

# 5. المراجعة الهندسية التي وصلنا إليها في المحادثة

رغم أن تقرير Phase 08.2 الرسمي أعلن GO / APPROVED، فقد راجعنا محتواه بصورة مستقلة، وقررنا عدم اعتبار جميع المخاطر مغلقة دون فحص إضافي.

التصنيف الذي نعتمده للمتابعة هو:

**CONDITIONAL PASS — Security Preflight Required**

الملاحظات المهمة:

### A. Coupon Concurrency

الكود الموثق يستخدم:

```php
$usedCouponCount = Order::query()
    ->where('user_id', $customer->id)
    ->where('applied_coupon_code', $couponCode)
    ->where('delivery_status', '!=', 'cancelled')
    ->lockForUpdate()
    ->count();
```

يجب إثبات أنه يمنع معاملتين مستقلتين من استهلاك أول استخدام للكوبون بالتزامن.

المطلوب:

- اختبار بمعاملتين حقيقيتين على MySQL InnoDB.
- حد استخدام واحد.
- طلبان متزامنان بمفتاحي Idempotency مختلفين.
- السماح لطلب واحد فقط.
- منع إنشاء الطلب الثاني أو خصم مخزونه.

إذا لم يثبت الضمان، استخدم سجل حصة ثابتًا قابلًا للقفل أو عدادًا ذريًا وقيود قاعدة بيانات مناسبة.

### B. Monetary Precision

الكود الموثق:

```php
$expectedCents = (int) round(
    ((float) $validated['expected_grand_total']) * 100
);

$actualCents = (int) round(
    ((float) $quote['grand_total']) * 100
);
```

التحويل إلى integer لا يلغي مشكلات floating-point السابقة.

يجب تحديد دقة العملة YER والعملات الأخرى إن وجدت، واستخدام تمثيل نقدي دقيق مثل integer minor units أو Decimal arithmetic.

### C. Receipt Privacy

جدول الرفع الموثق يحتوي على:

```sql
disk varchar(50) NOT NULL DEFAULT 'public'
```

يجب التحقق من إمكانية قراءة السندات بصورة عامة عبر URL.

لا نفترض وجود استغلال مؤكد قبل فحص إعدادات التخزين ومسارات تقديم الملفات.

الأفضل تخزين السندات الخاصة على قرص Private واستخدام وصول مصرح به.

كذلك يجب مراجعة إعادة السند إلى `available` عند إلغاء الطلب، وعدم السماح بإعادة استخدام إثبات تحويل سبق اعتماده ماليًا.

### D. Idempotency Recovery

يجب اختبار:

- عامل بطيء بعد استرداد القفل.
- عامل قديم يحاول إكمال الطلب.
- تكرار نفس المفتاح.
- نفس المفتاح مع Payload مختلف.
- فقدان استجابة HTTP بعد نجاح Commit.
- عدم خصم المخزون مرتين.

لا تدّعِ Exactly Once دون إثبات.

### E. Android Flutter UI E2E

يجب تنفيذ اختبار فعلي لتطبيق Flutter على Android، وليس الاكتفاء باختبار HTTP أو اتصال الشبكة.

هذه النقطة ما زالت تحتاج إثباتًا.

---

# 6. المرحلة التالية — PHASE 09

هذه هي المرحلة التي توقفنا عندها.

اسمها:

**PHASE 09 — FINAL GETX REMOVAL & ROUTER CUTOVER**

هدفها إزالة GetX بالكامل من كود التطبيق، بعد التأكد من ترحيل كل الوظائف المتبقية.

مهم:

Riverpod ليس بديلًا مباشرًا لجميع وظائف GetX.

التقسيم المعتمد:

| الوظيفة | التقنية المستهدفة |
|---|---|
| Shared State | Riverpod 3 |
| Notifiers | Riverpod 3 |
| Dependency Injection | Riverpod Providers |
| Navigation | go_router أو بديل مناسب بعد تقييم |
| Localization | Flutter l10n / ARB |
| UI Dialogs | Flutter showDialog |
| Snackbars | ScaffoldMessenger |
| UI Local State | Flutter StatefulWidget عند الحاجة |

لا تفترض أن go_router مثبت بالفعل.

يجب دراسة احتياجات التطبيق قبل اتخاذ قرار التوجيه النهائي.

## 7. المهام المطلوبة في Phase 09

### 9.1 Full GetX Dependency Audit

افحص كامل المشروع بحثًا عن:

```text
import 'package:get/get.dart'
GetxController
GetxService
GetMaterialApp
Get.put
Get.lazyPut
Get.find
Get.delete
Get.to
Get.toNamed
Get.off
Get.offAll
Get.back
Get.arguments
Get.parameters
Get.currentRoute
Get.context
Obx
GetBuilder
Rx
.obs
.tr
GetMiddleware
Bindings
GetConnect
```

افحص أيضًا:

- `pubspec.yaml`
- الاختبارات.
- integration_test.
- الملفات القديمة.
- أدوات التنبيه والحوارات.
- ملفات الترجمة.
- تعريفات التوجيه.

أنشئ مصفوفة بكل اعتماد متبقٍ وموقعه وسبب وجوده.

### 9.2 Authentication Migration

إكمال ترحيل Controllers المصادقة المتبقية:

- Login.
- Register.
- Forgot Password.
- Two Factor Challenge.

استخدم `authSessionProvider` بوصفه المالك الوحيد للجلسة.

لا تنشئ Session State ثانية.

احفظ سلوك 2FA والجلسات والرموز والتخزين الآمن.

### 9.3 Remaining Feature Migration

افحص وترحيل أي استخدام متبقٍ لـ GetX في:

- Customer Profile.
- Notifications.
- App Settings.
- Home.
- Flash Sale.
- Reviews.
- Catalog.
- Search.
- Product Details.
- Addresses.
- Wishlist.
- Cart.
- Checkout.
- Orders.

لا تفترض أن جميع هذه الوحدات ما زالت تحتاج ترحيلًا؛ بعض منطقها أصبح بالفعل تحت Riverpod في المراحل السابقة.

افحص المستهلكين الفعليين قبل الحذف.

### 9.4 Routing Migration

استبدال:

`GetMaterialApp`

و:

`GetPage`

و:

`Get.toNamed`

و:

`GetMiddleware`

بنظام توجيه مناسب.

ادرس go_router كخيار مرشح.

حافظ على:

- Authentication Guards.
- Guest Guards.
- 2FA.
- Deep Links.
- Navigation Stack.
- Back Navigation.
- Checkout Routes.
- Payment Return.
- Order Confirmation.
- Startup Routing.

تجنب Redirect Loops.

لا تنفذ Navigation Side Effects عشوائيًا داخل Provider build.

### 9.5 Localization Migration

استبدال:

`.tr`

و:

`AppTranslations`

باستخدام Flutter Localization وARB أو حل مناسب.

يجب المحافظة على:

- العربية.
- الإنجليزية.
- RTL / LTR.
- جميع النصوص.
- الترجمة الديناميكية.
- حفظ اللغة.
- رسائل الأخطاء.
- رسائل الدفع والشراء.

المصفوفة القديمة وثقت نحو 560 استدعاء ترجمة في 106 ملفات واجهة؛ أعد حصر العدد الحالي.

### 9.6 Dependency Injection

إزالة:

- InitialBinding.
- Get.put.
- Get.find.
- GetxService.
- GetX Bindings.
- Compatibility Facades.
- Legacy Bridge.

مع الحفاظ على دورة حياة صحيحة لـ Riverpod Providers.

لا تكرر ApiClient أو AuthSession أو TokenStorage.

### 9.7 UI Utilities

استبدال الاستخدامات المتبقية من:

- Get.dialog.
- Get.showSnackbar.
- Get.overlayContext.

باستخدام أدوات Flutter الأصلية أو حلول ملائمة.

### 9.8 Final GetX Removal

لا تحذف مكتبة GetX في بداية المرحلة.

التسلسل الصحيح:

1. جرد جميع الاستخدامات.
2. ترحيل المستهلكين.
3. اختبار السلوك.
4. حذف Facades.
5. حذف Bindings وControllers القديمة.
6. حذف Routes القديمة.
7. حذف نظام الترجمة القديم.
8. إزالة GetX من pubspec.yaml عند انعدام الحاجة.
9. flutter pub get.
10. إعادة فحص المشروع بالكامل.

الهدف النهائي: صفر اعتماد مباشر على GetX في كود التطبيق.

---

# 8. قواعد معمارية ملزمة

هذه قواعد أساسية لا يجوز تجاوزها دون مبرر هندسي واضح:

1. Riverpod 3.5.0 هو المعيار لإدارة الحالة المشتركة.
2. لا تنشئ أكثر من State Owner للميزة الواحدة.
3. لا تعد إلى GetX لتنفيذ أي ميزة جديدة.
4. استخدم Providers وNotifiers المكتوبة يدويًا وفق نمط المشروع.
5. لا تدخل build_runner أو Riverpod Code Generation أو ملفات .g.dart دون موافقة وتبرير.
6. لا تضع Business Logic داخل Widgets.
7. لا تستخدم Providers لحالة UI محلية بسيطة دون حاجة.
8. لا تجعل Repositories مسؤولة عن التنقل.
9. لا تنقل منطق الأسعار والمخزون إلى Flutter.
10. Laravel هو المرجع النهائي لكل عملية مالية.
11. لا تسمح ببيانات Mock لإنشاء طلب ناجح في Release.
12. حافظ على عزل بيانات الحسابات.
13. تعامل مع الشبكة المنقطعة أثناء الشراء بوصفها نتيجة غير مؤكدة حتى تتم المصالحة مع الخادم.
14. حافظ على تصميم التطبيق الحالي دون إعادة تصميم غير مطلوبة.

---

# 9. ضوابط العمل على المستودعات

قبل أي تعديل:

```powershell
git status --short
git branch --show-current
git diff --check
```

نفذها في كل مستودع.

ممنوع:

- git reset --hard
- git clean -fd
- حذف تعديلات المستخدم.
- عمل Stash تلقائيًا.
- الكتابة على قاعدة الإنتاج.
- إجراء مدفوعات حقيقية.
- Commit أو Push تلقائي دون طلب.

استخدم قاعدة بيانات Staging معزولة.

لا تعتبر نتائج الاختبارات السابقة دليلًا على أن الاختبارات الحالية ما زالت ناجحة.

أعد تشغيلها بنفسك.

لا تكتب PASS لاختبار لم يتم تنفيذه.

لا تختلق ملفات أو مسارات أو نتائج.

---

# 10. طريقة تنفيذ العمل

لا تنفذ المشروع كاملًا بتغيير ضخم دفعة واحدة.

استخدم أسلوبًا تدريجيًا:

1. Audit.
2. Baseline.
3. Implementation.
4. Unit Tests.
5. Integration Tests.
6. Regression Tests.
7. Documentation.
8. Quality Gate.

كل مجموعة تغييرات يجب أن تكون مفهومة وقابلة للمراجعة والتراجع.

إذا ظهرت مشكلة حرجة، أوقف التنفيذ وعالجها قبل الاستمرار.

لا تضحِّ بالأمان أو سلامة البيانات من أجل إنهاء المرحلة بسرعة.

---

# 11. نقطة الاستئناف الفعلية

أنت لا تبدأ مشروعًا جديدًا.

أنت تستكمل مشروعًا وصل إلى نهاية Phase 08.2.

المرحلة التالية المخطط لها هي Phase 09.

لكن قبل إزالة GetX، يجب تنفيذ Security Preflight مستقل للتحقق من:

1. Coupon Concurrent Redemption.
2. Monetary Precision.
3. Receipt Privacy and Reuse.
4. Idempotency Fencing and Recovery.
5. Real Android Flutter UI Integration.

أنشئ:

`docs/architecture/phase-09-final-migration/00_SECURITY_PREFLIGHT.md`

إذا بقيت مشكلة مالية أو أمنية حرجة، أوقف الانتقال إلى تنفيذ إزالة GetX، ووثق المشكلة وإصلاحها.

إذا اجتازت بوابة الأمان، ابدأ تنفيذ Phase 09 تدريجيًا.

لا تعتبر تقرير Phase 08.2 الرسمي وحده إثباتًا كافيًا؛ راجع المصدر الحقيقي.

---

# 12. متطلبات التوثيق النهائي

أنشئ المجلد:

`docs/architecture/phase-09-final-migration/`

وأنشئ الوثائق التالية:

1. `00_SECURITY_PREFLIGHT.md`
2. `01_IMPLEMENTATION_REPORT.md`
3. `02_GETX_REMOVAL_MATRIX.md`
4. `03_AUTH_AND_SESSION_FINAL_ARCHITECTURE.md`
5. `04_ROUTING_AND_DEEP_LINK_MIGRATION.md`
6. `05_LOCALIZATION_MIGRATION.md`
7. `06_DEPENDENCY_INJECTION_AND_PROVIDER_LIFECYCLE.md`
8. `07_FEATURE_COMPATIBILITY_AND_UI_UX.md`
9. `08_SECURITY_AND_ACCOUNT_ISOLATION.md`
10. `09_TEST_RESULTS.md`
11. `10_ANDROID_STAGING_E2E.md`
12. `11_FINAL_GETX_DEPENDENCY_AUDIT.md`
13. `12_PHASE_09_GATE.md`

استخدم Mermaid في شرح:

- Application Bootstrap.
- Riverpod Provider Ownership.
- Authentication Routing.
- Checkout Lifecycle.
- Localization.
- Account Isolation.

اربط النتائج بمسارات الملفات الفعلية والاختبارات الفعلية.

---

# 13. تعريف اكتمال المشروع

لا تعتبر Phase 09 مكتملة إلا عند تحقق جميع الشروط:

- لا توجد Controllers أو Services مملوكة للتطبيق تعتمد على GetX.
- لا يوجد GetMaterialApp.
- لا يوجد GetX Navigation.
- لا يوجد GetX Localization.
- لا توجد Compatibility Facades.
- لا توجد Bindings قديمة.
- لا يوجد اعتماد مباشر على GetX في كود التطبيق.
- إزالة حزمة get من pubspec.yaml إذا لم تعد مطلوبة.
- Riverpod هو المالك الوحيد للحالة المشتركة.
- المصادقة و2FA يعملان.
- جميع الشاشات والتنقلات تعمل.
- العربية والإنجليزية تعملان.
- Checkout وOrders يعملان.
- لا يوجد تسريب بيانات بين الحسابات.
- لا توجد Mock Financial Success في Release.
- الاختبارات ناجحة.
- Android UI E2E ناجح فعليًا.
- Flutter Analyze نظيف.
- جميع الوثائق مكتملة.

لا تدّعِ Production Ready بمجرد نجاح Unit Tests.

---

# 14. أسلوب التواصل والتقارير

تحدث بالعربية عند شرح النتائج، مع إبقاء أسماء التقنيات والكلاسات والمصطلحات البرمجية بالإنجليزية.

كن صريحًا في تقييم الجودة.

لا تجامل في إصدار PASS إذا كانت هناك مشكلة حقيقية.

عند كل مرحلة:

- اشرح ما تم.
- اذكر الملفات التي تغيرت.
- اذكر سبب التغيير.
- اذكر الاختبارات التي نفذت فعلًا.
- وضح المشكلات المتبقية.
- أعطِ قرار Gate واضحًا.

لا تطلب مني إعادة معلومات موجودة في هذا السياق.

إذا لم تستطع الوصول إلى المستودعات المحلية، وضح ذلك ولا تدّعِ فحصها.

---

# 15. المهمة المطلوبة منك الآن

ابدأ من نقطة التوقف الحالية.

**أولًا:** اقرأ توثيق Phase 00 إلى Phase 08.2 من المستودعات نفسها.

**ثانيًا:** افحص حالة Git والاختبارات الحالية.

**ثالثًا:** نفذ Security Preflight بصورة مستقلة، وخصوصًا اختبار تزامن استخدام الكوبونات على MySQL InnoDB.

**رابعًا:** إذا اجتاز الفحص، ابدأ Phase 09: Final GetX Removal & Router Cutover.

**خامسًا:** لا تحذف GetX قبل ترحيل جميع المستهلكين والتحقق من عدم وجود اعتماد عليهم.

**سادسًا:** لا تنشر إلى الإنتاج ولا تنفذ معاملات مالية حقيقية.

**المبدأ الأساسي: استكمل العمل من حيث توقف المشروع، ولا تعِد بناء ما تم إنجازه، ولا تفترض أن ما ورد في التقارير صحيح حتى تتحقق منه في الكود الفعلي.**