# Architecture boundaries: GetX today, portable data tomorrow

Prefer the existing project's folders. **No app-wide architecture redesign before the launch.** A minimal feature can use `page + controller + repository`, with domain interface only when it creates a real seam. Optional domain use-case for complex reused rules.

```text
lib/
  app/
    routes/                 # GetPage / navigation
    bindings/               # GetX composition root, app-wide registrations
  core/
    network/                # shared configured Dio, errors, auth
    storage/                # secure token / local prefs
  features/
    catalog/
      domain/product.dart
      domain/product_repository.dart
      data/laravel_product_repository.dart
      presentation/controllers/products_controller.dart
      presentation/pages/products_page.dart
      bindings/catalog_binding.dart
    cart/
    checkout/
    auth/
  main.dart
```

## Dependency rule

- `domain/`: plain Dart entity, repository interfaces, pure business rules. No GetX, Flutter, Dio, BuildContext, HTTP response DTOs or global service locators.
- `data/`: concrete Dio/API client, DTO/JSON mapping, persistence implementations; may depend on domain but **not GetX**.
- `presentation/`: Flutter, GetX, screen state, UI actions, loading/errors. Controllers receive domain contracts through constructors; they must not use Dio directly in new code.
- `bindings/`: concrete wiring; `Get.find` is acceptable **at composition**, and nowhere in domain/data.
- Navigation, dialog and snackbar are presentation/application concerns. If domain needs to signal an action, return data/errors; the adapter decides what to display.

A small domain model may be a single plain Dart class. An abstract repository isn't mandatory for *every* widget; create it for backend-facing features, reusable data sources, or where tests benefit from fakes. Do not add `BaseController`, a homegrown `IStateManager`, or boilerplate interfaces at every layer.

## Portable state boundaries

**Level A (required now):** models, repository contracts, DTO mapping, API, business rules independent of GetX. GetX stays in controller, bindings and Rx UI.

**Level B (selective):** reusable leaf widgets get `Product product`, `bool loading`, `VoidCallback onTap` etc. rather than `Rx` or `Get.find`. No extra abstraction for one-off pages.

**Level C (later, only if requested):** replace one presentation adapter with Riverpod `AsyncNotifier` / `Notifier`, or BLoC `Cubit`/`Bloc`; rewire state subscriptions and DI, retain repo implementation. Routing may remain GetX in phase one.

## Data ownership and ecommerce boundaries

- **Catalog**: repository owns fetching/cache/invalidation; controller handles filter/selection and view status.
- **Auth**: one account/session owner; keep token refresh, logout, and 401 behavior explicit; never stash tokens in feature controllers or logs.
- **Cart**: document guest/user persistence and merge, account change invalidation, quantity conflicts and stock handling. Cross-feature UI may observe shared data through a repository or central app service; avoid `Get.find<CartController>()` in product domain logic.
- **Checkout**: client may show an estimate, but only the Laravel quote determines payable totals. Order POST requires idempotency, and response must be verified against stored order. Payment verified by backend.
- **Network**: use a shared Dio instance with base URL, timeouts, authentication and predictable mapping. On 401/422/429/5xx distinguish scenarios; avoid infinite token refresh retries and duplicate POST retries.
- **Async**: protect against stale search/page responses and updates after disposal; prefer cancellation and request generations for last-write-wins features.

## Test strategy

1. Pure Dart unit tests for domain decisions/DTO mapping.
2. Repository tests with fake HTTP adapter (not live production API).
3. GetX controller tests with a fake repository, including loading/data/error, overlapping requests, after-close safety.
4. Widget tests for `Obx` and `GetBuilder` flows.
5. Real end-to-end staging order test (auth → cart → quote → order → confirmation), plus backend idempotency and authorization tests.

## Migration acceptance

No loss of persisted cart/session; API contracts untouched unless explicitly requested; UI state/commands preserved; branch-by-branch rollback; tests before removing GetX; don't combine with route migration or upgrade of unrelated packages.
