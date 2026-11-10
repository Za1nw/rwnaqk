# 01 — Comprehensive Project Architecture Audit

> **Phase**: Phase 00 — Architecture Audit & Migration Readiness  
> **Status**: Read-Only Baseline Complete  
> **Project**: Rawnaquk E-Commerce Storefront (`rwnaqk_frontend`)  
> **Target Modernization**: GetX ^4.7.3 → Flutter Riverpod 3.5.0 (Feature-First)  
> **Backend Integration**: Laravel REST API  
> **Date**: 2026-11-09  

---

## 1. Executive Summary

This audit establishes the definitive architectural, operational, and code-level baseline for the **Rawnaquk (رَوْنَقُك)** Flutter e-commerce application ahead of its planned migration to **Riverpod 3**. The storefront is an existing, highly stylized, production-oriented application developed for the Yemeni and regional luxury fashion market.

Currently, the application relies on **GetX (^4.7.3)** for state management, dependency injection, and routing. The application features **11 domain/feature modules**, a shared `core` foundation, a centralized `data` infrastructure layer, and a dedicated `routes` layer.

### Key Audit Findings:
1. **Repository & Network Hygiene**: Crucial domain contracts (`IAuthRepository`, `IProductsRepository`, `IAddressesRepository`, `IOrdersRepository`) and the core `ApiClient` (powered by `Dio 5.7.0`) are already **100% pure Dart**, containing zero GetX imports, zero `Rx` types, and zero `BuildContext` dependencies. These contracts represent high-value architectural assets that must be preserved without rewriting.
2. **Quality Baseline**: Static analysis (`flutter analyze`) passes with **0 errors and 0 warnings**. The unit and widget test suite executes **55 automated tests with a 100% pass rate** in under 10 seconds.
3. **Core Architectural Debts Identified**:
   - **Dual Network Stack**: A legacy `CustomerAuthApiService` and `GeoLookupApiService` extend `GetConnect`, operating in parallel to the pure Dio `ApiClient`.
   - **Cross-Controller Coupling**: Severe bidirectional coupling between `PaymentController` (checkout), `CartController` (cart & quote), and `OrdersController` (history & submission).
   - **Global Singleton Proliferation**: `InitialBinding` registers 17 services with `permanent: true`, forcing perpetual memory residency.
   - **Silent 401 Handling**: `ApiClient` has an unconfigured `_onUnauthorized` callback in production composition, preventing automatic session expiration on token invalidation.
   - **Wishlist Memory Leakage**: User logout in `AppSettingsController` clears cart, orders, and addresses, but misses `WishlistController`.
   - **Redundant API Endpoint Definition**: `lib/core/constants/api_endpoints.dart` is an unreferenced duplicate of `lib/core/network/api_endpoints.dart`.

---

## 2. Environment & Project Metadata

| Attribute | Verified Value | Evidence Source |
|---|---|---|
| **Operating System** | Windows 11 Enterprise (64-bit) | Local System Host |
| **Terminal / Shell** | PowerShell (pwsh) | Command Runtime |
| **Flutter SDK** | **3.47.3** (Channel stable) | `flutter --version` |
| **Dart SDK** | **3.13.3** (DevTools 2.60.0) | `flutter --version` |
| **Git Branch** | `bridg/getxtoriverpod` | `git status` |
| **Initial Git State** | Working tree clean except for pre-existing skill modifications | `git status` (recorded at baseline) |
| **State Framework (Current)** | `get: ^4.7.3` | `pubspec.yaml:37` |
| **HTTP Engine** | `dio: 5.7.0` | `pubspec.yaml:45` |
| **Secure Token Storage** | `flutter_secure_storage: ^11.2.0` | `pubspec.yaml:44` |
| **Target State Framework** | `flutter_riverpod: ^3.5.0` (Dart >=3.12 verified) | `riverpod3-35-release-and-compatibility.md` |
| **Total Dart Source Files** | **335 files** across `lib/` | Filesystem scan |
| **Total Automated Tests** | **55 tests** across 8 test suites | `flutter test` |

---

## 3. High-Level Architecture Overview

The application follows a modular structure divided into four primary top-level namespaces:

