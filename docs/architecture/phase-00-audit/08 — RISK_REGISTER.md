# 08 — Architectural & Operational Risk Register

> **Phase**: Phase 00 — Architecture Audit & Migration Readiness  
> **Project**: Rawnaquk E-Commerce Storefront (`rwnaqk_frontend`)  
> **Assessment Scope**: Architectural, Security, Concurrency, Performance, and Regression Risks  

---

## 1. Risk Evaluation Matrix

| Severity \ Probability | High Probability | Medium Probability | Low Probability |
|---|---|---|---|
| **Critical (P0)** | **R-02** (Auto-Retry Double Submit)<br>**R-03** (Cart-Payment Deadlock) | **R-01** (Cross-User Cache Leak)<br>**R-04** (Silent 401 Token Hang) | — |
| **High (P1)** | **R-05** (Dual Network Desync)<br>**R-06** (Wishlist Logout Leak) | **R-07** (Mass Refactor Breakdown)<br>**R-08** (riverpod_lint SDK Conflict) | — |
| **Medium (P2)** | **R-09** (Unbound Route Deep-Link Crash) | **R-10** (Search Race Condition) | — |

---

## 2. Comprehensive Risk Register

### R-01: Cross-User Data Leakage via Stale Session-Scoped Caches
- **Category**: Security & Privacy / Session Scoping
- **Severity**: **Critical (P0)** • **Probability**: Medium
- **Description**: In an e-commerce storefront, if user A logs out and user B logs in on the same device without explicit cache invalidation, user B could view user A's cart items, order history, or saved shipping addresses.
- **Root Cause**: GetX permanent controllers and Riverpod singleton providers persist in memory unless explicitly invalidated upon session teardown.
- **Mitigation Strategy**:
  1. Implement declarative cache invalidation in Riverpod: `ref.invalidate(cartProvider)`, `ref.invalidate(ordersProvider)`, `ref.invalidate(addressesProvider)`, `ref.invalidate(profileProvider)` immediately upon logout.
  2. Invalidate all session-scoped providers whenever `authSessionProvider` transitions to `unauthenticated`.
- **Detection & Verification**: Automated logout isolation test (`phase3_e2e_journey_test.dart:5`) verifying all local stores return to empty state after logout.

---

### R-02: Non-Idempotent Checkout Submission via Riverpod Automatic Provider Retry
- **Category**: Concurrency & Financial Transaction Safety
- **Severity**: **Critical (P0)** • **Probability**: High (if misconfigured)
- **Description**: Riverpod 3 automatically retries provider initialization upon failure when observed by new UI listeners. If order submission or payment verification is placed inside an async provider's `build()` method, a network blip could cause Riverpod to re-execute the purchase, resulting in duplicate order creation or double charging.
- **Root Cause**: Misunderstanding Riverpod 3's reactive lifecycle by placing write mutations inside read-only query builders.
- **Mitigation Strategy**:
  1. **Zero-Mutation Build Rule**: Provider `build()` methods must be strictly read-only (`GET` operations only).
  2. Checkout and order submission must strictly be an **explicit, user-triggered method** on the Notifier (`submitCheckout()`), never triggered reactively in `build()`.
  3. Enforce client-side `X-Idempotency-Key` (UUID v4) on every order submission. On network retry, reuse the exact same key.
- **Detection & Verification**: Code review lint prohibiting `apiClient.post` inside `build()`; automated idempotency test verifying identical key re-use.

---

### R-03: Circular Dependency Deadlock Between Cart, Payment, and Orders
- **Category**: Architecture & Coupling
- **Severity**: **Critical (P0)** • **Probability**: High
- **Description**: `PaymentController` calls `CartController.payNow()`, which calls back into `PaymentController.selectedWalletAccount`, which calls into `OrdersController.repository.submitCheckout()`, which calls into `OrdersController.addOrder()`. In Riverpod, circular provider dependencies throw a circular dependency exception at runtime.
- **Root Cause**: Overlapping responsibilities where checkout orchestration was never given its own independent domain boundary.
- **Mitigation Strategy**:
  1. Create a dedicated `checkoutNotifierProvider` in Phase 08.
  2. `CartNotifier` manages only cart items and quote requests.
  3. `PaymentNotifier` manages only UI payment method selection.
  4. `CheckoutNotifier` reads from both providers as an orchestrator, submits the order via `ordersRepositoryProvider`, and resets cart state on completion.
- **Detection & Verification**: Static dependency analysis ensuring zero circular imports between feature provider files.

---

### R-04: Silent 401 Unauthorized Token Hang
- **Category**: Security & Session Management
- **Severity**: **Critical (P0)** • **Probability**: Medium
- **Description**: When a customer's token expires or is revoked on the Laravel backend, API calls return HTTP 401. Currently, `ApiClient` maps the exception, but because `_onUnauthorized` is unconfigured in `InitialBinding`, the token remains in secure storage and the user remains on the screen indefinitely with broken functionality.
- **Root Cause**: `ApiClient` instantiated in `InitialBinding:58` without passing the `onUnauthorized` callback parameter.
- **Mitigation Strategy**:
  1. In Phase 01, wire `onUnauthorized` in `apiClientProvider` to invoke `ref.read(authSessionProvider.notifier).handleUnauthorized()`.
  2. `handleUnauthorized()` immediately purges secure storage and uses navigation listener to route to `/login`.
