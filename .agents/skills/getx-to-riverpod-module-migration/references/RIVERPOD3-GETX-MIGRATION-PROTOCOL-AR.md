# بروتوكول انتقال رونقك من GetX إلى Riverpod 3 — إصدار 2.0

## القاعدة

نقل **Module واحد في كل دورة**، دون حذف GetX أثناء المرحلة المختلطة. نقل المنطق، اختبار التكافؤ، تبديل الواجهة، ثم حذف الملفات التي تأكد عدم وجود أي مستهلك لها. كل خطوة لها commit / rollback مستقل.

## المرحلة 0 — تدقيق Core (قراءة فقط)

افحص `lib/core` قبل أي Module:

| المصدر | المطلوب |
|---|---|
| `bindings/initial_binding.dart` | كل Get.put/Get.lazyPut/Get.find وتبعياتها ومسارات استخدامها |
| `constants/api_endpoints.dart` مقابل `network/api_endpoints.dart` | مقارنة المحتوى والاعتماديات قبل اقتراح الدمج؛ تشابه الاسم لا يعني التكرار |
| `network/api_client.dart` | Dio Interceptors، 401، token storage، عدم تكرار جلسة المستخدم |
| `services/auth`, `services/geo` | استخدام GetConnect/GetxService، Data ownership ومراجع من Modules |
| `middleware/auth_middleware.dart` | المصادقة، route guard، verification/2FA |
| `theme`, `translations`, `widgets` | هل تحتاج GetMaterialApp/Get? لا تنقلها قبل اكتمال الـ Features |
| `data/` | نماذج DTO/Repository مكررة ومراجع متداخلة |

**مخرجات التدقيق:** `docs/migration/core-getx-inventory.md` و`dependency-graph.md` و`migration-ledger.md` و`verified-issues.md` و`core-repair-plan.md` مع file:line.

## المرحلة 1 — Core Stabilization

أصلح فقط المشاكل التي تثبتها مراجعة الكود والاختبارات؛ لا تعيد فتح تقارير قديمة حول التسريب أو تكرار الدفع لو كانت أصلحت بالفعل. اختبر `flutter analyze`, `flutter test`, وE2E المناسب على Staging. احتفظ بتبعية Dio وجلسة Sanctum والتخزين الآمن وMock Repos.

## المرحلة 2 — Riverpod Bootstrap

1. راجع SDK والإصدارات في دليل التوثيق المرفق.
2. أضف `flutter_riverpod` فقط إذا كان متوافقًا.
3. لفّ الجذر بـ `ProviderScope` وحافظ مؤقتًا على `GetMaterialApp` وRoutes وBindings القديمة.
4. أنشئ providers فقط لتبعيات `core` النقية غير المتنازع على ملكيتها، وأدخل Adapter ضيقًا عند الحاجة.
5. اختبر انطلاق التطبيق، إعادة التشغيل، تسجيل الخروج، استعادة الجلسة، تسجيل الدخول، navigation.

```dart
void main() {
  runApp(const ProviderScope(child: LegacyGetXApp()));
}
```

`LegacyGetXApp` اسم توضيحي: استخدم اسم الجذر الحقيقي. لا تضف ProviderScope ثانية بشكل عشوائي.

## المرحلة 3 — Pilot منخفض المخاطر

ابدأ بوحدة مستقلة محدودة بناءً على Dependency Graph وليس افتراض اسم مسبق. **لا تبدأ بـ auth/cart/checkout/orders** إذا كانت تؤثر على بوابة الطلبات والدفع. 

- سجّل واجهات/Controllers/GetX workers الحالية.
- أضف immutable state + Notifier/AsyncNotifier.
- حافظ على Repository interfaces وFake/Remote implementations.
- اختبر الحالات الثلاث: success/error/loading، ثم عزل الحالة وإلغاء المهام.
- انقل UI للوحدة فقط.
- ابحث عن مراجع ملفات GetX في كامل التطبيق.
- احذف ملفات الوحدة القديمة **بعد** قبول الاختبارات ومراجعة فرق الحذف فقط؛ اترك GetX في بقية الوحدات.

## المراحل 4+ — واحدة تلو الأخرى

يحدد ترتيب الوحدات من اعتمادات الكود الفعلية، عادة Features قليلة المخاطر قبل Customer/Auth ثم Catalog/Cart/Checkout/Orders. أعد تقييم الترتيب بعد كل دورة. لا يُسمح بنقل جماعي أو Rename كبير للمجلدات.

## حماية التجارة

- التوكن محفوظ في Secure Storage عبر IAuthTokenStorage؛ لا تجعله raw UI state.
- Register request يمر من Form→presentation→IAuthRepository→Dio→Laravel؛ الحفاظ على Validation/422/Verification/2FA.
- GetX/Riverpod لا يكونان مصدرين متعارضين لحالة المستخدم أو السلة.
- أسعار المنتج Quote تُحسب على Laravel؛ لا تتغير بسبب الترحيل.
- أمر شراء مهم = حدث صريح؛ no POST in provider build + idempotency persistence.
- إغلاق Session يفرغ بيانات A محليًا دون حذف سجلات B من Laravel.

## معايير القبول لكل وحدة

```text
[ ] ملفان: before/after wiring diagram
[ ] نفس العقود والنتائج والرسائل والـ UI
[ ] كود جديد مبني على Riverpod 3 APIs الصحيحة
[ ] لا double writes ولا Get.find داخل طبقات data/domain
[ ] Loading / empty / error / timeout / dispose / reload
[ ] Widget and Provider override tests
[ ] flutter analyze + flutter test passing
[ ] Real Staging E2E للوحدات الحساسة
[ ] مسح شامل للمراجع قبل حذف أي ملف
[ ] rerun tests after deletion
[ ] توثيق Commit Hash وخطة Rollback
```

**قرار كل وحدة:** PASS / FAIL / BLOCKED مع الأدلة. عند الفشل لا تنتقل للوحدة التالية.

**مرجع تقني:** `docs/RIVERPOD3-OFFICIAL-DOCS-2026-11-09-AR.md`.
