# Riverpod testing and commerce safety

## Provider test pattern (Riverpod 3)

```dart
final container = ProviderContainer.test(
  overrides: [
    productsRepositoryProvider.overrideWithValue(fakeRepository),
  ],
);
final sub = container.listen(featuredProductsProvider, (_, _) {});
final products = await container.read(featuredProductsProvider.future);
expect(products, isNotEmpty);
sub.close();
```

Create a **new container per test**, avoid shared global provider state. For widget tests use `ProviderScope(overrides: [...], child: MaterialApp(home: ...))`. Use `tester.container()` when needed. Verify overrides match actual project types.

## Mandatory regression scenarios

- App launch, routing, login, registration, email verification required, errors 401/422, logout/user switch.
- Catalog loads, empty, search debounce, cancellation, pagination, variant IDs and images.
- Cart line identity per `product_variation_id`, quantity changes, coupon, address-dependent quote.
- Orders: 409 price drift, idempotency key reuse after timeout, **no automatic duplicated POST**, cart retained until confirmed order, app restart/resume.
- Wallet proof privacy, never mark manual payment paid on upload.
- Provider disposed during request; late response doesn't update another user/session.
- Real API E2E, not Fake alone. Keep existing Laravel contract and tests unchanged unless approved.

## Deletion gate

Before removing any GetX file after migration: all imports/references to that file and GetX routes/bindings are gone or consciously retained; unit/widget/E2E tests green; API and state behavior parity shown; Git commit/rollback point exists. Never remove GetX from `pubspec.yaml` while **any** GetX references remain anywhere in application or tests. Never delete whole modules/folders as a cleanup shortcut.
