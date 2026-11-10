# 09 — Phase 00 Gate & Migration Readiness Decision

> **Program**: Modernization & State Migration (GetX → Riverpod 3)  
> **Phase**: Phase 00 — Comprehensive Architecture Audit & Migration Readiness  
> **Target Application**: Rawnaquk E-Commerce Storefront (`rwnaqk_frontend`)  
> **Gate Keeper**: Principal Flutter Architect & Senior Software Modernization Specialist  
> **Date**: 2026-11-09  

---

## 1. Formal Gate Decision

### **DECISION: CONDITIONAL PASS**

```text
╔══════════════════════════════════════════════════════════════════════════════╗
║                               GATE VERDICT                                   ║
║                                                                              ║
║                      >>>   CONDITIONAL PASS   <<<                            ║
║                                                                              ║
║  Sufficient evidence, technical inventory, and quality baselines have been   ║
║  established to authorize progression to Phase 01 (Core Stabilization &      ║
║  ProviderScope Bridge). Nonblocking core gaps must be remediated in Phase 01 ║
║  prior to authorizing feature cutovers.                                      ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

## 2. Gate Justification & Decision Criteria

### Why the Gate is a PASS (Readiness Justification):
1. **Repository Layer Purity**: The foundational domain repositories (`IAuthRepository`, `IProductsRepository`, `IAddressesRepository`, `IOrdersRepository`) and the core `ApiClient` are **100% decoupled from GetX**. They are pure Dart contracts ready for direct Riverpod `Provider<T>` binding without refactoring.
2. **Exemplary Quality Baseline**:
   - `flutter analyze`: **0 issues found** (0 errors, 0 warnings, 0 lints).
   - `flutter test`: **55 of 55 tests passing** (100% pass rate in 10.2 seconds).
3. **Environment Alignment**: Dart SDK `3.13.3` verified 100% compatible with `flutter_riverpod: ^3.5.0` (requires Dart >=3.12).
4. **Safety & Zero Disruption**: The entire investigation was executed in read-only mode. Zero application lines were modified, zero dependencies were added, zero Git changes were altered, and all pre-existing uncommitted changes were preserved.

### Why the Pass is CONDITIONAL (Remediation Gaps for Phase 01):
The audit revealed five specific, proven architectural debts that must be resolved as part of **Phase 01 Core Stabilization** before any feature module is cut over:
1. **Gap 1: Dual Network Stacks**: `CustomerAuthApiService` (`GetConnect`) must be deprecated and unified under `AuthRepositoryImpl` / `ApiClient` (Dio).
2. **Gap 2: Silent 401 Handling**: `ApiClient` must be instantiated with a concrete `_onUnauthorized` callback to purge session tokens upon token revocation.
3. **Gap 3: Redundant API Endpoints File**: Dead constant file `lib/core/constants/api_endpoints.dart` must be deleted to eliminate duplicate symbol confusion.
4. **Gap 4: Wishlist Logout Leakage**: `WishlistController` must be added to the logout cleanup routine (and subsequently managed via Riverpod cache invalidation).
5. **Gap 5: Checkout Circular Coupling**: The bidirectional call cycle between `PaymentController` and `CartController` must be untangled via an orchestrating `CheckoutNotifier` design.

---

## 3. Definition of Done (DoD) Verification Audit

| Requirement from Mission Statement | Audit Verification Evidence | DoD Status |
|---|---|---|
| **All existing Flutter modules inspected** | All 11 modules (`auth`, `cart`, `catalog`, `checkout`, `customer`, `home`, `onboarding`, `orders`, `search`, `support`, `wishlist`) inventoried and documented in `01 — PROJECT_AUDIT.md`. | **MET** |
| **GetX dependencies cataloged comprehensively** | Exact counts (39 controllers, 2 services, 2 GetConnect, 17 put, 59 lazyPut, 149 find, 79 Obx, 181 Rx, 4 workers, 560 `.tr`) documented in `02 — GETX_DEPENDENCY_MATRIX.md`. | **MET** |
| **Current architecture & major dependency paths documented** | Real vs ideal flows, Mermaid diagrams, and coupling loops documented in `03 — ARCHITECTURE_DEPENDENCY_MAP.md`. | **MET** |
| **Critical e-commerce customer journeys assessed** | 13 customer journeys (Startup, Auth, 2FA, Home, Catalog, Details, Wishlist, Cart, Addresses, Checkout, Orders, Profile, Support) detailed in `04 — ECOMMERCE_CRITICAL_FLOWS.md`. | **MET** |
| **Target Riverpod 3 APIs & compatibility verified** | `flutter_riverpod 3.5.0` compatibility with Dart 3.13.3 verified; zero-code-generation decision confirmed in `05 — RIVERPOD3_COMPATIBILITY.md`. | **MET** |
| **Dependency-aware migration roadmap established** | 9-phase sequence starting with Core, Pilot (Support), and leaving Checkout/Orders last documented in `06 — MIGRATION_ROADMAP.md`. | **MET** |
| **Testing baseline & diagnostic limitations documented** | 55/55 tests passing, `flutter analyze` clean, test warning analyzed in `07 — TESTING_BASELINE.md`. | **MET** |
| **Comprehensive risk register created** | 10 major architectural, security, and concurrency risks documented with mitigations in `08 — RISK_REGISTER.md`. | **MET** |
| **Pre-existing Git changes untouched** | Verified via `git status` at baseline and final completion. Zero application files modified. | **MET** |
| **Phase 01 has clear prerequisites & acceptance criteria** | Detailed scope, acceptance criteria, and quality gates specified below. | **MET** |

---

## 4. Phase 01: Scope, Prerequisites & Acceptance Criteria

### Objective:
Stabilize core shared dependencies and establish the non-disruptive Riverpod coexistence bridge.

### Strict Scope Constraints for Phase 01:
- **DO NOT** migrate any feature controllers, views, or widgets.
- **DO NOT** replace GetX navigation (`AppPages`, `GetMaterialApp`).
- **DO NOT** replace GetX translations (`.tr`).
- **DO NOT** introduce code generation (`riverpod_generator`, `build_runner`).

### Implementation Backlog for Phase 01:
1. **Dependency Addition**: Add `flutter_riverpod: ^3.5.0` to `pubspec.yaml`.
2. **Root Bridge**: Wrap `MyApp` with `ProviderScope` in `lib/main.dart`:
   ```dart
   runApp(
     ProviderScope(
       child: MyApp(...),
     ),
   );
   ```
3. **Core Providers Definition**: Under `lib/core/di/`, declare:
   - `authTokenStorageProvider = Provider<IAuthTokenStorage>`
   - `apiClientProvider = Provider<ApiClient>` (with active `onUnauthorized` callback)
   - `authRepositoryProvider = Provider<IAuthRepository>`
   - `ordersRepositoryProvider = Provider<IOrdersRepository>`
   - `addressesRepositoryProvider = Provider<IAddressesRepository>`
   - `productsRepositoryProvider = Provider<IProductsRepository>`
4. **Cleanup Redundant Constant**: Delete `lib/core/constants/api_endpoints.dart` (verified zero references).
5. **Fix Wishlist Logout Teardown**: Add `WishlistController` clearing to `AppSettingsController._clearLocalUserData()`.

### Acceptance Criteria for Phase 01 Gate:
1. `flutter analyze` produces 0 errors and 0 warnings.
2. All 55 baseline unit/widget tests continue to pass with 0 failures.
3. App launches seamlessly on Android and Windows with `ProviderScope` active at root.
4. Existing GetX navigation, tabs, translations, and checkout flow operate without regression.
5. All newly declared Riverpod providers have unit tests validating their dependency resolution.