```text
lib/
├── core/                       # Shared infrastructure, design system & utilities
│   ├── bindings/               # Legacy GetX composition root (InitialBinding)
│   ├── constants/              # App colors, dimensions, env config, storage keys
│   ├── errors/                 # Domain failures and exceptions
│   ├── middleware/             # Route guards (AuthMiddleware, GuestMiddleware)
│   ├── network/                # Pure Dio ApiClient, API endpoints & exceptions
│   ├── services/               # Auth session, token storage, and legacy API services
│   ├── theme/                  # Material 3 luxury light and dark themes
│   ├── translations/           # Arabic/English locale maps and AppTranslations
│   ├── utils/                  # Formatters, validators, money/checkout utilities
│   └── widgets/                # Reusable buttons, inputs, dialogs, toasts
├── data/                       # Shared cross-module models and base contracts
│   ├── models/                 # ApiResponse, CustomerModel, PaginationModel
│   └── repositories/           # BaseRepository with safeCall error mapping
├── modules/                    # 11 Feature Modules
│   ├── auth/                   # Login, register, 2FA, password recovery
│   ├── cart/                   # Cart state, items, promo codes, server quote
│   ├── catalog/                # Products listing, details, reviews, flash sales
│   ├── checkout/               # Payment method, wallet transfer, receipt upload
│   ├── customer/               # Profile, addresses, app settings, 2FA settings
│   ├── home/                   # Main bottom nav tabs, banners, product feeds
│   ├── onboarding/             # Intro slides and initial entry walkthrough
│   ├── orders/                 # Order creation, order details, order tracking
│   ├── search/                 # Product search, filter chips, search history
│   ├── support/                # Help center, FAQs, support chat mock
│   └── wishlist/               # Wishlist and favorite items
└── routes/                     # Centralized navigation configuration
    ├── app_pages.dart          # 30 GetPage route definitions with bindings/guards
    └── app_routes.dart         # String route name constants
```

---

## 4. Comprehensive Feature Module Inventory

Every module has been inspected for structure, state patterns, dependencies, and migration readiness:

