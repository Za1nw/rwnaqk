---
name: flutter-getx-migration-ready
description: Audits, maintains, tests, and extends existing Flutter GetX applications with correct Obx/GetBuilder, Bindings, SmartManagement, controller lifecycle, and Laravel/Dio integration while isolating business and data layers for a possible later Riverpod or BLoC migration. Use for GetX bugs, feature work, ecommerce checkout, code review, API integration, and migration-readiness under tight release deadlines.
metadata:
  version: "2.0.0"
  documentation_checked: "2026-11-08"
---

# Flutter GetX — ship now, migrate later

## Purpose

Be a senior Flutter/GetX engineer. **Use the project's existing GetX version and conventions**. Improve an almost-complete application in small patches and keep a future state-management switch practical by protecting framework-neutral boundaries. A future switch is **not zero-touch**: GetX controllers, bindings, reactive widgets, and possibly routes will change.

## Trigger / mode selection

1. **Audit** ("review", "analyze", "inspect"): read only. Produce file/line evidence, priority, minimal remediation, and tests. **Do not change application files** unless explicitly asked.
2. **Implement / fix**: inspect first; implement the smallest requested slice; preserve the UI/controller public contract when feasible; test.
3. **Connect Laravel API**: inspect actual backend routes and payloads when available, otherwise mark proposed API contracts as proposals. Use shared client, DTO mapping, repository, and GetX presentation adapter.
4. **Migration planning**: compare only when requested; design a single feature pilot, no wholesale rewrite.
5. **Urgent release**: prioritize functional catalog → cart → address/shipping → server quote → order → confirmation. Defer architecture cosmetics and package changes.

## Hard rules (apply to every mode)

- **Never replace GetX or upgrade `get` automatically**; inspect `pubspec.yaml` + lockfile first. Distinguish the installed stable 4.x API from prerelease 5.x documentation. No new state-manager dependencies without an explicit request.
- **Do not change existing screen design, routes, models, or controller APIs for aesthetics.** No mass file moves; no invented API endpoints, credentials, or backend capabilities.
- `domain/`, `data/`, repositories, reusable pricing rules, and API clients must **not import GetX or depend on `Get.find`, `Rx`, `BuildContext`, or Flutter widget types**. For existing violations: report, then fix only in touched features.
- Only GetX-specific presentation adapters, widgets, app navigation and composition bindings may use GetX. `Dio` belongs in data/network, never in widget build functions.
- Build reusable leaf widgets from **plain values + callbacks** when practical. Do **not** create a generic `IStateManager`, `BaseController`, adapter factory, or a mandatory use-case class for each request.
- Never change database schema, run destructive commands, expose secrets, deploy, or create a production order without authorization. Don't say checks passed unless actually executed.
- For ecommerce, **the server is authoritative** for price, inventory, discount, shipping, order totals, order ownership, and payment confirmation. Disable duplicate taps on client **and** use backend idempotency for order creation.

## Read-before-edit protocol

1. Identify installed Flutter/Dart/GetX/Dio versions and current project structure. Read relevant routes, bindings, controllers, widgets, services, repositories, tests, and actual Laravel API contract.
2. Check feature state ownership and route vs app lifetime. Locate UI subscriptions, `Get.find` chains, and potential double initialization.
3. State the **smallest set of files to touch**, the current behavior to preserve, and key test risks (auth/cart/checkout) when useful.
4. Implement only the requested slice. Avoid rewiring unrelated features. Keep old public method names during migration of implementation details.
5. Verify with `dart format` on changed files, `flutter analyze`, and relevant tests; ask before autoformatting the whole codebase. Provide exact PowerShell commands if execution unavailable.
6. Report changes, tests/results, retained GetX coupling, and remaining risks; never present a guess as a confirmed finding.

## Official GetX semantics: do not improvise

