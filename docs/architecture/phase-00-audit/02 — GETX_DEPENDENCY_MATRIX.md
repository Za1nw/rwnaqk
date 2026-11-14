# 02 — Comprehensive GetX Dependency Matrix & Usage Inventory

> **Phase**: Phase 00 — Architecture Audit & Migration Readiness  
> **Project**: Rawnaquk E-Commerce Storefront (`rwnaqk_frontend`)  
> **Baseline Date**: 2026-11-09  
> **Audit Method**: Full-tree static source code inspection across 335 Dart files  

---

## 1. Executive Summary of GetX Footprint

A exhaustive scan across `lib/`, `test/`, and `integration_test/` identified every occurrence of GetX primitives. The findings demonstrate that while GetX is pervasive throughout the UI and controllers, it has **zero footprint** in pure repositories (`IAuthRepository`, `IProductsRepository`, `IAddressesRepository`, `IOrdersRepository`) and the `ApiClient`.

### Quantitative Metrics Across Production Code (`lib/`):

| GetX Primitive / Feature | Total Occurrences | Distinct Files | Classification Category |
|---|---|---|---|
| **`GetxController`** | 39 | 39 | 1. State Management / Presentation |
| **`GetxService`** | 2 | 2 | 7. Global Application State |
| **`GetConnect`** | 2 | 2 | 8. Utilities / Network Client |
| **`Get.put`** | 17 | 1 (`initial_binding.dart`) | 2. Dependency Injection (Permanent) |
| **`Get.lazyPut`** | 59 | 16 | 2. Dependency Injection (Ephemeral / Fenix) |
| **`Get.find`** | 149 | 62 | 2. Service Locator / Dependency Access |
| **`Get.delete`** | 0 | 0 | 2. Dependency Invalidation (Missing) |
| **`GetBuilder`** | 0 | 0 | 1. State Management (Unused) |
| **`Obx`** | 79 | 45 | 1. Reactive UI Widget |
| **`Rx<T>` / `.obs`** | 181 | 38 | 1. Reactive Observable State |
| **`GetPage`** | 31 | 1 (`app_pages.dart`) | 3. Declarative Route Configuration |
| **`GetMaterialApp`** | 1 | 1 (`main.dart`) | 3. Application Root / Navigation Engine |
| **Navigation (`Get.to/off/back/etc.`)** | 126 | 52 | 3. Imperative Navigation |
| **Route Arguments (`Get.arguments/parameters`)** | 10 | 10 | 3. Navigation Parameters |
| **Overlays (`Get.snackbar/dialog/bottomSheet`)** | 6 | 6 | 4. Dialogs, Overlays & Toasts |
| **`Bindings` / `BindingsBuilder`** | 17 | 17 | 2. Dependency Injection Module |
| **Workers (`ever<T>`)** | 4 | 3 | 5. Reactive Event Streams |
| **Translations (`.tr` string extension)** | 560 | 106 | 8. Localization & Utilities |

---

## 2. Classification by Functional Category

### Category 1: State Management (Reactive Variables & Controllers)
- **Scope**: 39 `GetxController` subclasses, 181 `Rx` observables (`.obs`, `RxInt`, `RxBool`, `RxString`, `RxList`, `Rxn<T>`), 79 `Obx` builder widgets.
- **Observation**: The codebase avoids `GetBuilder` entirely. All reactive state is strictly driven by `Rx` types observed by `Obx` widgets.
- **Riverpod 3 Replacement**:
  - Replace async controllers (`ProductsListingController`, `OrdersController`, `AddressesController`, `ProductDetailsController`) with `AsyncNotifier<T>` / `AsyncNotifierProvider`.
  - Replace synchronous UI controllers (`CartUiController`, `HomeUiController`, `WishlistUiController`, `PaymentUiController`) with `Notifier<T>` / `NotifierProvider`.
  - Replace `Obx` with `ConsumerWidget` / `Consumer` and `ref.watch(provider.select(...))`.

### Category 2: Dependency Injection & Service Locator
- **Scope**: 17 `Get.put(..., permanent: true)` in `InitialBinding`, 59 `Get.lazyPut(..., fenix: true)` across feature bindings, 149 `Get.find<T>()` lookups.
- **Observation**:
  - `Get.put` is confined exclusively to `InitialBinding` where it creates global singletons.
  - `Get.find` is heavily abused across presentation controllers to reach into sibling controllers (e.g., `CartController` reaches into `PaymentController`, `WishlistController`, `OrdersController`, and `MainController`).
