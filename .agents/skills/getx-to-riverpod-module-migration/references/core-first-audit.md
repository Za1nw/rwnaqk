# Read-only core audit — Rwnaqk current tree

User-shared tree highlights:

```text
lib/
  core/
    bindings/initial_binding.dart
    constants/api_endpoints.dart
    constants/app_colors.dart
    constants/app_constants.dart
    constants/app_dimensions.dart
    constants/app_env.dart
    constants/local_storage_keys.dart
    errors/exceptions.dart
    errors/failures.dart
    middleware/auth_middleware.dart
    network/api_client.dart
    network/api_endpoints.dart
    network/api_exceptions.dart
    services/auth/
    services/geo/
    theme/
    translations/
    utils/
    widgets/
  data/
  modules/
    auth/ cart/ catalog/ checkout/ customer/ home/
    onboarding/ orders/ search/ support/ wishlist/
```

**Do not infer any file is redundant solely from its filename.** Two `api_endpoints.dart` files are an audit candidate, not automatic deletion. Other folders may contain GetX calls not visible in the screenshot; inspect actual code.

## Deliverable: dependency matrix

| Core component | GetX usage | Consumers | Ownership/source of truth | Migration target | Risk |
|---|---|---|---|---|---|
| InitialBinding | inspect | all screens | DI composition | Provider graph with bridge | high |
| Auth services | inspect | auth/customer/checkout | session & token | pure auth repository + session notifier | P0 |
| ApiClient | inspect | all remote repos | bearer and errors | single Provider<ApiClient> | P0 |
| Auth middleware | inspect | protected routes | route guards | unchanged until route gate | high |
| Geo services | inspect | address & checkout | Laravel geo is authoritative | repository Provider | high |
| Theme/translations | inspect | app-wide | visual/localization config | separate later migration | medium |
| Widgets | inspect | all modules | UI | small consumer adapters | medium |

## Audit exact usages

From Windows PowerShell in Flutter project root (`rg` if ripgrep is installed):

```powershell
rg -n 'package:get/get.dart|GetxController|GetxService|GetConnect|GetMaterialApp|Get\.find|Get\.put|Get\.lazyPut|\.obs\b|\bObx\b|\bGetBuilder\b|\bGetMiddleware\b' lib test integration_test
rg -n 'api_endpoints|InitialBinding|AuthSession|IAuthTokenStorage|IAuthRepository|CartController|PaymentController' lib
flutter --version
flutter analyze
flutter test
```

If `integration_test` does not exist, omit it rather than treating rg's missing directory as a migration failure. If `rg` is unavailable use PowerShell `Get-ChildItem -Recurse -Filter *.dart ... | Select-String ...`.

Potentially critical issues to check, not assume: register/login/logout handling of 401; token stored twice; global GetX instances surviving logout; circular dependencies; geo coverage state from fake vs remote; price quote stale on address change; `Get.find` in repository implementations; duplicate API endpoint definitions and conflicting values; stale async callbacks; routes that instantiate controllers despite migration; lifecycle of `Worker`/ScrollController.

## Core repair gate

For each verified P0 bug: cite file and lines, prove reproduction with test, fix minimally, rerun baseline suite, preserve contracts, commit. Only then add Riverpod bootstrap and pilot feature.
