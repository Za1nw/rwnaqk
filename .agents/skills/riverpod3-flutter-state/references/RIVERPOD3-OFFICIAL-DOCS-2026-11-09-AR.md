# دليل Riverpod 3 الحديث — رونقك / نسخة مراجعة 9 نوفمبر 2026

> هذا **شرح عربي أصلي ومختصر للمصادر الرسمية**، وليس نسخة مطابقة من موقع Riverpod. الروابط الحية أدناه هي المرجع النهائي عند اختلاف الإصدارات. أُعدّ استنادًا إلى صفحات Riverpod الرسمية وصفحات إصدارات pub.dev، بمراجعة بتاريخ 2026-11-09. لم تتم تجربة الأمثلة على جهاز المستخدم؛ نفذ تحليل المشروع واختباراته قبل اعتماد أي تغيير.

## 1) الإصدارات المؤكدة وتوافق الأدوات

| الحزمة | أحدث إصدار مستقر بتاريخ المراجعة | الحد الأدنى من Dart بحسب pub.dev | الدور |
|---|---|---|---|
| `flutter_riverpod` | **3.5.0** — 2026-11-06 | **3.12** | Providers وConsumers في Flutter |
| `riverpod` | **3.5.0** | **3.12** | النواة |
| `riverpod_annotation` | **4.0.8** | **3.12** | `@riverpod` إذا اخترت توليد الكود |
| `riverpod_generator` | **4.0.10** | **3.12** | توليد Providers |
| `riverpod_lint` | **3.2.0** | **3.13 (dev)** | أداة Lint *اختيارية*؛ لا تثبتها تلقائيًا مع Dart 3.12 |

**قرار التثبيت:** افحص `flutter --version` و`dart --version` وقيود `pubspec.yaml` و`flutter pub outdated`. لا تُغيّر Flutter أو Dart تلقائيًا، ولا تفرض إصدارًا يتعذر على SDK الحالي استخدامه. مثال: عند استخدام Dart 3.7–3.11، قد يكون `flutter_riverpod 3.3.2` آخر خط ملائم **بحسب توافق التبعيات الفعلي** (افحص resolver)، ولا تفرض `3.5.0`.

**ملاحظة:** أصبح `flutter_riverpod 3.5.0` يعتمد أيضًا على `material_ui` داخليًا؛ اتبع تعليمات التثبيت الرسمية وتحقق من توافق نسختك. لا تُعد كتابة واجهات Flutter Material الحالية لمجرد تغيّر اعتماد داخلي.

### أوامر Windows PowerShell

```powershell
Set-Location 'D:\project\laravel\app-rwnaqk\rwnaqk_frontend'
flutter --version
dart --version
flutter pub outdated
flutter analyze
flutter test
```

بعد التأكد من SDK:

```powershell
flutter pub add flutter_riverpod:^3.5.0
# اختياري *لاحقًا*: codegen فقط بعد اجتياز Pilot وتوافق dependency solver
flutter pub add riverpod_annotation:^4.0.8
flutter pub add dev:riverpod_generator:^4.0.10
flutter pub add dev:build_runner
# dart run build_runner build --delete-conflicting-outputs
```

**لا تزل `get` من `pubspec.yaml` حتى تنتهي جميع الوحدات والمسارات والخدمات والاختبارات من استخدامه.**

## 2) المعمارية الصحيحة لحزمة 3.5

```text
ProviderScope (حول GetMaterialApp مؤقتًا)
  └─ Feature UI: ConsumerWidget / ConsumerStatefulWidget
       └─ WidgetRef.watch(NotifierProvider/AsyncNotifierProvider)
            └─ Notifier / AsyncNotifier (حالة عرض غير قابلة للتعديل المباشر)
                 └─ Ref.watch(repositoryProvider)
                      └─ Pure repository interface + real/fake implementation
                           └─ ApiClient (Dio) → Laravel
```

**مسؤوليات:**
- `Provider<T>`: تهيئة/حقن خدمة أو Repository بلا حالة تفاعلية خاصة بالواجهة.
- `FutureProvider<T>`: قراءة غير قابلة للتعديل من UI؛ دعم `AsyncValue` والتخزين المؤقت؛ لا تضع POST حساسًا داخل `build`.
- `Notifier<T>`: حالة متزامنة وطرق تعديلها (مثل Filters/Cart draft).
- `AsyncNotifier<T>`: بيانات غير متزامنة (كتالوج/طلبات/جلسة) مع `AsyncValue`.
- `StreamProvider`/`StreamNotifier`: الاشتراك في Stream عند وجود حاجة فعلية.
- `ConsumerWidget`: مراقبة Providers؛ و`ConsumerStatefulWidget` حين تتطلب الشاشة `TextEditingController`, focus أو animation lifecycle.
- احتفظ بـ Models/Repositories/Services النقية الموجودة؛ لا تنقل كل منطق التجارة إلى Notifier.

## 3) أمثلة حديثة صحيحة بدون Code Generation

### 3.1 مزوّد Repository مع Override للاختبارات

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class IProductsRepository {
  Future<List<String>> listProductNames();
}

