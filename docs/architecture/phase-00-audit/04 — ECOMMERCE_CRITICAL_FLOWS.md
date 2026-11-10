# 04 — E-Commerce Critical Customer Journeys Assessment

> **Phase**: Phase 00 — Architecture Audit & Migration Readiness  
> **Project**: Rawnaquk E-Commerce Storefront (`rwnaqk_frontend`)  
> **Backend Authority**: Laravel REST API  
> **Mandate**: Ensure transactional integrity, zero customer data leakage, and backend-authoritative safety  

---

## 1. Cardinal Principle: Laravel Backend Authority

Across all 13 customer journeys, the **Laravel backend is the sole source of truth** for:
1. **Pricing & Currency**: Grand totals, VAT, shipping tiers, and discounts must never be computed authoritatively on the client.
2. **Stock & Inventory**: Variant availability and max purchase quantities are validated server-side.
3. **Coupon Validation**: Discount applicability, minimum order amounts, and expiration are strictly determined by the server.
4. **Address Serviceability**: Delivery coverage areas and delivery fee calculation depend on Laravel geo rules.
5. **Order Creation & Idempotency**: Order numbers, invoice timestamps, and payment statuses are issued exclusively by Laravel.

---

## 2. In-Depth Journey Assessments

### Journey 1: Application Startup & Onboarding
- **Participating Controllers**: `OnboardingController`, `OnboardingUiController`.
- **Services & Repositories**: `SharedPreferences`, `SecureAuthTokenStorage`, `AuthSessionService`, `CustomerAuthApiService`.
- **State Classification**:
  - *Local*: Active intro slide index (`currentIndex`).
  - *Shared*: `hasSeenOnboarding` boolean, `persistedToken` string.
- **Persistence Requirements**:
  - Survives navigation: Yes.
  - Survives restart: Yes (persisted in `SharedPreferences` key `onboarding_seen` and secure storage key `auth_token`).
- **Failure Behavior**: If `.env` or SharedPreferences fails to initialize, defaults gracefully to `AppRoutes.onboarding`.
- **Concurrency & Stale State Risks**: Low.
- **Existing Test Coverage**: Covered in `mock_store_e2e_test.dart` and `secure_auth_token_storage_test.dart`.

---

### Journey 2: Login, Registration & Session Restoration
- **Participating Controllers**: `LoginController`, `RegisterController`.
- **Services & Repositories**: `IAuthRepository` (`AuthRepositoryImpl`), `LoginService`, `RegisterService`, `AuthSessionService`, `SecureAuthTokenStorage`, `GeoLookupApiService`.
- **State Classification**:
  - *Local*: Form fields, validation error messages, password visibility toggles.
  - *Shared*: `AuthSessionService.token` (`RxnString`), `customer` (`Rxn<CustomerModel>`), `isGuestMode` (`RxBool`).
- **Persistence Requirements**:
  - Survives navigation: Yes.
  - Survives restart: Yes. The token is stored in KeyStore / Keychain via `SecureAuthTokenStorage.writeToken()`.
- **Failure Behavior**:
  - 422: `ValidationException` parsed and displayed under respective form fields.
  - 401: Clears session and redirects to `/login`.
  - Network timeout: Displays localized error toast via `AppToast.error`.
- **Concurrency & Race Conditions**:
  - Double submit prevented via `isSubmitting.value` guard.
- **Existing Test Coverage**: `network_and_repositories_test.dart:3-5`, `p0_hardening_test.dart:1-2`, `phase2_stabilization_test.dart:1-3`.

---

### Journey 3: Two-Factor Authentication (2FA)
- **Participating Controllers**: `TwoFactorChallengeController`, `TwoFactorSettingsController`.
- **Services & Repositories**: `IAuthRepository`, `TwoFactorSettingsService`, `CustomerAuthApiService`, `AuthSessionService`.
- **State Classification**:
  - *Local*: 6-digit OTP code, recovery code input, countdown timer for resend.
  - *Shared*: 2FA requirement flag (`requiresTwoFactor` in `LoginResult`).
- **Persistence Requirements**:
  - Survives navigation: 2FA challenge is an ephemeral modal route; if popped, session remains unauthenticated.
  - Survives restart: No. User must re-enter credentials upon app restart.
- **Failure Behavior**: Invalid OTP code returns 422/401; error displayed inline without closing challenge screen.
- **Concurrency & Race Conditions**: Resend OTP button disabled during 60-second cooldown timer.
- **Existing Test Coverage**: Partially covered in repository tests; widget UI flow lacks dedicated widget tests.

---