| Module | Files | Primary Responsibility | Controllers | Bindings | Repositories & Data Sources | Services | Route Entry Points | Cross-Module Dependencies | Automated Tests | Complexity | Migration Risk |
|---|---|---|---|---|---|---|---|---|---|---|---|
| **`auth`** | 22 | Authentication, registration, OTP, 2FA challenge, password reset | `LoginController`<br>`RegisterController`<br>`ForgotPasswordController`<br>`TwoFactorChallengeController` | `LoginBinding`<br>`RegisterBinding`<br>`ForgotPasswordBinding` | `IAuthRepository`<br>`AuthRepositoryImpl` | `LoginService`<br>`RegisterService`<br>`ForgotPasswordService` | `/login`<br>`/register`<br>`/email-verify`<br>`/two-factor-challenge`<br>`/forgot`<br>`/otp`<br>`/reset` | `CustomerModel`<br>`AuthSessionService`<br>`IAuthTokenStorage`<br>`GeoLookupApiService` | `network_and_repositories_test.dart`<br>`p0_hardening_test.dart`<br>`phase2_stabilization_test.dart` | High | High (P0 Session Security) |
| **`cart`** | 26 | Cart items, item quantities, server quote calculation, coupon validation | `CartController`<br>`CartUiController` | None (Registered in `InitialBinding`) | None (Directly calls `ApiClient` in `CartService`) | `CartService` | `/cart` | `ProfileStoreService`<br>`PaymentController`<br>`OrdersController`<br>`IOrdersRepository`<br>`HomeProductItem`<br>`ShippingAddress` | `network_and_repositories_test.dart`<br>`phase3_e2e_journey_test.dart`<br>`mock_store_e2e_test.dart` | High | High (Commerce Totals) |
| **`catalog`** | 48 | Product catalog, dynamic attributes, variants, reviews, flash sales | `ProductsListingController`<br>`ProductDetailsController`<br>`ReviewsController`<br>`FlashSaleController`<br>`*UiController` (4) | `ProductsListingBinding`<br>`ProductDetailsBinding`<br>`ReviewsBinding`<br>`FlashSaleBinding` | `IProductsRepository`<br>`ProductsRepositoryImpl`<br>`FakeProductsRepository` | `ProductsListingService`<br>`ProductDetailsService`<br>`ReviewsService`<br>`FlashSaleService` | `/listing`<br>`/product`<br>`/reviews`<br>`/flash-sale` | `WishlistController`<br>`CartController`<br>`HomeProductItem` | `product_details_test.dart`<br>`network_and_repositories_test.dart` | High | Medium (Read-Heavy) |
| **`checkout`** | 16 | Payment method selection, wallet receipt upload, order confirmation | `PaymentController`<br>`PaymentUiController` | None (Registered in `InitialBinding`) | None (Delegates to `CartController.payNow`) | `PaymentService` | `/payment`<br>`/order-confirmation`<br>`/order-success` | `CartController`<br>`ProfileStoreService`<br>`OrdersController`<br>`ApiClient` | `phase3_e2e_journey_test.dart`<br>`mock_store_e2e_test.dart` | High | High (Payment & Orders) |
| **`customer`** | 52 | Customer profile, address book, geographic coverage, app settings | `ProfileController`<br>`AddressesController`<br>`EditProfileController`<br>`AppSettingsController`<br>`TwoFactorSettingsController`<br>`*UiController` (3) | `AddressesBinding`<br>`EditProfileBinding`<br>`ProfileBinding`<br>`SettingsBinding`<br>`CustomerBinding` | `IAddressesRepository`<br>`AddressesRepositoryImpl`<br>`FakeAddressesRepository` | `ProfileStoreService`<br>`AddressesService`<br>`EditProfileService`<br>`AppSettingsService`<br>`TwoFactorSettingsService` | `/profile`<br>`/edit-profile`<br>`/addresses`<br>`/settings` | `AuthSessionService`<br>`CartController`<br>`OrdersController`<br>`CustomerAuthApiService` | `network_and_repositories_test.dart`<br>`p0_hardening_test.dart`<br>`phase2_stabilization_test.dart` | High | High (Address Coverage) |
| **`home`** | 26 | Bottom navigation hub, promotional banners, categories, product feeds | `MainController`<br>`HomeController`<br>`MainUiController`<br>`HomeUiController` | None (Registered in `InitialBinding`) | None (Mock/Seed via `HomeService`) | `MainService`<br>`HomeService` | `/main`<br>`/home` | `CartController`<br>`WishlistController`<br>`ProductsRepositoryImpl` | `phase3_e2e_journey_test.dart`<br>`mock_store_e2e_test.dart` | Medium | Medium (Tab Coordinator) |
| **`onboarding`** | 5 | App introduction walkthrough, first-launch preference setting | `OnboardingController`<br>`OnboardingUiController` | `OnboardingBinding` | None | `OnboardingService` | `/onboarding` | `SharedPreferences`<br>`AuthSessionService` | None | Low | Low (Candidate Pilot) |
| **`orders`** | 25 | Order submission, history listing, status details, live timeline tracking | `OrdersController`<br>`OrdersUiController` | None (Registered in `InitialBinding`) | `IOrdersRepository`<br>`OrdersRepositoryImpl`<br>`FakeOrdersRepository` | `OrdersService` | `/orders`<br>`/order-details`<br>`/order-tracking` | `ApiClient`<br>`CartController`<br>`MainController`<br>`Uuid` | `network_and_repositories_test.dart`<br>`phase2_stabilization_test.dart`<br>`phase3_e2e_journey_test.dart` | High | High (Idempotency Key) |
| **`search`** | 7 | Search bar, search query suggestions, filter chips, results view | `AppSearchController`<br>`SearchUiController` | `SearchBinding` | None (Delegates to catalog search) | `SearchService` | `/search`<br>`/search-results` | `ProductsListingController`<br>`HomeProductItem` | None | Low | Low (Secondary Pilot) |
| **`support`** | 17 | Help center FAQs, support channels (WhatsApp, phone), interactive chat | `HelpCenterController`<br>`SupportChatController`<br>`SupportChatUiController` | `SupportBinding` | None | `HelpCenterService`<br>`SupportChatService` | `/help-center`<br>`/support-chat` | `url_launcher`<br>`support_chat_message` | None | Low | Low (Ideal Pilot #1) |
| **`wishlist`** | 9 | Customer favorites, toggle wishlist items, move from wishlist to cart | `WishlistController`<br>`WishlistUiController` | None (Registered in `InitialBinding`) | None (In-memory storage) | `WishlistService` | `/wishlist` | `CartController`<br>`MainController`<br>`HomeProductItem` | `phase3_e2e_journey_test.dart` | Low | Low (Ideal Pilot #2) |

---

## 5. Proven Technical Debt & Architectural Gaps

### Defect 1: Dual Network Stacks (`GetConnect` vs `Dio`)
- **Evidence**:
  - `lib/core/services/auth/customer_auth_api_service.dart:40`: `class CustomerAuthApiService extends GetConnect`
  - `lib/core/services/geo/geo_lookup_api_service.dart:5`: `class GeoLookupApiService extends GetConnect`
  - `lib/core/network/api_client.dart:15`: `class ApiClient` (pure Dio)
- **Problem**: Authentication and Geo services use `GetConnect` with hardcoded URL concatenation and custom header injection, while Catalog, Addresses, Orders, and Cart use `Dio` with centralized interceptors, logging, and error mapping.
- **Risk**: Desynchronized headers, split timeout configurations, uncoordinated token refreshes.

### Defect 2: Duplicate API Endpoints Definition
- **Evidence**:
  - `lib/core/constants/api_endpoints.dart`: 19 lines, contains 4 dynamic auth getters (`$customerAuth/login`, etc.).
  - `lib/core/network/api_endpoints.dart`: 41 lines, contains all endpoints across Auth, Catalog, Cart, Orders, Media, and Addresses.
  - Audit check: Zero files in `lib/` or `test/` import `lib/core/constants/api_endpoints.dart`. All real repositories import `lib/core/network/api_endpoints.dart`.
- **Problem**: Dead legacy constant file causing naming collisions and developer confusion.

### Defect 3: Cross-Controller Coupling & Dependency Cycles
- **Evidence**:
  - `PaymentController.confirmAndSubmitOrder()` (`payment_controller.dart:217`) calls `cart.payNow()`.
  - `CartController.payNow()` (`cart_controller.dart:601`, `675`) calls `Get.find<PaymentController>()` to extract `selectedWalletAccount` and `paymentMethodLabel`.
  - `CartController.payNow()` then calls `Get.find<IOrdersRepository>().submitCheckout()`.
  - `CartController.payNow()` then calls `Get.find<OrdersController>().addOrder(order)`.
- **Problem**: Circular coupling between three major controllers. Neither controller can be tested or migrated in isolation.

### Defect 4: Excessive `permanent: true` Registrations
- **Evidence**:
  - `lib/core/bindings/initial_binding.dart:54-165`: 17 calls to `Get.put(..., permanent: true)`.
  - Includes UI controllers like `AppSettingsUiController`, `PaymentUiController`, and `CartUiController`.
- **Problem**: UI controllers remain permanently allocated in memory even when the user is not in those screens, preventing natural garbage collection.

### Defect 5: Unhandled 401 Unauthorized in `ApiClient`
- **Evidence**:
  - `lib/core/network/api_client.dart:20, 97`: `_onUnauthorized?.call()` is defined to handle HTTP 401.
  - `lib/core/bindings/initial_binding.dart:58`: `ApiClient` is instantiated without passing `_onUnauthorized`.
- **Problem**: When a Dio request receives a 401 from Laravel, the exception is mapped, but no automatic session purge or login redirection occurs.

### Defect 6: Wishlist Leakage Across User Logout
- **Evidence**:
  - `lib/modules/customer/controllers/app_settings_controller.dart:218-230`: `_clearLocalUserData()` purges `_authSession`, `CartController`, `OrdersController`, and `ProfileStoreService.addresses`.
  - `WishlistController` is completely omitted.
- **Problem**: When user A logs out and user B logs in, user A's wishlist items remain visible in memory.

### Defect 7: Fragile Route Bindings (8 Unbound Routes)
- **Evidence**:
  - `lib/routes/app_pages.dart`: Routes `/home`, `/main`, `/cart`, `/payment`, `/order-confirmation`, `/order-success`, `/orders`, `/order-details`, `/order-tracking`, and `/wishlist` have no `binding:`.
  - They rely completely on `InitialBinding` having previously registered their controllers.
- **Problem**: If any of these screens is navigated to via deep link or test runner without `InitialBinding` executing first, a runtime `Get.find()` crash occurs.

---

## 6. Architectural Strengths Worth Preserving

1. **Pure Repository Abstractions**:
   - `IAuthRepository` (`lib/modules/auth/data/repositories/auth_repository.dart`)
   - `IProductsRepository` (`lib/modules/catalog/data/repositories/products_repository.dart`)
   - `IAddressesRepository` (`lib/modules/customer/data/repositories/addresses_repository.dart`)
   - `IOrdersRepository` (`lib/modules/orders/data/repositories/orders_repository.dart`)
   - All 4 contracts are pure Dart interfaces with zero framework dependencies.

2. **Unified Dio ApiClient**:
   - `ApiClient` (`lib/core/network/api_client.dart`) has queued interceptors, automatic Bearer token insertion, comprehensive timeout handling, multipart upload support, and clean Laravel exception translation.

3. **Secure Auth Token Storage**:
   - `SecureAuthTokenStorage` (`lib/core/services/auth/auth_token_storage.dart`) correctly leverages Android KeyStore (`resetOnError: true`) and iOS Keychain (`accessibility: first_unlock`), with automatic legacy SharedPreferences migration and cleanup.

4. **Server-Authoritative Commerce Safety**:
   - Cart totals rely on `POST /api/v1/customer/cart/quote` (`CartQuoteModel`).
   - Order submission uses `X-Idempotency-Key` generated via `Uuid().v4()`, preventing double-charge scenarios on network retry.

5. **Exquisite Luxury Design System**:
   - Royal Burgundy (`#6E0131`) and Luxury Gold (`#FAAD01`) palettes, custom brand gradients, Cairo typography, responsive breakpoints, and fully styled Material 3 light/dark themes.

6. **Automated Testing Culture**:
   - 55 automated tests already present, covering repository operations, token storage, checkout validation, and end-to-end shopping journeys.

---

## 7. Migration Baseline Verdict

The codebase is exceptionally well-suited for an incremental, core-first migration to **Riverpod 3**. Its pure repository layer and clean analyzer baseline eliminate the need for domain or network rewrites. Migration will focus strictly on state management, dependency composition, and uncoupling presentation controllers.