final productsRepositoryProvider = Provider<IProductsRepository>((ref) {
  throw UnimplementedError('Override in composition root or tests');
});
```

**اختبار override صحيح:**

```dart
final container = ProviderContainer.test(overrides: [
  productsRepositoryProvider.overrideWith((ref) => fakeRepository),
]);
```

لـ `Provider<T>` استخدم `overrideWith((ref) => implementation)` بدل نسخ snippets `overrideWithValue` من إصدارات قديمة دون فحص API.

### 3.2 Notifier للحالة المتزامنة

```dart
final quantityProvider = NotifierProvider<QuantityController, int>(
  QuantityController.new,
);

class QuantityController extends Notifier<int> {
  @override
  int build() => 1;

  void increment() => state = state + 1;
  void decrement() => state = state > 1 ? state - 1 : 1;
}
```

```dart
class QuantityView extends ConsumerWidget {
  const QuantityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(quantityProvider);
    return TextButton(
      onPressed: () => ref.read(quantityProvider.notifier).increment(),
      child: Text('Quantity: $quantity'),
    );
  }
}
```

### 3.3 AsyncNotifier لبيانات خادم

```dart
final productNamesProvider =
    AsyncNotifierProvider<ProductNamesController, List<String>>(
  ProductNamesController.new,
);

class ProductNamesController extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    final repository = ref.watch(productsRepositoryProvider);
    return repository.listProductNames();
  }

  Future<void> reload() async {
    final repository = ref.read(productsRepositoryProvider);
    state = const AsyncLoading();
    final result = await AsyncValue.guard(repository.listProductNames);
    if (!ref.mounted) return;
    state = result;
  }
}
```

```dart
final result = ref.watch(productNamesProvider);
return switch (result) {
  AsyncData(:final value) => Text(value.join(', ')),
  AsyncError(:final error) => Text('Error: $error'),
  _ => const CircularProgressIndicator(),
};
```

`ref.mounted` مهم بعد `await`: في Riverpod 3 قد يؤدي استخدام `Ref` أو Notifier بعد التخلص منه إلى استثناء بدل الفشل الصامت.

## 4) أهم تغييرات Riverpod 3 عن الشروحات القديمة

| الموضوع | المعتمد في Riverpod 3 |
|---|---|
| `StateProvider`, `StateNotifierProvider`, `ChangeNotifierProvider` | موجودة للتراث فقط عبر `package:flutter_riverpod/legacy.dart`؛ لا تستخدمها في وحدات جديدة |
| `Ref` | بدون وسيط نوعي قديم مثل `Ref<MyType>` في التوليد الحديث |
| `AutoDispose*` classes | توحدت الواجهات؛ استخدم `.autoDispose` أو `@Riverpod(keepAlive: ...)` |
| `Notifier` families | تم توحيدها مع `Notifier` بدل `FamilyNotifier` القديمة |
| `ref.mounted` | افحصه قبل استخدام Ref/state بعد `await` |
| فشل إنشاء Provider | **إعادة محاولة تلقائية افتراضيًا**؛ لا تفترض أنها اختيارية |
| `ProviderObserver` | التوقيع الجديد يعتمد `ProviderObserverContext` |
| مقارنة الحالة | جميع Providers تعتمد `==` في تصفية الإشعارات افتراضيًا |
| عند dispose قبل انتهاء `.future` | 3.5.0 يستخدم `ProviderDisposedException` بدل `StateError` |
| تجميد/استئناف Listener | معالجة دورة الحياة أكثر صرامة؛ لا تستخدم Ref بعد dispose |
| `overrideWith`/`overrideWithValue` | اعتمد التوقيع المطابق **لنوع Provider** والمستند الحالي، لا مثالًا عامًا من Riverpod 2 |

### إعادة المحاولة التلقائية

في Riverpod 3، **فشل حساب Provider** يعاد تلقائيًا افتراضيًا (حتى 10 محاولات تقريبًا بتأخير متزايد). هذا **لا يعني** إعادة إرسال `POST` تلقائيًا إذا نُفذ كـ `Notifier` action، ومع ذلك:
- لا تضع إنشاء طلب/دفع/تسجيل/رفع سند داخل `FutureProvider` أو `AsyncNotifier.build()`.
- عمليات POST الحساسة يجب أن تُنفذ من method صريح مع حارس in-flight وIdempotency Key ثابت عند إعادة المحاولة.
- لقراءات `GET` يمكنك تخصيص retry/إيقافه على مستوى Provider إذا كانت 401/422 أو فشل مصادقة لا يستحق إعادة محاولة.

مثال تعطيل retry على Provider معين:

```dart
final accountProvider = FutureProvider<String>(
  (ref) async => loadAccountName(),
  retry: (retryCount, error) => null,
);
```

تأكد من أن `loadAccountName` معرفة فعليًا في مشروعك؛ المثال تصوري لتوقيع `retry`.

## 5) دقة دورة الحياة والملكية

- `ref.watch` داخل `build` أو Provider لمعرفة القيمة وتحديث المستهلك عند تغيرها.
- `ref.read` داخل Action/Callback (`onPressed` أو method) دون إنشاء تبعية تفاعلية.
- `ref.listen` للآثار الجانبية؛ لا تنشئ listener في `build` بصورة تؤدي للتكرار.
- `ref.onDispose` لإلغاء Timer/Stream/CancelToken، دون إجراء state writes على مزود آخر أثناء الإغلاق.
- `.autoDispose` للشاشات المؤقتة و`family` الديناميكية؛ `keepAlive` فقط عند وجود مبرر واضح.
- Providers المولدة بـ `@riverpod` **تعمل autoDispose افتراضيًا**؛ الافتراضي يختلف في الإنشاء اليدوي.
- بيانات جلسة مستخدم A يجب ألا تظهر للمستخدم B؛ invalidation + clearing local cache يطبق عند Logout/user switch.
- لا تمتلك GetX وRiverpod مصدرين يكتبان لنفس الحالة؛ الجسر المؤقت لا يغيّرها بالاتجاهين.

## 6) اختبار Providers وWidgets

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('quantity changes', () {
    final container = ProviderContainer.test();
    expect(container.read(quantityProvider), 1);
    container.read(quantityProvider.notifier).increment();
    expect(container.read(quantityProvider), 2);
  });
}
```

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      productsRepositoryProvider.overrideWith((ref) => fakeRepository),
    ],
    child: const MaterialApp(home: ProductsPage()),
  ),
);
```

- حاوية مستقلة لكل اختبار، ولا تسرّب State بين الاختبارات.
- وفّر override صريحًا لـ Fake vs Remote؛ لا تستخدم Mock fallback عند فشل API الحقيقي.
- اختبر Loading/Error/Empty، الإلغاء والبحث، تغيير الحساب و401، وتتابع أحداث Timeout.
- لا تحذف كود GetX القديم حتى تكون اختبارات Unit/Widget وReal Staging E2E للوحدة ناجحة.

## 7) Code generation: اختياري لا إجباري

يفضل فريق Riverpod الـ `@riverpod` لكثرة مزايا العائلات والإدارة التلقائية، لكن **لا تخلط ترحيل GetX مع إدخال Codegen دفعة واحدة**. أولًا ترحيل Pilot باستخدام API اليدوية ثم قرر توحيد الأسلوب بعد التأكد من التوافق.

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'counter.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;
  void increment() => state++;
}
```