- **Riverpod 3 Replacement**:
  - Replace `InitialBinding` with top-level `Provider<T>` declarations (`apiClientProvider`, `authTokenStorageProvider`, `authRepositoryProvider`, `ordersRepositoryProvider`).
  - Eliminate `Get.find` in favor of declarative `ref.watch` or `ref.read` in notifiers.

### Category 3: Navigation & Routing
- **Scope**: `GetMaterialApp` (root), 31 `GetPage` definitions in `AppPages`, 126 imperative calls (`Get.toNamed`, `Get.offNamed`, `Get.offAllNamed`, `Get.back`), 10 `Get.arguments` lookups.
- **Observation**: Navigation is tightly integrated with `GetMiddleware` (`AuthMiddleware`, `GuestMiddleware`).
- **Migration Strategy**:
  - **CRITICAL**: Do NOT replace GetX navigation during Phase 01. State management and routing must be decoupled.
  - Retain `GetMaterialApp` and `GetPage` routes while wrapping the app root in `ProviderScope`.
  - Navigation migration (e.g. to `go_router` or Flutter Navigator 2.0) is a distinct future milestone after all feature state is stabilized on Riverpod.

### Category 4: Dialogs, Snackbars, and Overlays
- **Scope**: 6 direct overlay calls, wrapped inside `RawnaqkToast` (`app_toast.dart`), `AppConfirmDialog` (`app_confirm_dialog.dart`), and `AppSavedDialog` (`app_saved_dialog.dart`).
- **Observation**:
  - `RawnaqkToast` uses `Get.showSnackbar(GetSnackBar(...))` and `Get.overlayContext`.
  - `AppConfirmDialog` uses `Get.dialog()`.
- **Migration Strategy**:
  - Retain the public APIs of `RawnaqkToast` and `AppConfirmDialog`.
  - Update internal implementation to accept `BuildContext` or use a `GlobalKey<ScaffoldMessengerState>` / `GlobalKey<NavigatorState>` when GetX overlay dependencies are eventually decommissioned.

### Category 5: Reactive Streams & Subscriptions (Workers)
- **Scope**: Exactly 4 `ever<T>` workers across 3 files:
  1. `lib/modules/customer/controllers/profile_store_service.dart:105`: `ever<CustomerModel?>(_authSession.customer, _syncFromSession)`
  2. `lib/modules/cart/controllers/cart_controller.dart:729`: `ever<List<dynamic>>(_profileStore.addresses, (list) { ... })`
  3. `lib/modules/cart/controllers/cart_controller.dart:742`: `ever<ShippingAddress>(shippingAddress, (addr) { ... })`
  4. `lib/modules/checkout/controllers/payment_controller.dart:268`: `ever<List<WalletTransferAccount>>(walletAccounts, (accounts) { ... })`
- **Observation**: All 4 workers synchronize state between stores (e.g. auth session → profile store, profile addresses → cart shipping address).
- **Riverpod 3 Replacement**:
  - Replace cross-store `ever` workers with declarative provider derivation (`ref.watch`) inside Riverpod Notifiers. When `authSessionProvider` changes, dependent providers automatically recompute without manual worker registration and teardown.

### Category 6: Lifecycle Management
- **Scope**: `onInit()`, `onReady()`, and `onClose()` methods across 39 controllers.
- **Observation**:
  - Controllers manage text editing controllers, focus nodes, scroll listeners, and worker teardown inside `onClose()`.
- **Riverpod 3 Replacement**:
  - `build()` in `Notifier` / `AsyncNotifier` replaces `onInit()`.
  - `ref.onDispose()` replaces `onClose()` for releasing timers, workers, and Dio `CancelToken`s.
  - UI-specific resources (`ScrollController`, `TextEditingController`) should be managed in `ConsumerStatefulWidget` or Flutter hooks, not inside business state providers.

### Category 7: Shared & Global Application State
- **Scope**: `AuthSessionService` (`lib/core/services/auth/auth_session_service.dart`), `ProfileStoreService` (`lib/modules/customer/controllers/profile_store_service.dart`), and `InitialBinding`.
- **Observation**:
  - `AuthSessionService` extends `GetxService` and maintains `token`, `customer`, `requiresEmailVerification`, and `isGuestMode`.
  - It triggers imperative navigation (`Get.offAllNamed(AppRoutes.login)`) from deep within its background session refresh.
