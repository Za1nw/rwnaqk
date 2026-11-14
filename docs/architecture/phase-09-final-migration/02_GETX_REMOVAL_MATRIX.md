# Phase 09 — Complete GetX Removal & Inventory Matrix

## 1. Inventory Summary

Prior to Phase 09, 178 files in `lib/` and 17 files in `test/` referenced `package:get/`. The dependencies fall into six distinct categories:

1. **Routing & Framework Core:** `GetMaterialApp`, `GetPage`, `GetMiddleware`, `Get.toNamed`, `Get.back`, `Get.offAllNamed`.
2. **Localization:** `Translations`, `Get.updateLocale`, and `.tr` String extension.
3. **Dependency Injection:** `Bindings`, `InitialBinding`, `Get.put`, `Get.find`, `Get.isRegistered`, `Get.lazyPut`.
4. **UI Feedback & Dialogs:** `Get.snackbar`, `Get.dialog`, `Get.bottomSheet`.
5. **State Management Controllers & Observers:** `GetxController`, `Rx<T>`, `Obx`, `GetBuilder`, `GetView`.
6. **Legacy Compatibility Bridges:** Facades maintained in prior phases to prevent breaking non-migrated screens.

---

## 2. Comprehensive Artifact Migration & Removal Matrix

| Component / Artifact | Path | GetX Usage | Riverpod 3 / Native Replacement | Target Action | Risk Level |
|---|---|---|---|---|---|
| **App Entry Point** | `lib/main.dart` | `GetMaterialApp`, `initialBinding`, `getPages`, `translations` | Native `MaterialApp`, `onGenerateRoute`, `appLocaleProvider`, Riverpod `UncontrolledProviderScope` | Refactor | Medium |
| **Initial Binding** | `lib/core/bindings/initial_binding.dart` | `Bindings`, `Get.put` | Riverpod DI in `core_providers.dart` | Delete | Low |
| **Core Providers** | `lib/core/di/core_providers.dart` | `Get.isRegistered`, `Get.put`, `Get.find` | Pure Riverpod `Provider<T>` | Refactor | Low |
| **Auth Middleware** | `lib/core/middleware/auth_middleware.dart` | `GetMiddleware`, `Get.find<AuthSessionService>()` | Native route interceptor in `AppRouter.onGenerateRoute` | Refactor | Low |
| **Route Map** | `lib/routes/app_pages.dart` | `GetPage`, `GetMiddleware` | `lib/routes/app_router.dart` (`MaterialPageRoute`, `RouteSettings`) | Replace | Medium |
| **Navigation Facade** | New `lib/core/routing/app_nav.dart` | `Get.toNamed`, `Get.back`, etc. | Global `AppNav` using `GlobalKey<NavigatorState>` | Create | Low |
| **Translations** | `lib/core/translations/app_translations.dart` | `Translations` class | Native `LocalizationsDelegate` + `.tr` extension | Refactor | Low |
| **Feedback & Notifier** | `lib/core/utils/app_notifier.dart` | `Get.snackbar`, `Get.dialog` | `ScaffoldMessengerKey` + `showModalBottomSheet` | Refactor | Low |
| **Auth Session Service** | `lib/core/services/auth/auth_session_service.dart` | `GetxService`, `Rx<AuthSessionState>` | `authSessionProvider` (Phase 04 Riverpod state) | Deprecate/Remove | Low |
| **Login Flow** | `lib/modules/auth/controllers/login_controller.dart` | `GetxController`, `RxBool`, `RxString` | `loginFormProvider` (Riverpod `Notifier`) | Replace | Low |
| **Register Flow** | `lib/modules/auth/controllers/register_controller.dart` | `GetxController`, `RxBool` | `registerFormProvider` (Riverpod `Notifier`) | Replace | Low |
| **Forgot Password** | `lib/modules/auth/controllers/forgot_password_controller.dart` | `GetxController` | `forgotPasswordFormProvider` (Riverpod `Notifier`) | Replace | Low |
| **2FA Challenge** | `lib/modules/auth/controllers/two_factor_challenge_controller.dart` | `GetxController` | `twoFactorFormProvider` (Riverpod `Notifier`) | Replace | Low |
| **Auth Views** | `lib/modules/auth/views/*` | `GetView`, `Obx`, `Get.find` | `ConsumerWidget`, `ref.watch`, `ref.read` | Refactor | Low |
| **Home State** | `lib/modules/home/controllers/home_controller.dart` | `GetxController`, `RxList` | `homeContentProvider` (Riverpod `AsyncNotifier`) | Replace | Medium |
| **Main Navigation** | `lib/modules/home/controllers/main_controller.dart` | `GetxController`, `RxInt currentTab` | `mainNavigationProvider` (Riverpod `Notifier<int>`) | Replace | Low |
| **Customer Profile** | `lib/modules/customer/controllers/profile_controller.dart` | `GetxController`, `GetBuilder` | `customerProfileProvider` (Riverpod `AsyncNotifier`) | Replace | Low |
| **App Settings** | `lib/modules/customer/controllers/app_settings_controller.dart` | `GetxController`, `Get.updateLocale` | `appSettingsProvider`, `appLocaleProvider`, `appThemeProvider` | Replace | Low |
| **2FA Settings** | `lib/modules/customer/controllers/two_factor_settings_controller.dart` | `GetxController` | `twoFactorSettingsProvider` | Replace | Low |
| **Catalog Bridge** | `lib/modules/catalog/controllers/*` | Compatibility bridges to Riverpod | Pure Riverpod consumer widgets | Delete/Clean | Low |
| **Cart Bridge** | `lib/modules/cart/controllers/cart_controller.dart` | Compatibility bridge to Riverpod | Pure Riverpod `cartProvider` | Delete/Clean | Low |
| **Orders Bridge** | `lib/modules/orders/controllers/orders_controller.dart` | Compatibility bridge to Riverpod | Pure Riverpod `ordersProvider` | Delete/Clean | Low |
| **Addresses Bridge** | `lib/modules/customer/controllers/addresses_controller.dart` | Compatibility bridge to Riverpod | Pure Riverpod `customerAddressesProvider` | Delete/Clean | Low |
| **Wishlist Bridge** | `lib/modules/wishlist/controllers/wishlist_controller.dart` | Compatibility bridge to Riverpod | Pure Riverpod `wishlistProvider` | Delete/Clean | Low |
| **Search Bridge** | `lib/modules/search/controllers/app_search_controller.dart` | Compatibility bridge to Riverpod | Pure Riverpod `searchProvider` | Delete/Clean | Low |
| **Support Bridge** | `lib/modules/support/controllers/*` | Compatibility bridge to Riverpod | Pure Riverpod `supportChatProvider` | Delete/Clean | Low |
| **UI Widgets** | 100+ files across `widgets/` | `import 'package:get/get.dart'` for `.tr` | `import 'package:rwnaqk_frontend/core/localization/app_localizations.dart'` | Refactor | Low |
| **Pubspec Dependency** | `pubspec.yaml` | `get: ^4.7.3` | Removed from dependencies | Delete | Low |