شغّل من PowerShell:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

في codegen generated providers افتراضيًا autoDispose، استخدم `@Riverpod(keepAlive: true)` للخدمات المطلوبة على مستوى التطبيق إذا كان ذلك آمنًا.

## 8) حواجز أمن المتجر التي تبقى كما هي

- سجلات الطلبات `OrderGroup/Order` لا تُخترع داخل الـ Notifier؛ استخدم Repositories الحالية.
- الأسعار والمخزون والكوبون والشحن تُحتسب على Laravel؛ Riverpod يعرضها فقط.
- `X-Idempotency-Key` لا يتجدد عند Retry لنفس الطلب؛ احفظ الطلب المعلّق وفق آلية التطبيق.
- مسح `auth_token` يتم عبر `IAuthTokenStorage` المخصص، وليس SharedPreferences العادية.
- لا ترجع تلقائيًا لبيانات وهمية في وضع الإنتاج أو Staging الحقيقي عند فشل Laravel.
- أبقِ GetX Navigation/Bindings القديمة خلال المراحل المختلطة؛ كل خطوة تنقل Module واحدًا فقط.

## 9) الروابط الرسمية المباشرة (مصدر الحقيقة)

**Riverpod Documentation**
- Getting started: https://riverpod.dev/docs/introduction/getting_started
- What's new in Riverpod 3: https://riverpod.dev/docs/whats_new
- Migration from 2.x to 3.x: https://riverpod.dev/docs/3.0_migration
- Providers: https://riverpod.dev/docs/concepts2/providers
- Consumers: https://riverpod.dev/docs/concepts2/consumers
- Refs: https://riverpod.dev/docs/concepts2/refs
- Automatic dispose: https://riverpod.dev/docs/concepts2/auto_dispose
- Automatic retry: https://riverpod.dev/docs/concepts2/retry
- Overrides: https://riverpod.dev/docs/concepts2/overrides
- Tests: https://riverpod.dev/docs/how_to/testing
- Code generation: https://riverpod.dev/docs/concepts/about_code_generation
- DO / DON'T: https://riverpod.dev/docs/root/do_dont

**pub.dev version sources**
- https://pub.dev/packages/flutter_riverpod/versions
- https://pub.dev/packages/flutter_riverpod/changelog
- https://pub.dev/packages/riverpod_annotation/versions
- https://pub.dev/packages/riverpod_generator/versions
- https://pub.dev/packages/riverpod_lint/versions

**التعامل مع التحديثات:** هذه روابط حية، وأرقام الإصدارات لقطة موثقة بتاريخ 2026-11-09. قبل كل ترحيل كبير أعد التحقق من pub.dev و`flutter pub outdated`؛ لا تثبّت الإصدارات آليًا دون اختبار.
