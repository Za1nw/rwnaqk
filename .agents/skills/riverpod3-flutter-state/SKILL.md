---
name: riverpod3-flutter-state
description: Implement safe, testable Flutter Riverpod 3 state management in a modular e-commerce app. Use for ProviderScope, Provider/Notifier/AsyncNotifier, repository dependency injection, async state, auth session scoping, and Riverpod testing. Preserve existing pure repositories and Laravel contracts.
---

# Flutter Riverpod 3 — Production State Management

## Purpose and prerequisites

Target **flutter_riverpod 3.x** (current verified stable: 3.5.0, 2026-11-09). Before adding packages, inspect `flutter --version`, `dart --version`, `pubspec.yaml`, and `flutter pub deps`. **3.5.0 requires Dart >=3.12**; resolve a compatible 3.x version if the project cannot upgrade, or propose an SDK upgrade for approval. Do not blindly modify Flutter SDK or pubspec. Verify all version-specific APIs against current official docs. Code generation (`riverpod_annotation`, `riverpod_generator`, `build_runner`) is optional and **must not** be imposed during initial migration.

Read `references/architecture-and-patterns.md`, `references/riverpod3-apis.md`, `references/testing-and-security.md` before implementing.

## Architecture contract

- Riverpod manages **presentation/application state and dependency composition**; it is not a backend, database, router, or substitute for repositories.
- UI -> `ConsumerWidget` / `ConsumerStatefulWidget` -> Notifier / AsyncNotifier -> repository interface -> existing Dio-based implementation -> Laravel.
- Keep domain models, business rules, repository contracts and DTO mappers **independent of Riverpod, GetX, and Flutter** whenever practical.
- Existing `ApiClient`, `IAuthTokenStorage`, `IAuthRepository`, `IProductsRepository`, `IOrdersRepository`, `IAddressesRepository` are assets: reuse, do not rewrite without a proven deficiency.
- Keep Laravel authoritative for price, coupon, stock, address coverage, shipping and order confirmation. No client-authoritative grand totals.
- Keep all user-owned data scoped to session: orders, addresses, cart, profile, coupon; clear/invalidate when principal changes.

## Choosing providers

| Requirement | Recommended primitive |
|---|---|
| Stateless dependency injection: API client / repository | `Provider<T>` |
| Read-only fetch with parameters | `FutureProvider.family` or generated family |
| Synchronous editable application state | `NotifierProvider<Notifier, State>` |
| Stateful async workflows or remote-backed state | `AsyncNotifierProvider<AsyncNotifier, State>` |
| Stream subscription | `StreamProvider` or `StreamNotifierProvider` for edits |

Avoid creating new `StateProvider`, `StateNotifierProvider`, or `ChangeNotifierProvider` as first choice in Riverpod 3; legacy providers are available under `legacy.dart` for compatibility, not recommended for new architecture.

## Strict implementation rules

1. Add a single `ProviderScope` at bootstrap, **outside the existing `GetMaterialApp`** while the migration is incomplete; do not replace routes/theme/translations at the same time.
2. Use `ref.watch` in `build` to react, `ref.read` in user event handlers, and `ref.listen`/`listenManual` for side effects when necessary; do not navigate or show dialogs inside provider `build`.
3. Use immutable state; avoid mutable `List`/`Map` in place, `Rx`, global state singletons, or `BuildContext` inside repositories.
4. Represent remote loading/error/data with `AsyncValue`; distinguish network error, 401, 409, 422, 429, timeout and order-indeterminate outcomes.
5. Use `ref.mounted` after `await` in provider operations where lifecycle may end; cancel network/debounce/streams using `ref.onDispose` and Dio `CancelToken` where appropriate.
6. Riverpod 3 has automatic retry for provider initialization failures: **never put non-idempotent purchase/payment submission in an auto-retried provider `build`**. Order creation is an explicit guarded user action with a persisted/reused idempotency key.
7. Scope feature state properly. For per-screen fetches use auto disposal; for session-wide state use explicit lifecycle/invalidation. Do not use `keepAlive` everywhere.
8. Provide loading, empty, error, refresh and stale-response defenses. Use `family` for product IDs and pagination keys; validate filters and prevent outdated search responses from overwriting new results.
9. Limit rebuilds with focused `Consumer`/`select` where valuable; do not use whole-page rebuilds by default.
10. Every new provider must have focused unit tests, override-based tests with fake repositories and at least one widget test for critical states.
11. Do not log tokens, credentials, payment receipts, addresses or personal information.
12. No use of experimental offline persistence/mutations for checkout or session unless explicitly approved and tested.

## Acceptance gate for any feature

- State ownership and dependencies documented, and a single source of truth established.
- `flutter analyze` and relevant tests pass; existing regression suite remains green.
- Loading, error, cancellation, logout isolation, and request race cases tested.
- Test against **Remote** repositories for critical flows; Mock tests do not prove backend connectivity.
- Do not remove existing GetX implementation without the separate migration skill's deletion gate.

## References

- https://riverpod.dev/docs/introduction/getting_started
- https://riverpod.dev/docs/concepts2/providers
- https://riverpod.dev/docs/how_to/testing
- https://riverpod.dev/docs/whats_new
- https://pub.dev/packages/flutter_riverpod/versions
