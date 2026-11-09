---
name: getx-to-riverpod-module-migration
description: Safely migrate the Rwnaqk Flutter modular e-commerce app from GetX to Riverpod 3 one module at a time, starting with a read-only core audit and shared dependency stabilization. Keep GetX until every migrated module passes gates; delete only verified unused legacy files, preserve Laravel contracts and production stability.
---

# Rwnaqk GetX → Riverpod — Incremental, Core-First Migration

## Non-negotiable goal

Move the app to modern feature-first Riverpod 3 without breaking a production-like checkout and authentication stack. **Do not remove the `get` dependency initially.** Do not mass-rewrite controllers, bindings, navigation, translations or rename all `lib/modules` in one operation. One module, one ownership cutover, one test gate, one reviewed cleanup at a time.

Before working, read:
- `references/core-first-audit.md`
- `references/migration-execution.md`
- `references/deletion-and-gates.md`
- the other skill `riverpod3-flutter-state/SKILL.md` when available.

## Phase 0: read-only baseline and inventory — no edits

1. Inspect `flutter --version`, `dart --version`, `pubspec.yaml`, lockfile, tests, current git status/branch, route and bindings graph.
2. Inspect core: `bindings/initial_binding.dart`, `network/api_client.dart`, both potential `api_endpoints.dart`, `services/auth`, `services/geo`, `middleware/auth_middleware.dart`, app startup, `theme`, `translations`, `widgets`, `data` and each module's `Get.find/put/lazyPut`, Rx, Obx, GetxService, GetConnect, GetMaterialApp and navigation.
3. Identify ownership and **all** module consumers of each global dependency: session, token storage, Dio client, addresses, cart, orders, env, navigation, theme and translations.
4. Identify old/new duplicate code and definite core P0 bugs (token exposure, circular DI, duplicate singletons, session leakage, 401 handling, wrong endpoint mapping, unresolved disposal), with file+line evidence. Do not speculate.
5. Produce `docs/migration/core-audit.md`, `dependency-graph.md`, `module-migration-order.md`, `baseline-tests.md`, and `migration-ledger.md`. Present proposed changes; **stop before editing** unless the task explicitly authorizes implementation.

## Phase 1: stabilize and bridge shared core

- Fix proven core correctness/security bugs first, **without changing state framework**, and retest.
- Add `flutter_riverpod` compatible with local Dart SDK. Register one root `ProviderScope(child: existing GetMaterialApp(...))` while keeping GetX initial bindings/routes working.
- Extract/confirm pure domain interfaces; expose one canonical API client, token store and repositories. Avoid two instances of session state or network interceptors.
- Design a *temporary, explicit compatibility bridge* for necessary GetX consumers. Prefer one direction of data flow and an owned adapter, never bidirectional state mirroring without tested reconciliation.
- Do not use GetX in Riverpod domain/data layers. Any transitional `Get.find` adapter must be quarantined under `core/legacy_bridge/`, documented and removed with the last consumer.
- Keep GetX routing, translations, theme and auth middleware working. Route migration is a **separate** future gate; state migration alone does not justify switching to go_router.
- Scope auth/session providers and invalidate stale session-scoped provider caches on logout/switch. Clear *local* cart/addresses/orders without deleting remote orders/addresses.

## Phase 2: pilot and module-by-module cutover

1. Select a small, low-risk pilot (e.g., support static view or onboarding) after core stabilization. If it has no meaningful state, choose catalog read-only listing as a meaningful pilot instead. Do not start with checkout/payment.
2. For each selected module: inventory legacy files and consumers; map GetX controller state/events/dependencies -> provider/notifier; write new providers + UI adapters; keep old implementation available but **only one writes state at runtime**.
3. Switch module routing/binding for that module only; preserve visual design, validation, request/response contracts, loading/error/empty flows and RTL.
4. Run feature tests plus full regression and real API integration where relevant. Record before/after behavior and screenshots if UI changed.
5. Only after gate PASS, remove **dead, zero-reference** controller/binding/legacy UI code in that module in a separate cleanup commit. Never remove a shared core service still used elsewhere.
6. Update ledger, dependency graph and next eligible module; stop after one module unless user explicitly requested multiple modules and each gate passed.

## Suggested dependency-aware order (adjust after real graph)

`Core audit/fixes` → `ProviderScope/shared DI bridge` → `pilot` → `auth/session` → `geo` → `catalog` → `search` → `wishlist` → `customer/addresses` → `cart` → `checkout` → `orders` → `home` → `support/onboarding` → `app-wide navigation/theme/i18n GetX removal`.

Order can change. **Checkout/orders are last among transactional modules**, because they depend on session, variants, addresses, cart and quote. Cross-module writers must migrate together or stay on a single bridge owner. Do not create duplicate cart or auth states.

## Phase 3: global cleanup

After **all** feature and core consumers are migrated: grep across `lib`, `test`, `integration_test`, assets/config for GetX imports, `.obs`, `Obx`, `Get.*`, `GetxController`, bindings, middleware and use of `GetMaterialApp`. Only when counts are zero or explicitly resolved and routes/deep links/theme/translations pass their own test gates, remove `get` from pubspec. Delete legacy folder(s) using a reviewed file-by-file ledger, not `Remove-Item -Recurse` on live modules.

## Safety and testing gates

- Do not alter Laravel API behavior, login payloads, token storage or order idempotency except when a verified bug requires approval.
- For every module: `flutter analyze`, `flutter test`, relevant integration tests, real API tests on Staging if commerce/auth, app navigation tests, and `git diff --check` must pass.
- Preserve `Fake*Repository` test implementations; they are part of testing strategy, not obsolete GetX files.
- Preserve transaction correctness: no double submit, same idempotency key on retry, no cart clear on timeout, prices server-authoritative.
- A migration is **not complete** if production routes still instantiate old controllers or if old files are merely left unused without documented reason.
- Roll back feature cutover, not the entire app, on failure. Report executed vs skipped tests precisely.

## Output required every run

State: (a) exact module, (b) baseline, (c) changed/added/deleted files, (d) tests commands/results, (e) remaining GetX references in scope, (f) migration gate PASS/FAIL, (g) known risks, (h) next module. No unsupported claims of 100% production readiness.