### Journey 4: Home Screen Data & Main Navigation
- **Participating Controllers**: `MainController`, `HomeController`, `HomeUiController`.
- **Services & Repositories**: `MainService`, `HomeService`, `IProductsRepository`.
- **State Classification**:
  - *Local*: Banner carousel active index, category tab selection.
  - *Shared*: `MainController.currentIndex` (controls bottom navigation bar: Home, Catalog, Wishlist, Cart, Profile).
- **Persistence Requirements**:
  - Survives navigation: Tab index persists across child route pushes and pops.
  - Survives restart: No (resets to index 0: Home).
- **Failure Behavior**: Home feed renders skeleton loading; on error, displays `AppErrorState` with retry button.
- **Concurrency & Race Conditions**: Banner auto-play timer paused during user drag gesture.
- **Existing Test Coverage**: `phase3_e2e_journey_test.dart`, `mock_store_e2e_test.dart`.

---

### Journey 5: Product Listing, Search, Filtering & Pagination
- **Participating Controllers**: `ProductsListingController`, `AppSearchController`, `*UiController`.
- **Services & Repositories**: `IProductsRepository` (`ProductsRepositoryImpl`), `ProductsListingService`, `SearchService`.
- **State Classification**:
  - *Local*: Search query text, selected category filters, price range slider (`minPrice`, `maxPrice`), active sort (`ListingSort`).
  - *Shared*: Paginated product items list (`products`), `hasMorePages` flag.
- **Persistence Requirements**:
  - Survives navigation: Search query and filter state survive navigating to a product details screen and returning back.
  - Survives restart: Recent search keywords saved in local preferences.
- **Failure Behavior**: If page N fails to load, `isNextPageLoading` resets to false; user can pull-to-refresh or re-trigger scroll.
- **Concurrency & Race Conditions**:
  - Debounce applied to search input (350ms) to prevent out-of-order API responses overwriting latest input.
- **Existing Test Coverage**: `network_and_repositories_test.dart:9-10`.

---

### Journey 6: Product Details, Variants & Availability
- **Participating Controllers**: `ProductDetailsController`, `ProductDetailsUiController`.
- **Services & Repositories**: `IProductsRepository`, `ProductDetailsService`, `CartController`, `WishlistController`.
- **State Classification**:
  - *Local*: Selected color option, selected size attribute, gallery image carousel index, quantity counter.
  - *Shared*: Synchronized favorite status with `WishlistController`.
- **Persistence Requirements**:
  - Survives navigation: Screen-scoped; disposed when route is popped.
  - Survives restart: No.
- **Failure Behavior**: If product ID is invalid or network fails, displays `AppEmptyState` or `AppErrorState`.
- **Concurrency & Race Conditions**: Fast tapping "Add to Cart" guarded by UI debounce.
- **Existing Test Coverage**: `product_details_test.dart` (5 extensive tests including dynamic attribute groups and size guides).

---

### Journey 7: Favorites & Wishlist
- **Participating Controllers**: `WishlistController`, `WishlistUiController`.
- **Services & Repositories**: `WishlistService`.
- **State Classification**:
  - *Shared*: `wishlistItems` (`RxList<HomeProductItem>`).
- **Persistence Requirements**:
  - Survives navigation: Yes (registered with `fenix: true` in `InitialBinding`).
  - Survives restart: In-memory only in current codebase (backend wishlist endpoint planned).
- **Failure Behavior**: In-memory operations are synchronous and infallible.
- **Identified Gap / Risk**: **Wishlist items are NOT purged when user logs out in `AppSettingsController`!**
- **Existing Test Coverage**: `phase3_e2e_journey_test.dart`.

---

### Journey 8: Cart Operations & Real-Time Server Quote
- **Participating Controllers**: `CartController`, `CartUiController`.
- **Services & Repositories**: `CartService`, `ApiClient` (`POST /api/v1/customer/cart/quote`, `POST /api/v1/customer/cart/validate-coupon`), `ProfileStoreService`.
- **State Classification**:
  - *Shared*: `cartItems` (`RxList<HomeProductItem>`), `itemQuantities` (`RxMap<String, int>`), `couponCode` (`RxString`), `serverQuote` (`Rxn<CartQuoteModel>`), `shippingAddress` (`Rx<ShippingAddress>`).
- **Persistence Requirements**:
  - Survives navigation: Yes (registered with `permanent: true` in `InitialBinding`).
  - Survives restart: In-memory only; cleared on app restart or logout.
- **Failure Behavior**:
  - If server quote fails (e.g. offline): falls back to local estimated calculations (`_service.computeItemsTotal`), with clear UI indicator that final total will be verified at checkout.
- **Concurrency & Race Conditions**:
  - Fast item quantity increments debounce server quote requests.