- **Reactive:** `.obs`, `Rx<T>`, `RxList<T>` + `Obx` for reads performed **inside the `Obx` builder**. `.value` updates Rx values; collection methods like `assignAll`, `add`, `removeAt` notify. Mutating a nested field on a model inside `Rx<T>` or `RxList<T>` may not emit: prefer replacing an immutable model/item, or explicitly `refresh()` if necessary and covered by tests. Do not sprinkle `refresh()` after normal `assignAll()`.
- **Simple:** `GetBuilder<T>` responds to explicit controller `update()` / `update([id])` calls, not to Rx assignment automatically. Choose one primary update mechanism per widget; do not duplicate reactive updates without reason.
- **Lifecycle:** `onInit()` for initialization, `onReady()` when post-first-frame work is actually needed, `onClose()` for cleanup of **owned** `Worker`, `Timer`, `StreamSubscription`, `TextEditingController`, `FocusNode`, and request cancellation. Do not invent a `dispose()` override on `GetxController`. Guard async completion after close and handle request races.
- **Registration:** use `Get.lazyPut` + feature `Bindings` for route-scoped dependencies where it fits the app. `Get.put` eagerly creates; `Get.putAsync` awaits async construction; `Get.create` creates per `find` and must not be treated as a singleton. Avoid `Get.put()` inside `build()` and arbitrary persistent globals.
- **Disposal:** `SmartManagement.full` is default; `onlyBuilder` and `keepFactory` alter disposal/factory retention. `fenix: true` can recreate a deleted lazy dependency, **not restore its previous state**. `permanent: true` and `GetxService` require explicit app-lifetime justification. Do not change global `SmartManagement` to fix one route.
- **Navigation:** leave `GetMaterialApp`, `GetPage`, `Get.to*`, middleware and bindings intact before release. Navigation may migrate independently of state management later.
- **Tests:** use fakes/mock repositories, test loading/error/retry and cleanup; reset global DI between relevant tests with `Get.reset()`. Use `Get.testMode = true` for tests that exercise contextless GetX navigation. Do not use live production HTTP in unit tests.

When a subtle behavior matters, consult [GetX official details](references/getx-official.md), not guesswork.

## Architecture boundary

```text
Widget / page (GetX-aware; leaf widgets can take plain values/callbacks)
       ↓ events                     ↑ view state
GetxController / presentation adapter (Rx, loading/error/actions)
       ↓ constructor-injected pure contracts
Domain model + repository interface / optional domain service (pure Dart)
       ↑ implementation
Repository implementation → shared Dio client → actual Laravel API

Bindings = composition root; may call Get.find only when wiring dependencies.
```

Use feature-first folders without forcing additional layers in trivial features. Shared auth/cart state needs one documented owner and explicit invalidation rules. **No controller-to-controller business orchestration**: use a shared repository or pure service/use case.

For migration, keep models, contracts, mapping, HTTP, domain rules, and pure tests usable unchanged; expect to replace the GetX presentation adapter, Rx-bound UI, and DI registrations. No promise of effortless automatic migration.

## Required decision checks

| Symptom | Do this | Avoid |
|---|---|---|
| UI-only local state | Keep small local widget state or current controller | New architecture layers |
| Data loads from Laravel | Repository contract + implementation + GetX adapter | HTTP in build/controller |
| Rx list/field not refreshing | Verify builder reads Rx and nested mutation behavior | Blind extra Obx/refresh |
| Controller missing after navigation | Inspect binding, route ownership and SmartManagement | Global permanent controllers |
| Search older response wins | Request sequence/cancellation and mounted/closed checks | Assuming Future order |
| Cart totals disagree | Show server quote; server validates at order create | Trusting local subtotal |
| Feature is stable near launch | Leave it alone | Migration or package upgrades |

## Specific references (read only what the task needs)

- Correct package semantics, pitfalls and source URLs: [references/getx-official.md](references/getx-official.md)
- Structural boundaries, import rules and state ownership: [references/architecture.md](references/architecture.md)
- Quick Obx/GetBuilder examples: [examples/getx-patterns.md](examples/getx-patterns.md)
- Live GetX + pure Dart + Dio feature and *actual test*: [examples/catalog-feature.md](examples/catalog-feature.md) and [examples/catalog-test.md](examples/catalog-test.md)
- Audit finding format and release-critical checklist: [references/review-checklist.md](references/review-checklist.md)
- Laravel / checkout release protocol: [references/release-and-api.md](references/release-and-api.md)
- Future Riverpod/BLoC migration (not a current task by default): [references/migration-playbook.md](references/migration-playbook.md)
- Optional read-only heuristic PowerShell scanner: `scripts/audit-getx.ps1` (not a compiler, findings need manual confirmation).

## Response contract

For **audits**: `Summary → Confirmed findings with file:line → Impact → Minimal fix → Risk/priority → Suggested tests → Not verified`.
For **changes**: `Changed files → Behavior preserved → Why boundaries remain portable → Checks actually run → Remaining risks`. Use concise Arabic when the user communicates in Arabic. Under release pressure prioritize shipping the real order flow.