---

## 3. Migration Sequence & Gates

1. **Gate 1: Localization & Global Routing Abstraction (Part E & F):**
   - Implement `AppLocalizations` + `.tr` extension.
   - Implement `AppNav` + `AppRouter.onGenerateRoute` with global `navigatorKey` and `scaffoldMessengerKey`.
   - Update `MyApp` in `main.dart` to native `MaterialApp`.
2. **Gate 2: Residual Auth Migration (Part C):**
   - Provide Riverpod Notifiers for login, register, forgot password, OTP, reset, and 2FA challenge.
   - Convert all Auth screens to `ConsumerWidget`.
3. **Gate 3: Feature State Migration (Part D):**
   - Migrate Home & Main navigation tabs.
   - Migrate Profile & Settings.
4. **Gate 4: Compatibility Bridges Decommissioning (Part G & I):**
   - Disconnect and remove legacy GetX controllers and bindings.
   - Remove `InitialBinding`.
5. **Gate 5: Clean Codebase & `pubspec.yaml` (Part H & I):**
   - Sweep all `.dart` files in `lib/` and `test/` to remove `package:get`.
   - Remove `get: ^4.7.3` from `pubspec.yaml` and run `flutter pub get`.
6. **Gate 6: Verification & Release (Part J):**
   - `flutter analyze` clean.
   - All tests passing.
   - Android Staging UI verification.