- **Backend Authority**: Laravel recalculates subtotal, applies coupon logic, computes shipping fees based on address governorate, and returns verified grand total.
- **Existing Test Coverage**: `network_and_repositories_test.dart:15-18`, `phase3_e2e_journey_test.dart`, `mock_store_e2e_test.dart`.

---

### Journey 9: Customer Addresses & Geographic Coverage
- **Participating Controllers**: `AddressesController`, `AddressesUiController`.
- **Services & Repositories**: `IAddressesRepository` (`AddressesRepositoryImpl`), `AddressesService`, `ProfileStoreService`.
- **State Classification**:
  - *Shared*: `addresses` (`RxList<ShippingAddress>`), `defaultAddress`.
- **Persistence Requirements**:
  - Survives navigation: Yes (cached in `ProfileStoreService`).
  - Survives restart: Fetched fresh from `/api/v1/customer/addresses` on session start.
- **Failure Behavior**:
  - If address is in an unsupported delivery region, `isServiceable` is false; checkout displays warning and blocks progress.
- **Concurrency & Race Conditions**: `setPrimaryAddress` uses optimistic UI update with rollback on API error.
- **Existing Test Coverage**: `network_and_repositories_test.dart:11-14`.

---

### Journey 10: Checkout & Payment Verification
- **Participating Controllers**: `PaymentController`, `PaymentUiController`, `CartController`.
- **Services & Repositories**: `PaymentService`, `ApiClient` (multipart upload for receipt images), `ProfileStoreService`.
- **State Classification**:
  - *Local*: `receiptImage` (`Rx<File?>`), `orderNotes` (`RxString`), `selectedWalletAccountIndex`.
  - *Shared*: `paymentMethodId` (`'cod'` vs `'wallet'`), `activeIdempotencyKey` (`RxnString`).
- **Persistence Requirements**:
  - Survives navigation: Preserved across Step 1 (Address), Step 2 (Payment), and Step 3 (Confirmation).
  - Survives restart: No.
- **Failure Behavior**:
  - Missing receipt image for wallet transfer blocks checkout with user guidance toast.
  - Network failure during image upload alerts user before order placement.
- **Concurrency & Race Conditions**:
  - `isSubmitting.value` provides immediate synchronous locking against double-clicks.
- **Existing Test Coverage**: `phase3_e2e_journey_test.dart:2-4`, `mock_store_e2e_test.dart`.

---

### Journey 11: Order Creation, History & Live Tracking
- **Participating Controllers**: `OrdersController`, `OrdersUiController`, `CartController`.
- **Services & Repositories**: `IOrdersRepository` (`OrdersRepositoryImpl`), `OrdersService`, `ApiClient`, `Uuid`.
- **State Classification**:
  - *Shared*: `orders` (`RxList<OrderModel>`), `activeTrackingOrder`.
- **Persistence Requirements**:
  - Survives navigation: Yes.
  - Survives restart: Fetched from `/api/v1/customer/orders`.
- **Transaction Safety & Idempotency**:
  - Every order submission injects `X-Idempotency-Key` (UUID v4).
  - If a network timeout occurs during submission, retry sends the **exact same key**, preventing duplicate order creation on the Laravel backend.
  - Cart is cleared ONLY after server returns 201 Created and validated `OrderModel`.
- **Existing Test Coverage**: `network_and_repositories_test.dart:6-8`, `phase2_stabilization_test.dart:4-5`, `phase3_e2e_journey_test.dart:1`.

---

### Journey 12: Profile & Account Settings
- **Participating Controllers**: `ProfileController`, `EditProfileController`, `AppSettingsController`, `TwoFactorSettingsController`.
- **Services & Repositories**: `ProfileStoreService`, `AppSettingsService`, `AuthSessionService`, `CustomerAuthApiService`.
- **State Classification**:
  - *Shared*: Customer profile details, dark/light theme mode, Arabic/English locale.
- **Persistence Requirements**:
  - Theme mode and locale saved to `SharedPreferences`.
  - Logout cleans session, cart, orders, addresses from memory and deletes secure token.
- **Existing Test Coverage**: `phase3_e2e_journey_test.dart:5`.

---

### Journey 13: Customer Support & Live Assistance
- **Participating Controllers**: `HelpCenterController`, `SupportChatController`.
- **Services & Repositories**: `HelpCenterService`, `SupportChatService`, `url_launcher`.
- **State Classification**:
  - *Local*: Support chat messages (`support_chat_message`), FAQ search filter.
- **Persistence Requirements**: Ephemeral.
- **Failure Behavior**: WhatsApp/Phone launcher verifies URL scheme support before opening external app.
- **Existing Test Coverage**: None currently (manual QA).

