---
trigger: always_on
description: "Keep GetX for the current release while enforcing state-management-portable domain/data boundaries and safe controller lifecycle."
---
# GetX today; portable business logic tomorrow

## Allowed boundaries
- `presentation/` and app composition/navigation may import `package:get/get.dart` and use `GetxController`, `.obs`, `Obx`, `GetBuilder`, `GetPage`, `Bindings`, `Get.find`.
- `domain/`, `data/`, repositories, shared API clients, DTOs, business rules and reusable calculations must **not** import GetX; do not expose `Rx<T>`, `GetxController`, `Get.find`, `BuildContext`, `Widget`, `GetConnect`, `Response` from GetX, or navigation callbacks in pure repository APIs.
- Inject plain Dart repository **interfaces** into GetX controllers through constructors. Wire implementations in `Bindings` / existing composition root; do not call `Get.find()` deep in business/data logic. Existing violations should be fixed only when touched and safe, not via a mass rewrite.
- A future switch changes the controllers/observable UI bindings/DI and perhaps routing; **do not promise zero-code migration**. Aim to reuse repositories, entities, DTOs, API code, and tests unchanged.
- Prefer leaf widgets accepting immutable values/callbacks over widgets tightly coupled to `Get.find()`; do not rebuild existing stable widgets solely for architectural purity.

## Correct GetX usage
- `Obx` requires an observable **read inside its builder**; choose it for reactive state. `GetBuilder` updates on explicit `update()`/`update([id])`, not on plain Rx mutation. Avoid redundant `Obx` + `update()` for the same value.
- For Rx lists use reactive collection operations (`assignAll`, `add`, etc.). For nested mutable model changes prefer replacing an immutable item/value; `refresh()` is a targeted fallback, not a blanket fix.
- Prefer feature `Bindings` with `Get.lazyPut` for route-owned controllers. Distinguish `Get.put` (eager) and `Get.lazyPut(fenix: true)` (recreates an instance, **not state**). Do not enable `permanent: true`, use global `Get.put`, or change `SmartManagement` without documented lifetime requirement.
- `onInit` is for setup; `onReady` for work requiring the first frame; `onClose` releases **owned** Workers, subscriptions, timers, request cancellation, focus nodes and text controllers. Account for in-flight futures and stale responses after a controller is closed or a newer request supersedes an older one.
- Keep cross-feature state ownership explicit. Auth session and shared cart state must have defined owners and invalidation rules. Do not orchestrate multi-feature business flows by reaching into other controllers.

## Simplicity constraint
- Do not add a universal `BaseController`, `IStateManager`, factory of state providers, or mandatory UseCase for every tiny action. A small app flow should remain small.
- Keep installed package versions and the project's proven conventions. Consult the version-specific docs for non-obvious lifecycle behavior.