- **Riverpod 3 Replacement**:
  - `AuthSessionService` → `AsyncNotifierProvider<AuthSessionNotifier, AuthSessionState>`.
  - Navigation side-effects moved to presentation listeners (`ref.listen(authSessionProvider, ...)`).

### Category 8: Utilities & Miscellaneous Dependencies
- **Scope**: `CustomerAuthApiService` and `GeoLookupApiService` (`GetConnect`), `AppTranslations` (`Translations`), and 560 `.tr` calls across 106 UI files.
- **Observation**:
  - GetConnect introduces a duplicate HTTP engine.
  - `.tr` extension provides seamless runtime translations for Arabic and English.
- **Migration Strategy**:
  - Eliminate `GetConnect` by routing Auth and Geo endpoints through the pure Dio `ApiClient`.
  - Retain `AppTranslations` and `.tr` during state migration to avoid touching 106 presentation files.

---

## 3. Comprehensive Traceable Inventory Table

The following table catalogs every primary GetX component across the repository:

| # | File Path | Class / Symbol | GetX Feature Used | Dependent Modules | Lifecycle Behavior | Recommended Riverpod Target | Risk Level | Evidence from Source Code |
|---|---|---|---|---|---|---|---|---|
| 1 | `lib/main.dart` | `MyApp` | `GetMaterialApp` | All Modules | App lifetime root | Keep `GetMaterialApp` inside `ProviderScope` | Medium | `main.dart:71`: `return GetMaterialApp(...)` |
| 2 | `lib/core/bindings/initial_binding.dart` | `InitialBinding` | `Bindings`, `Get.put` (17x), `Get.lazyPut` (6x) | Core, Auth, Cart, Orders, Customer, Home | Permanent singleton allocation | Root `ProviderScope` with pure providers | High | `initial_binding.dart:54`: `Get.put<IAuthTokenStorage>(..., permanent: true)` |
| 3 | `lib/core/services/auth/auth_session_service.dart` | `AuthSessionService` | `GetxService`, `RxnString`, `RxBool`, `Rxn<CustomerModel>`, `Get.offAllNamed` | Auth, Customer, Cart, Middleware | App lifetime, survives navigation | `NotifierProvider<AuthSessionNotifier, AuthSessionState>` | Critical (P0) | `auth_session_service.dart:10`: `class AuthSessionService extends GetxService` |
| 4 | `lib/core/services/auth/customer_auth_api_service.dart` | `CustomerAuthApiService` | `GetConnect`, `Response` | Auth, AppSettings, Profile | Registered in `InitialBinding` | Eliminate; merge into `AuthRepositoryImpl` (`ApiClient`) | High | `customer_auth_api_service.dart:40`: `class CustomerAuthApiService extends GetConnect` |
| 5 | `lib/core/services/geo/geo_lookup_api_service.dart` | `GeoLookupApiService` | `GetConnect` | Register | Ephemeral via `RegisterBinding` | Convert to `IGeoRepository` via `ApiClient` | Medium | `geo_lookup_api_service.dart:5`: `class GeoLookupApiService extends GetConnect` |
| 6 | `lib/core/middleware/auth_middleware.dart` | `AuthMiddleware`, `GuestMiddleware` | `GetMiddleware`, `RouteSettings`, `Get.find` | Routes, Navigation | Invoked during route transitions | Retain until future router migration | High | `auth_middleware.dart:8`: `class AuthMiddleware extends GetMiddleware` |
| 7 | `lib/core/widgets/feedback/app_toast.dart` | `RawnaqkToast` | `GetSnackBar`, `Get.showSnackbar`, `Get.overlayContext` | UI Notifications | Ephemeral overlay | Keep API; abstract context or messenger | Medium | `app_toast.dart:133`: `Get.showSnackbar(GetSnackBar(...))` |
| 8 | `lib/core/widgets/dialogs/app_confirm_dialog.dart` | `AppConfirmDialog` | `Get.dialog` | UI Dialogs | Ephemeral dialog | Standard Flutter `showDialog` | Low | `app_confirm_dialog.dart:16`: `return Get.dialog<bool>(...)` |
| 9 | `lib/core/translations/app_translations.dart` | `AppTranslations` | `Translations`, `.tr` | 106 UI files (560 `.tr` calls) | App lifetime | Keep GetX translations during state migration | High (Friction) | `app_translations.dart:8`: `class AppTranslations extends Translations` |
| 10 | `lib/modules/auth/controllers/login_controller.dart` | `LoginController` | `GetxController`, `RxBool`, `RxString`, `Get.toNamed` | Auth, LoginView | Disposed on screen exit | `AsyncNotifierProvider<LoginNotifier, AsyncValue<void>>` | High | `login_controller.dart:18`: `class LoginController extends GetxController` |
| 11 | `lib/modules/auth/controllers/register_controller.dart` | `RegisterController` | `GetxController`, `RxBool`, `RxString`, `Rxn<YemenGovernoratesLookup>` | Auth, RegisterView | Disposed on screen exit | `AsyncNotifierProvider<RegisterNotifier, RegisterState>` | High | `register_controller.dart:18`: `class RegisterController extends GetxController` |
| 12 | `lib/modules/auth/controllers/two_factor_challenge_controller.dart` | `TwoFactorChallengeController` | `GetxController`, `RxBool`, `RxString` | Auth, 2FA Challenge | Disposed on screen exit | `AsyncNotifierProvider<TwoFactorNotifier, AsyncValue<void>>` | Medium | `two_factor_challenge_controller.dart:8`: `class TwoFactorChallengeController extends GetxController` |
| 13 | `lib/modules/auth/bindings/login_binding.dart` | `LoginBinding` | `Bindings`, `Get.lazyPut` | Auth routes | Registered on route load | Riverpod module provider file | Medium | `login_binding.dart:9`: `class LoginBinding extends Bindings` |
| 14 | `lib/modules/cart/controllers/cart_controller.dart` | `CartController` | `GetxController`, `RxList`, `RxMap`, `Rx<ContactInfoModel>`, `Rxn<CartQuoteModel>`, `Worker` (2x), `Get.find` (11x) | Cart, Checkout, Home, Wishlist | Permanent in `InitialBinding` | `NotifierProvider<CartNotifier, CartState>` | Critical (Commerce) | `cart_controller.dart:39`: `class CartController extends GetxController` |
| 15 | `lib/modules/cart/controllers/cart_service.dart` | `CartService` | `Get.isRegistered`, `Get.find` | Cart | Permanent in `InitialBinding` | `Provider<CartService>` or `ICartRepository` | High | `cart_service.dart:32`: `Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : ApiClient()` |
| 16 | `lib/modules/cart/controllers/cart_ui_controller.dart` | `CartUiController` | `GetxController`, `RxInt`, `RxBool` | CartView | Permanent in `InitialBinding` | `NotifierProvider<CartUiNotifier, CartUiState>` | Medium | `cart_ui_controller.dart:5`: `class CartUiController extends GetxController` |
| 17 | `lib/modules/catalog/controllers/products_listing_controller.dart` | `ProductsListingController` | `GetxController`, `RxList`, `RxBool`, `Rx<ListingSort>`, `ScrollController` | Catalog, Home | Disposed on route pop | `AsyncNotifierProvider<ProductsListingNotifier, ProductsListingState>` | High | `products_listing_controller.dart:17`: `class ProductsListingController extends GetxController` |
| 18 | `lib/modules/catalog/controllers/product_details_controller.dart` | `ProductDetailsController` | `GetxController`, `Rxn<HomeProductItem>`, `RxMap`, `Get.find` (5x) | Catalog, Wishlist, Cart | Disposed on route pop | `AsyncNotifierProvider.family<ProductDetailsNotifier, ProductDetailsState, String>` | High | `product_details_controller.dart:21`: `class ProductDetailsController extends GetxController` |
| 19 | `lib/modules/checkout/controllers/payment_controller.dart` | `PaymentController` | `GetxController`, `RxString`, `RxInt`, `Rx<File?>`, `Worker` (1x), `Get.find` (5x) | Checkout, Cart, Orders | Permanent in `InitialBinding` | `NotifierProvider<PaymentNotifier, PaymentState>` | Critical (Payment) | `payment_controller.dart:25`: `class PaymentController extends GetxController` |
| 20 | `lib/modules/customer/controllers/profile_store_service.dart` | `ProfileStoreService` | `GetxService`, `Rxn<CustomerModel>`, `RxList`, `Worker` (1x) | Customer, Checkout, Cart | Permanent in `InitialBinding` | `NotifierProvider<ProfileStoreNotifier, ProfileStoreState>` | High | `profile_store_service.dart:9`: `class ProfileStoreService extends GetxService` |
| 21 | `lib/modules/customer/controllers/addresses_controller.dart` | `AddressesController` | `GetxController`, `RxList`, `RxBool`, `Get.find` (2x) | Customer, Cart | Disposed on route pop | `AsyncNotifierProvider<AddressesNotifier, List<ShippingAddress>>` | High | `addresses_controller.dart:16`: `class AddressesController extends GetxController` |
| 22 | `lib/modules/customer/controllers/app_settings_controller.dart` | `AppSettingsController` | `GetxController`, `RxBool`, `Rx<ThemeMode>`, `Get.find` (6x) | Customer, Settings | Permanent in `InitialBinding` | `NotifierProvider<AppSettingsNotifier, AppSettingsState>` | High | `app_settings_controller.dart:18`: `class AppSettingsController extends GetxController` |
| 23 | `lib/modules/home/controllers/main_controller.dart` | `MainController` | `GetxController`, `RxInt`, `Get.find` (1x) | MainView, BottomNav, All Tabs | Permanent in `InitialBinding` | `NotifierProvider<MainNavigationNotifier, int>` | Medium | `main_controller.dart:11`: `class MainController extends GetxController` |
| 24 | `lib/modules/home/controllers/home_controller.dart` | `HomeController` | `GetxController`, `RxList`, `RxBool`, `Get.find` (1x) | HomeView | Permanent in `InitialBinding` | `AsyncNotifierProvider<HomeNotifier, HomeFeedState>` | Medium | `home_controller.dart:11`: `class HomeController extends GetxController` |
| 25 | `lib/modules/onboarding/controllers/onboarding_controller.dart` | `OnboardingController` | `GetxController`, `RxInt`, `PageController`, `Get.offAllNamed` | OnboardingView | Disposed on completion | `NotifierProvider<OnboardingNotifier, int>` | Low (Pilot) | `onboarding_controller.dart:11`: `class OnboardingController extends GetxController` |
| 26 | `lib/modules/orders/controllers/orders_controller.dart` | `OrdersController` | `GetxController`, `RxList`, `RxBool`, `Get.find` (3x) | OrdersView, OrderTracking | Fenix in `InitialBinding` | `AsyncNotifierProvider<OrdersNotifier, List<OrderModel>>` | High | `orders_controller.dart:18`: `class OrdersController extends GetxController` |
| 27 | `lib/modules/search/controllers/app_search_controller.dart` | `AppSearchController` | `GetxController`, `RxString`, `RxList`, `TextEditingController` | SearchView | Disposed on route pop | `NotifierProvider<SearchNotifier, SearchState>` | Low (Pilot) | `app_search_controller.dart:12`: `class AppSearchController extends GetxController` |
| 28 | `lib/modules/support/controllers/support_chat_controller.dart` | `SupportChatController` | `GetxController`, `RxList`, `TextEditingController` | SupportChatView | Disposed on route pop | `NotifierProvider<SupportChatNotifier, List<SupportChatMessage>>` | Low (Pilot) | `support_chat_controller.dart:10`: `class SupportChatController extends GetxController` |
| 29 | `lib/modules/wishlist/controllers/wishlist_controller.dart` | `WishlistController` | `GetxController`, `RxList`, `Get.find` (5x) | WishlistView, ProductDetails | Fenix in `InitialBinding` | `NotifierProvider<WishlistNotifier, List<HomeProductItem>>` | Low (Pilot) | `wishlist_controller.dart:18`: `class WishlistController extends GetxController` |
| 30 | `lib/routes/app_pages.dart` | `AppPages` | `GetPage` (31x), `GetMiddleware` (2x) | All Routes | App routing configuration | Retain until router migration phase | High | `app_pages.dart:50`: `static final routes = <GetPage<dynamic>>[...]` |

---

## 4. Separation of Concerns & Non-Substitutable Features

### Why Riverpod 3 Does NOT Directly Replace GetX Navigation
- **Architecture Distinction**: Riverpod is a reactive data-binding and dependency-injection framework. It does not provide built-in routing, URL parsing, deep-link matching, or back-stack manipulation.
- **Decision**: Navigation will remain on `GetPage` / `GetMaterialApp` throughout the state migration. Replacing routing prematurely would introduce severe regression risks in route guards, deep links, and tab preservation.

### Why Riverpod 3 Does NOT Directly Replace GetX Overlays
- **Architecture Distinction**: `Get.snackbar` and `Get.dialog` bypass the `BuildContext` tree using internal overlay keys. Riverpod intentionally requires `BuildContext` or explicitly registered UI controllers.
- **Decision**: Retain existing wrapper facades (`RawnaqkToast.success`, `AppConfirmDialog.show`) while transitioning internal plumbing to Flutter's native `ScaffoldMessenger` and `showDialog` during the global cleanup phase.

