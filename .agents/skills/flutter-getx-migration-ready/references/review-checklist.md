# Read-only audit checklist — verify each finding

For every issue report: **severity, file:line, observed code, reproduction/failure case, smallest fix, test, release-blocking?** A regex match is NOT evidence of a runtime bug by itself. Read surrounding code before classifying severity.

## GetX-specific

- `Obx` accesses Rx inside its builder; suspicious nested mutable model fields and needless `refresh()`.
- `GetBuilder` calls `update()`/`update([id])`; mixed Obx/GetBuilder not duplicating work.
- Route `Bindings` register required dependencies before `Get.find`; avoid `Get.put` in widgets' `build`.
- Do not assume `fenix` preserves state, or that `permanent` is required for route-scoped controllers.
- Inspect `SmartManagement.full` (default), `onlyBuilder`, `keepFactory` and version-specific disposal behavior before recommending changes. Official docs caution about keepFactory with multiple bindings.
- Ensure owned `Worker`, timers, subscriptions, form controllers and focus nodes closed/cancelled in `onClose`; avoid disposing someone else's resource.
- Async completion after closure, stale search results, pagination and multiple concurrent requests.
- `Get.find<OtherController>()` chains used for business logic; pure repository ownership is preferable.
- `GetxService` / global auth/cart lifecycle explicitly documented.

## Data and Laravel API

- Actual Laravel routes/JSON/pagination/HTTP status codes verified, not guessed.
- DTO mapping protects nullable types, IDs, images/currency and unexpected error payloads.
- Shared Dio client, per-environment URL/timeouts, HTTPS, secure token storage; no secret logs.
- 401/403/422/429/5xx/offline/timeout handling; token refresh cannot loop infinitely.
- Retries for non-idempotent POST orders are forbidden without server-supported idempotency.
- Repository returns pure models/results, no GetX `Rx`, snackbar, navigation or `BuildContext`.

## Ecommerce release gates

- Catalog, cart, address/shipping, server quote, create order, confirmed order detail.
- Quantity, stock, price, discounts, shipping cost and totals recalculated on server.
- Repeat taps, retry after timeout, and network reconnection do not double-charge/order.
- Payment confirmation is server-verified; order access is authorized server-side.
- Guest/user carts and logout/account-switch cache invalidation are tested.
- Loading/empty/error/slow connections handled; accessibility and layout survive small screens.
- Tests and a real staging order work before store submission. No UI polish/refactor at expense of critical order flow.

## Verification and evidence

- `dart format` on changed code only; `flutter analyze`; feature unit/widget tests; release build and real-device QA when possible.
- Use source version from `pubspec.yaml` + lockfile; no automatic `get` prerelease upgrade.
- Distinguish **confirmed defect** from **possible risk**, and **tests executed** from **tests recommended**.

## Optional static scan (read only)

```powershell
& "$HOME\.gemini\config\skills\flutter-getx-migration-ready\scripts\audit-getx.ps1" -ProjectPath .
```

JSON output for scripts: `-Format Json`. Findings are heuristic and may include false positives, e.g. code in comments, strings, or deliberately legacy files.
