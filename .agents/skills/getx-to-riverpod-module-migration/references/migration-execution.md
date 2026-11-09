# One-module migration playbook

## Pass A: read-only feature map

Record: module name/path; `Controller`/`Binding`/`GetxService`/`Obx` ownership; providers/repositories/models; routes/Deep Links; consumers outside the module; pre-existing behavior tests and UI screenshot/UX baseline.

## Pass B: state conversion

| Current GetX concern | New owner |
|---|---|
| `GetxController` mutable `Rx` fields | immutable `FeatureState` + `Notifier` / `AsyncNotifier` |
| `ever/once/debounce` | appropriate listener with cancel/dispose, domain debounce |
| `Get.find<IRepo>()` | `ref.watch(repoProvider)` for dependencies |
| `Get.put/lazyPut` | providers/overrides; original legacy still registered until unused |
| `GetxService` state | pure shared service plus a session- or app-scope provider |
| `Obx` views | `ConsumerWidget` or scoped `Consumer` |
| Routes, middleware | unchanged GetX navigation until a later global route gate |

No dual write. If old screens still depend on GetX, keep a temporary bridge to **a single canonical state owner**. Do not sync new Riverpod state into GetX and GetX state back into Riverpod continuously.

## Pass C: module cutover

1. Add tests first (behavior parity and provider state transitions).
2. Introduce Riverpod implementation without deleting old code.
3. Update a single module's screens to consume providers; route remains intact.
4. Verify changed modules work with Fake and Remote repositories.
5. Run whole-app tests and inspect imports/DI graph.
6. Remove old files one at a time **only after zero reference**, then rerun tests and inspect diffs.
7. Record completion and stop for acceptance.

## Required contract invariants for auth

- Payload mapping matches Laravel: `first_name`, `last_name`, `mobile`, `email`, `country`, `governorate`, `password`, `password_confirmation`, `terms_accepted`, `privacy_policy_accepted`, `device_name` (verify actual server requirements).
- On 200/201, response may contain token and/or require email verification/2FA. Do not start a fully authenticated UI session with an empty token or bypass verification.
- Token written only through existing secure storage abstraction, with migration rules preserved.
- 422 field errors are surfaced, and 401 from registration/login is not misinterpreted as an existing-session logout.
- On logout or principal change, invalidate all session-dependent local caches and pending operations; no cross-user data leakage.

## Required contract invariants for checkout/orders

- `CartQuoteEngineService` is server-authoritative, `409` refresh/confirmation flow remains intact.
- Idempotency UUID retained across network timeouts and app restart for one logical order.
- Do not clear cart until confirmed server order. No new background retry of POST /orders.
- Receipt upload must respect backend-approved paths; still unpaid until verified.
- Ensure an order group is never created twice via alternate state managers.

## Example cutover note (template)

```text
Module: catalog
Current state owner: ProductsListingController
New owner: productsListingProvider (AsyncNotifier)
Repository: IProductsRepository (unchanged)
Bindings: old binding remains only for other legacy screens
Routes: unchanged
Tests: unit [ ], widget [ ], remote E2E [ ], flutter analyze [ ]
Removal candidates: OLD_CONTROLLER.dart (reference scan pending)
Gate: NOT YET PASSED
```
