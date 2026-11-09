# Riverpod 3.x API quick reference

| GetX today | Riverpod 3 destination | Important note |
|---|---|---|
| `GetxController` + `.obs` | `Notifier` / `AsyncNotifier` + immutable state | Methods replace direct mutation |
| `Obx(() => ...)` | `Consumer` + `ref.watch(provider)` | Keep watches narrow |
| `Get.find<T>()` | `ref.read(repositoryProvider)` | Only in presentation/event code; dependencies via providers |
| `Get.put`, `Get.lazyPut` | `Provider` factories + overrides | One owner for each dependency |
| `GetBuilder` | `ConsumerWidget` / `ConsumerStatefulWidget` | Widget lifecycle differs |
| `ever`, `once`, `debounce` | `ref.listen`, cancellation, explicit debounce | Dispose listeners/timers correctly |
| `GetxService` | Plain Dart service + `Provider` | Do not turn service into a giant global Notifier |
| `Get.offAllNamed` | Keep existing GetX routes temporarily | Routing migration is independent |
| `GetMiddleware` | Existing router until separate gate | Auth redirects parity mandatory |
| `.obs` loading flags | `AsyncValue` or immutable command state | Keep non-idempotent submit explicit |

## Version notes

- Riverpod 3 discourages `StateProvider`, `StateNotifierProvider`, and `ChangeNotifierProvider` for new usage; these live under `flutter_riverpod/legacy.dart` or `riverpod/legacy.dart`.
- Riverpod 3 removes most `AutoDispose*` notifier subclasses; use supported `.autoDispose` variants or generator lifecycle configuration.
- `ref.mounted` should be checked after `await` for disposed-provider scenarios.
- Automatic retries occur on failure of provider initialization; never rely on implicit retry for POST /orders, payment, register, or upload actions.
- `ProviderScope` can wrap a **GetMaterialApp** during transitional coexistence; keep exactly one root composition boundary.
- Generated providers are an optional later step. If selected, verify compatible `riverpod_annotation` and `riverpod_generator` versions from pub.dev, then use `dart run build_runner build --delete-conflicting-outputs`.
- Avoid obsolete Riverpod 2 migration snippets that refer to removed `AutoDisposeAsyncNotifier` class patterns without verifying Riverpod 3.

## Auth and route separation

Store bearer tokens only in existing `IAuthTokenStorage`; a Riverpod provider exposes **session status / customer data**, not raw token for UI. Registration may require email verification or 2FA; don't route directly to Home just because HTTP 201 was returned. Handle server state explicitly. Retain GetX navigation until all routes, deep links, guards, dialogs, back behavior, theme and localization are tested against replacement router (if routing migration is later requested).
