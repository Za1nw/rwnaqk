# Riverpod 3.5 API — verified quick reference (2026-11-09)

**Always read first:** `docs/RIVERPOD3-OFFICIAL-DOCS-2026-11-09-AR.md` at the extracted package root; all links and example patterns live there. This reference is a concise enforcement checklist.

| Old GetX API | Riverpod 3.5 destination | Owner |
|---|---|---|
| `GetxController` + `.obs` | `Notifier<T>` / `AsyncNotifier<T>` with immutable state | presentation |
| `Get.find<T>()` | `ref.watch(repoProvider)` in providers, `ref.read` in actions | DI providers |
| `Get.put` / `Get.lazyPut` | `Provider<T>((ref) => dependency)` plus `overrideWith` | composition |
| `Obx`, `GetBuilder` | `ConsumerWidget` / `Consumer` / `ConsumerStatefulWidget` | presentation |
| `ever`, `once` | `ref.listen` where side effects appropriate | presentation/handler |
| `GetxService` | plain Dart service + Provider | core/domain/data |
| GetX routing/middleware | KEEP until separate navigation migration gate | app routing |

## Accurate 3.5 notes

- Stable Riverpod/Flutter Riverpod 3.5.0 (2026-11-06), **Dart >=3.12**. Verify current project first.
- `riverpod_annotation` 4.0.8 and `riverpod_generator` 4.0.10 optional, both Dart >=3.12. `riverpod_lint` 3.2.0 needs Dart 3.13 dev; optional and *not automatic*.
- Legacy providers (`StateNotifierProvider`, `StateProvider`, `ChangeNotifierProvider`) moved to `flutter_riverpod/legacy.dart`; avoid in new migration code.
- `Ref` is unified, no old typed `Ref<T>`. AutoDispose types unified; use `.autoDispose` manually or default generated disposal.
- Riverpod 3 automatically retries *provider computations*. Never put POST /orders/register/payment/receipt in a build method.
- Riverpod 3 throws for using Ref after disposal: use `ref.mounted` after await and cancellation via `ref.onDispose`.
- Version 3.5 introduces `ProviderDisposedException` for disposed provider `.future` and fixes listener/resume issues. Handle cancellations separately from server business errors.
- `ProviderObserver` uses `ProviderObserverContext` as first parameter.
- `.family` Notifier classes are unified; avoid obsolete `FamilyNotifier` examples.
- Manually declared Provider<T> override example: `repoProvider.overrideWith((ref) => fakeRepo)`; never blindly paste Riverpod 2 `overrideWithValue` examples.
- Offline persistence and Mutations are EXPERIMENTAL; avoid as default for financial/auth state.

## Safe examples

```dart
final apiProvider = Provider<ApiClient>((ref) => makeApiClient());
final catalogProvider = AsyncNotifierProvider<Catalog, List<Product>>(Catalog.new);
class Catalog extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() async => ref.watch(productsRepositoryProvider).list();
}
```

Example uses conceptual `ApiClient`/`Product`/`list` identifiers: adapt them to real code, do not assume those methods exist.

For full runnable-contained quantity examples and tests use `docs/RIVERPOD3-OFFICIAL-DOCS-2026-11-09-AR.md`.

### Official source URLs

- https://riverpod.dev/docs/introduction/getting_started
- https://riverpod.dev/docs/whats_new
- https://riverpod.dev/docs/3.0_migration
- https://riverpod.dev/docs/concepts2/retry
- https://riverpod.dev/docs/how_to/testing
- https://pub.dev/packages/flutter_riverpod/changelog
