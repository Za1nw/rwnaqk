# GetX official reference — verify before coding

Documentation reviewed: **2026-11-08**. Installed project version wins over generic web examples. `pub.dev/packages/get` currently lists stable **4.7.3** and a **5.0 prerelease**; do NOT treat the prerelease as a stable upgrade or combine incompatible examples.

Official sources:
- Package / releases: https://pub.dev/packages/get
- Project README (state, routes, tests): https://github.com/jonataslaw/getx/blob/master/README.md
- Dependency registration, Bindings and SmartManagement: https://github.com/jonataslaw/getx/blob/master/documentation/en_US/dependency_management.md
- State management / lifecycle: https://github.com/jonataslaw/getx/blob/master/documentation/en_US/state_management.md
- Flutter separation of concerns: https://docs.flutter.dev/app-architecture/guide
- Official agent skill locations (Antigravity): https://antigravity.google/docs/skills/

## Rx vs GetBuilder

| Pattern | Change notification | Read mechanism | Preferred use |
|---|---|---|---|
| `final count = 0.obs;` with `Obx(() => Text('${count.value}'))` | `.value` assignment | Rx read within `Obx` | Reactive widgets |
| `final items = <Product>[].obs` | `assignAll/add/removeAt`, etc. | Rx collection read within `Obx` | Reactive lists |
| `GetBuilder<MyController>` | controller `update()` or `update(['id'])` | `GetBuilder` rebuild | Explicit/manual coarse updates |

Do not assume `RxList<Product>` observes `products[index].stock--` when `Product` is a mutable plain object. Prefer an immutable replacement such as `products[index] = products[index].copyWith(stock: newStock)`; where unavoidable, use `products.refresh()` and test. For `Rx<Product>`, prefer replacing `.value` with a new immutable object. Do not call `refresh()` on every Rx update.

`Obx` must synchronously access at least one tracked reactive value during its builder. Do not do the observable read exclusively in a callback that runs later. Narrow the rebuild scope only when profiling or clear widget complexity justifies it.

## Registration / lifetime decision table

| API | What matters |
|---|---|
| `Get.put<T>(instance)` | Eager registration; lifetime depends on route ownership and SmartManagement settings |
| `Get.lazyPut<T>(() => T())` | Factory registration, created upon first `Get.find<T>()` |
| `Get.lazyPut<T>(() => T(), fenix: true)` | Recreates after deletion; **does not preserve old in-memory state** |
| `Get.putAsync<T>(() async => ...)` | Async registration must be awaited at appropriate bootstrap |
| `Get.create<T>(() => T())` | New object on each lookup; not for shared cart/session singletons |
| `GetxService` | Long-lived application service where justified; do not create one for each screen |
| `permanent: true` | Opt out of automatic disposal; document the owner and shutdown/reset needs |

`SmartManagement.full` is the default. The official docs distinguish `onlyBuilder` (only certain builder/binding registrations automatically disposed) and `keepFactory` (retains factories). The docs warn against global `keepFactory` alongside multiple Bindings. Audit a specific code path before changing this setting; version-specific behavior must be tested.

Route Bindings register deps when the route is opened and let GetX associate them with the route. A route-scoped repo/controller can be disposed; app-wide token storage/API client may need an explicit app-lifetime registration. Use constructor injection for the dependencies *inside* business classes.

## Controller lifecycle and workers

```dart
class SearchController extends GetxController {
  SearchController(this.repository);
  final SearchRepository repository;

  final query = ''.obs;
  Worker? _worker;
  bool _disposed = false;
  int _requestSequence = 0;

  @override
  void onInit() {
    super.onInit();
    _worker = debounce<String>(
      query,
      (_) => load(),
      time: const Duration(milliseconds: 350),
    );
  }

  Future<void> load() async {
    final request = ++_requestSequence;
    final term = query.value;
    final result = await repository.search(term);
    if (_disposed || request != _requestSequence) return;
    // Apply result to an Rx field here.
  }

  @override
  void onClose() {
    _disposed = true;
    _requestSequence++;
    _worker?.dispose();
    super.onClose();
  }
}
```

The above is a **pattern fragment**: repository and types are feature-provided. Wrap actual work with error handling and `try/finally`, cancel network requests when possible. `onInit()` is not an async override. `onReady()` is for post-first-frame work if genuinely needed. Dispose only resources the controller owns. API calls should not run from widget `build()`.

## Testing and navigation

- GetX's README documents `Get.reset()` to reset DI between tests and `Get.testMode = true` for navigation from controllers in tests.
- Register route dependencies in Bindings and keep `GetMaterialApp`/`GetPage` existing conventions while launch is near.
- `Get.find<T>()` from an unregistered dependency throws; do not hide missing composition behind catch-all errors or fallback global singleton creation.
- If a migration happens later, move **state management first**, and leave routing in GetX until a separate validated step.

## Be skeptical of claims

- Avoid marketing claims that GetX removes every possible lifecycle leak. Native subscriptions and controllers still require ownership-based cleanup.
- `fenix` is recreation, not persistence.
- Abstracting a repository protects *data/business* code, not GetX-bound widgets/controllers.
- Always inspect the exact GetX version and actual application behavior; documents may evolve.
