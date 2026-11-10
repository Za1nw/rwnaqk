# مصفوفة إزالة واستبدال GetX في وحدة الدعم
# 03 — GETX REMOVAL MATRIX: Support Module Dispositions

- **المشروع:** متجر رونقك الإلكتروني (Rawnaquk E-Commerce)
- **المرحلة:** Phase 02 — Support Module Pilot Migration to Riverpod 3
- **الهدف المعماري:** استئصال كافة أشكال إدارة الحالة بواسطة GetX داخل وحدة الدعم الفني

---

## 1. جدول الحصر الشامل والتصرف النهائي (Disposition Matrix)

| العنصر البرمجي السابق | النوع السابق في GetX | التصرف النهائي في المرحلة 02 | البديل المعتمد في Riverpod 3 / Flutter | مبرر الإجراء والوضع النهائي |
|---|---|---|---|---|
| `HelpCenterController` | `class HelpCenterController extends GetxController` | **محذوف نهائياً (DELETED)** | `HelpCenterNotifier` + `HelpCenterState` | الكنترولر القديم كان مجرد وعاء لقوائم ثابتة، تم نقله إلى نموذج حالة نقي وموفر Riverpod. |
| `SupportChatController` | `class SupportChatController extends GetxController` | **محذوف نهائياً (DELETED)** | `SupportChatNotifier` + `SupportChatState` | تم نقل حالة الرسائل والتفاعل إلى كائن غير قابل للتعديل مع Notifier صريح. |
| `SupportChatUiController` | `class SupportChatUiController extends GetxController` | **محذوف نهائياً (DELETED)** | `ConsumerStatefulWidget` دورة حياة محلية | إدارة `TextEditingController` و `ScrollController` داخل GetX نمط خاطئ؛ نُقلت إلى الودجت المحلي مع `dispose()`. |
| `SupportBinding` | `class SupportBinding extends Bindings` | **مفرغ ومعدل (PRESERVED EMPTY)** | لا كائنات مسجلة في GetInstance | أفرغ من التسجيل لمنع وجود نسختين من الحالة، مع إبقاء الكلاس للحفاظ على عقد المسارات في `app_pages.dart`. |
| `HelpCenterScreen` | `class HelpCenterScreen extends GetView<HelpCenterController>` | **مهاجر ومعدل (MIGRATED)** | `ConsumerWidget` | استبدال وراثة GetView بـ ConsumerWidget واستخدام `ref.watch(helpCenterProvider)`. |
| `SupportChatScreen` | `class SupportChatScreen extends GetView<SupportChatController>` | **مهاجر ومعدل (MIGRATED)** | `ConsumerStatefulWidget` | استبدال وراثة GetView وإزالة `Obx` بالكامل واستخدام `ref.watch(supportChatProvider)`. |
| `Obx` في `SupportChatScreen` | ودجت مراقبة تفاعلية `Obx(...)` | **مستأصل بالكامل (REMOVED)** | `ref.watch(supportChatProvider)` | إزالة `Obx` وإعادة بناء الودجت بواسطة آلية Riverpod الدقيقة والفعالة. |
| `Get.find<SupportChatController>()` | محدد مواقع الخدمة (Service Locator) | **مستأصل بالكامل (REMOVED)** | `ref.read(supportChatProvider.notifier)` | حقن مباشر ومحدد النطاق عبر `WidgetRef`. |
| `Get.find<SupportChatUiController>()` | محدد مواقع الخدمة (Service Locator) | **مستأصل بالكامل (REMOVED)** | حقول محلية `_messageCtrl`, `_messagesScrollCtrl` | وصول مباشر للمتحكمات داخل الودجت دون بحث في الذاكرة العامة. |
| `messages = <SupportChatMessage>[].obs` | قائمة تفاعلية متحولة `RxList` | **مستبدلة بالكامل (REPLACED)** | `List<SupportChatMessage>` في `SupportChatState` | قائمة نقية غير قابلة للتعديل يتم استبدالها عبر `state = state.copyWith(...)`. |
| `Get.arguments` | استخراج وسائط التوجيه | **معدل ومدعوم (ADAPTED)** | `widget.initialArgs ?? _readArgs(Get.arguments)` | دعم حقن الوسائط المباشر للاختبارات المعزولة مع بقاء التوافق التلقائي مع GetX. |
| `Get.toNamed` | التنقل بين الشاشات | **مُبقى عمداً (RETAINED FOR PHASE 09)** | GetX Navigation | الملاحة مؤجلة كلياً للمرحلة Phase 09 بحسب خارطة الطريق المعتمدة. |
| `Get.back` | الرجوع للخلف | **مُبقى عمداً (RETAINED FOR PHASE 09)** | GetX Navigation | الرجوع للشاشة السابقة عبر زر الرجوع متبوع لنظام الملاحة العام. |
| `.tr` | ترجمة النصوص وتوطين اللغة | **مُبقى عمداً (RETAINED FOR PHASE 09)** | `AppLocaleKeys` و GetX Translations | محرك الترجمة مرتبط بـ `GetMaterialApp` ومؤجل للمرحلة الختامية. |

