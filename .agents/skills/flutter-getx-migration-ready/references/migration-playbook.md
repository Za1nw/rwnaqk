# Future migration to Riverpod / BLoC (not a default action)

## Do not migrate under a one-to-two-week launch deadline

Migrate only on explicit request, or after demonstrable maintenance problems and agreed risk. First isolate Laravel/Dio, business rules and repository contracts; these changes can be done **while GetX stays**. A native leaf widget that receives values/callbacks survives migration; `Obx` views do not magically survive.

## Migration map

| GetX now | Riverpod later | BLoC later | What must change? |
|---|---|---|---|
| `GetxController` | `Notifier` / `AsyncNotifier` | `Cubit` / `Bloc` | UI adapter and associated tests |
| `Rx` / `.obs` | provider state | emitted states | State representation, subscribers |
| `Obx` / `GetBuilder` | `Consumer` / `ref.watch` | `BlocBuilder` / `BlocSelector` | Rx-bound widgets |
| `Bindings` / `Get.find` | provider overrides / graph | explicit constructors / DI | Composition root |
| `Get.to` / GetPage | Can **retain** initially, later `go_router` | Can **retain** initially | Separate routing project |
| Domain models / repo contracts | Reuse | Reuse | None if truly pure Dart |
| Laravel/Dio implementations | Reuse | Reuse | None if not coupled to GetX |

## Low-risk sequence

1. Baseline branch + actual tests for catalog/cart/auth/checkout; document current route and state ownership.
2. Eliminate GetX imports from **touched** domain/data classes, not from all widgets at once. Constructor-inject pure repository contracts.
3. Confirm there is one owner of session/cart and clear cache-logout invalidation rules. Do **not** create two simultaneously writable cart authorities.
4. Choose a safe pilot feature (catalog search/filters), not authentication or checkout.
5. Wire the same repository into a Riverpod/BLoC presentation adapter; update only the pilot view + DI registrations.
6. Keep GetX routing until the state pilot is independently tested; avoid mixing route and state migrations in the same pull request.
7. Regression-test navigation, retries, disposal, persisted cart and auth. Measure actual effort and decide whether migration benefits justify the work.
8. Remove GetX only after all pages, bindings, app services, and routes no longer depend on it.

## Required report for migration proposals

- GetX-specific files that must change.
- Framework-neutral files to reuse unchanged.
- Estimated risks (cart, auth, checkout, release), with evidence not generic claims.
- Pilot scope, tests, rollback plan, dependency changes and deployment impacts.
- Explicit statement that migration will require UI/state/DI changes, not just replacing an import.
