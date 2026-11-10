# Riverpod 3.5 provider testing, lifecycle, and commerce security

## Provider unit tests: isolated containers

```dart
final container = ProviderContainer.test(overrides: [
  productsRepositoryProvider.overrideWith((ref) => fakeRepository),
]);
final subscription = container.listen(productsProvider, (_, _) {});
final products = await container.read(productsProvider.future);
expect(products, isNotEmpty);
subscription.close();
```

This example depends on a `FutureProvider` or `AsyncNotifierProvider` named productsProvider and actual project repository types. Tests must not share containers or mutate global providers.

## Widget tests

```dart
await tester.pumpWidget(ProviderScope(
  overrides: [productsRepositoryProvider.overrideWith((ref) => fakeRepository)],
  child: const MaterialApp(home: CatalogView()),
));
```

`ProviderScope` stays as the root DI boundary. Keep `GetMaterialApp` underneath temporarily in the real app. `ProviderContainer.test()` is supported by Riverpod 3 and handles disposal in tests.

## Lifecycle

- Async code: `if (!ref.mounted) return;` before using notifier `state`/`ref` after `await`.
- Cancel Dio requests/listeners using `ref.onDispose` where ownership permits.
- `AsyncError` from server != `ProviderDisposedException` from cancellation. Avoid exposing disposal exceptions as business failures.
- Always guard stale search/catalog responses and session changes.

## Automatic retry distinction

- Provider computation failure is retried automatically in Riverpod 3 unless configured.
- Mutation/action callbacks must be explicit: never trigger order creation in provider build; retain the same idempotency key on retry.
- Loading/error states via AsyncValue; do not conflate `409` price drift with generic connectivity.

## Commerce & privacy gates

- Auth: token via SecureAuthTokenStorage, no raw token exposure in widgets; preserve 2FA, email verification, and 401 behaviors.
- Catalog: filter/debounce/variant ID stable; avoid stale result overwrites.
- Cart: separate lines by real product variation; quantity and quote server-authoritative.
- Checkout: `X-Idempotency-Key` stable for one attempt; no double POST; preserve cart when unknown outcome.
- Logout: invalidate user-scoped providers, clear local caches and credentials, do not delete server orders.
- Wallet: proof upload stays unpaid pending verification; avoid insecure link access.

## Deletion gate

Before removing GetX files: run a full project symbol/import/route/binding search, then pass `flutter analyze`, `flutter test`, and relevant real Staging E2E; retest after deletion.

Reference: https://riverpod.dev/docs/how_to/testing and https://riverpod.dev/docs/concepts2/overrides