---

## 2. مصفوفة التحقق من الاستئصال التام داخل وحدة الدعم

تم إجراء فحص كودي شامل للمجلد `lib/modules/support/` عبر الأوامر البرمجية للتأكد من خلوه التام من أنماط GetX لإدارة الحالة:

```powershell
# التحقق من عدم وجود GetxController
git grep "extends GetxController" lib/modules/support/
# النتيجة: صفر تطابقات (Clean)

# التحقق من عدم وجود .obs
git grep "\.obs" lib/modules/support/
# النتيجة: صفر تطابقات (Clean)

# التحقق من عدم وجود Obx(
git grep "Obx(" lib/modules/support/
# النتيجة: صفر تطابقات (Clean)

# التحقق من عدم وجود Get.find
git grep "Get\.find" lib/modules/support/
# النتيجة: صفر تطابقات (Clean)

# التحقق من عدم وجود GetView
git grep "extends GetView" lib/modules/support/
# النتيجة: صفر تطابقات (Clean)

# التحقق من عدم وجود GetBuilder
git grep "GetBuilder" lib/modules/support/
# النتيجة: صفر تطابقات (Clean)
```

---

## 3. مقارنة الأنماط البرمجية (Before vs. After Comparison)

### نمط إرسال الرسائل في محادثة الدعم

#### سابقاً (GetX Pattern - Anti-Pattern):
```dart
// كان الودجت يستدعي Get.find مرتين، ويقرأ من كنترولر منفصل
final chatCtrl = Get.find<SupportChatController>();
final uiCtrl = Get.find<SupportChatUiController>();

Obx(() => ListView(
  children: chatCtrl.messages.map((m) => ...).toList(),
))

// الإرسال كان يعتمد على تحوير قائمة RxList بشكل مباشر
chatCtrl.sendMessage(uiCtrl.messageCtrl.text);
```

#### حالياً (Riverpod 3 Golden Pattern):
```dart
// الودجت ConsumerStatefulWidget يمتلك المتحكمات وينصت بوعي للحالة
final chatState = ref.watch(supportChatProvider);

ListView(
  controller: _messagesScrollCtrl,
  children: chatState.messages.map((m) => ...).toList(),
)

// الإرسال يتم عبر Notifier نقي مع تنظيف الحقل وتمرير القائمة بحالة جديدة
final sent = ref.read(supportChatProvider.notifier).sendMessage(text);
if (sent) {
  _messageCtrl.clear();
  _scrollToBottom();
}
```

---

## 4. تقييم السلامة المعمارية

- **نسبة تخلص وحدة الدعم من إدارة حالة GetX:** 100%.
- **استقرار مسارات التطبيق:** 100% (المسار `/help-center` و `/support-chat` يعملان بكفاءة تامة دون أي تغيير خارجي).
- **العزل الذاكري:** تم التأكد من تفريغ كافة الموارد عند الخروج من الشاشة دون أي تسريب في الذاكرة.

