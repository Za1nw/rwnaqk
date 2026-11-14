# Phase 09 — Dependency Injection Migration Architecture

## 1. Executive Summary

This document specifies the migration of Dependency Injection (DI) from GetX's runtime service locator (`Get.find`, `Get.put`, `Get.lazyPut`, `Bindings`) to **compile-time verified, pure Riverpod 3.5.0 declarative providers**.

---

## 2. Legacy DI Vulnerabilities & Anti-Patterns Eliminated

| Legacy Pattern (GetX) | Inherent Risk / Defect | Riverpod 3 Replacement |
| :--- | :--- | :--- |
| `Get.find<T>()` inside widgets | Runtime `NotMounted` / `NotFoundException` crashes if route binding failed. | `ref.watch(provider)` guaranteed safe at compile-time. |
| `Get.lazyPut(fenix: true)` | Recreated new instances without clearing stale state, causing cross-account memory leakage. | Explicit `sessionGeneration` lifecycle and auto-disposable providers. |
| Global mutable service locator | Hidden dependencies, tightly coupled code, impossible to mock in isolation. | Explicit constructor injection with pure Dart interfaces. |
| `InitialBinding` & 13 feature bindings | Monolithic imperative setup in `main.dart` with race conditions during app initialization. | Declarative `core_providers.dart` graph evaluated on-demand. |

---

## 3. Canonical Provider Hierarchy (`core_providers.dart`)

All dependencies are wired in a unidirectional dependency DAG:

```
[Level 0: Platform & Storage Primitives]
  - sharedPreferencesInstanceProvider
  - flutterSecureStorageProvider
  - authTokenStorageProvider (SecureAuthTokenStorage with SharedPreferences fallback migration)
       |
       v
[Level 1: Network & Serialization Engine]
  - dioClientProvider (Configured timeouts, headers, tenant keys)
  - apiClientProvider (ApiClient with error mapping and Bearer interceptors)
       |
       v
[Level 2: Pure Domain Repositories (Interfaces)]
  - authRepositoryProvider (IAuthRepository -> AuthRepositoryImpl)
  - productsRepositoryProvider (IProductsRepository -> ProductsRepositoryImpl)
  - cartRepositoryProvider (ICartRepository -> CartRepositoryImpl)
  - ordersRepositoryProvider (IOrdersRepository -> OrdersRepositoryImpl)
  - addressesRepositoryProvider (IAddressesRepository -> AddressesRepositoryImpl)
       |
       v
[Level 3: Application & Session State Notifiers]
  - authSessionProvider (AuthSessionNotifier)
  - cartProvider (CartNotifier)
  - cartQuoteProvider (CartQuoteNotifier)
  - checkoutProvider (CheckoutNotifier)
  - ordersProvider (OrdersNotifier)
  - addressesProvider (AddressesNotifier)
  - wishlistProvider (WishlistNotifier)
  - appLocaleProvider / appThemeModeProvider
```

---

## 4. Test Isolation & Provider Overrides

With Riverpod 3, testing does not require resetting global state or manipulating static registries:

```dart
// Isolated Unit / Integration Test Container
final container = ProviderContainer(
  overrides: [
    authTokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
    sharedPreferencesInstanceProvider.overrideWithValue(mockPrefs),
    apiClientProvider.overrideWithValue(mockApiClient),
  ],
);
```

Every test runs in total isolation with zero cross-test interference or leak risk.