- **Detection & Verification**: Automated unit test in `network_and_repositories_test.dart:3` verifying 401 triggers the callback.

---

### R-05: Dual Network Stack Desynchronization (`GetConnect` vs `Dio`)
- **Category**: Networking & Maintainability
- **Severity**: **High (P1)** • **Probability**: High
- **Description**: `CustomerAuthApiService` and `GeoLookupApiService` use `GetConnect` with hardcoded URL concatenation and custom headers, while the rest of the application uses `ApiClient` (Dio) with interceptors and token injection. Changes to API base URL, timeout policies, or global logging must be duplicated in two incompatible engines.
- **Root Cause**: Legacy code retained during early GetX prototyping alongside modern Dio repository architecture.
- **Mitigation Strategy**:
  1. Retire `CustomerAuthApiService` and route all Auth endpoints through `AuthRepositoryImpl` backed by `ApiClient`.
  2. Convert `GeoLookupApiService` to a pure repository contract using `ApiClient`.
- **Detection & Verification**: Grep scan verifying zero imports of `package:get/get_connect/` in `lib/core/`.

---

### R-06: Wishlist Data Leakage Across User Logout
- **Category**: Security & State Consistency
- **Severity**: **High (P1)** • **Probability**: High
- **Description**: `AppSettingsController._clearLocalUserData()` purges cart, orders, and addresses during logout, but omits `WishlistController`. When another user logs in on the same device, the previous user's favorite products remain visible.
- **Root Cause**: Hardcoded manual controller cleanup list in `AppSettingsController:218`.
- **Mitigation Strategy**:
  1. In Phase 01/Phase 03, add `WishlistController.clear()` to the logout teardown routine.
  2. In Riverpod 3, declarative invalidation (`ref.invalidate(wishlistProvider)`) eliminates manual per-controller lists entirely.
- **Detection & Verification**: Automated regression test asserting `wishlistItems.isEmpty` immediately after `confirmLogout()`.

---

### R-07: Mass Refactoring Breakdown & Release Disruption
- **Category**: Migration Governance & Engineering Process
- **Severity**: **High (P1)** • **Probability**: Medium
- **Description**: Attempting to rewrite the entire application into Riverpod in one large batch, or simultaneously migrating routes to `go_router` and translations to `intl`, will inevitably introduce massive merge conflicts, broken screens, and broken checkout flows.
- **Root Cause**: Architecture perfectionism over disciplined incremental delivery.
- **Mitigation Strategy**:
  1. **Strict Core-First Policy**: Migrate strictly one module at a time.
  2. Keep `GetMaterialApp`, `AppPages`, and `AppTranslations` working unchanged until Phase 09.
  3. Enforce the Single-Writer rule: either GetX or Riverpod writes state for a module, never both.
- **Detection & Verification**: Migration gate checks requiring each module PR to pass `flutter analyze` and `flutter test` independently.

---

### R-08: Incompatible SDK Constraints on `riverpod_lint`
- **Category**: Toolchain & Dependency Resolution
- **Severity**: **High (P1)** • **Probability**: High (if blindly added)
- **Description**: `riverpod_lint: 3.2.0` requires a Dart 3.13 prerelease (dev) SDK. Adding it to `pubspec.yaml` on stable Flutter 3.47.3 / Dart 3.13.3 causes `flutter pub get` resolution failure.
- **Root Cause**: Version mismatch in experimental developer tooling.
- **Mitigation Strategy**:
  1. Strictly omit `riverpod_lint` during initial migration phases.
  2. Use existing `flutter_lints: ^6.0.0` with manual Riverpod peer review guidelines.
- **Detection & Verification**: `flutter pub get` verification during Phase 01 dependency addition.

---

### R-09: Unbound Route Deep-Link Runtime Crashes
- **Category**: Routing & Navigation Stability
- **Severity**: **Medium (P2)** • **Probability**: Medium
- **Description**: 8 routes in `AppPages` (`/cart`, `/payment`, `/orders`, etc.) have no `binding:`. They rely exclusively on `InitialBinding` having previously registered their dependencies. If a user enters via a deep link or widget test without `InitialBinding`, the app crashes with `Get.find()` error.
- **Root Cause**: Fragile reliance on global eager initialization rather than route-scoped dependency bindings.
- **Mitigation Strategy**:
  1. Maintain `InitialBinding` throughout the transitional bridge phases.
  2. In Riverpod 3, providers are globally accessible and pull-based; deep linking to any screen automatically resolves required providers without route bindings.
- **Detection & Verification**: Widget tests pumping individual screens in isolation.

---

### R-10: Out-of-Order Search Responses Overwriting Current Results
- **Category**: Concurrency & Search Discovery
- **Severity**: **Medium (P2)** • **Probability**: Medium
- **Description**: When a user types rapidly in the search bar ("Abaya", "Abaya Velvet"), fast keystrokes can fire overlapping HTTP requests. If request #1 returns after request #2, stale results overwrite current results.
- **Root Cause**: Missing request cancellation token on subsequent query dispatches.
- **Mitigation Strategy**:
  1. Implement a 350ms debounce before dispatching search queries.
  2. Attach Dio `CancelToken` to the search request, managed via Riverpod's `ref.onDispose(cancelToken.cancel)`.
- **Detection & Verification**: Unit test with simulated network jitter asserting only the latest query result is emitted.

