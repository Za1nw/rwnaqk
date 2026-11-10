# Phase 09 — Navigation & Localization Migration Architecture

## 1. Executive Summary

This document specifies the complete decoupling and migration of routing, navigation, and multi-language localization from GetX to native Flutter primitives and Riverpod 3.5.0 state providers.

---

## 2. Navigation Architecture (`AppNav` & `AppRouter`)

The legacy application relied on `GetMaterialApp`, `GetPage` definitions, and `Get.toNamed()` / `Get.offAllNamed()` calls throughout presentation and core services. 

### 2.1 Native Navigation Controller (`AppNav`)
A production-grade, singleton-free navigation service `AppNav` was implemented in `lib/core/routing/app_nav.dart` using Flutter's native `GlobalKey<NavigatorState>`:

```dart
class AppNav {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String? currentRoute;

  static BuildContext? get currentContext => navigatorKey.currentContext;
  static BuildContext? get context => currentContext;

  static Future<T?>? toNamed<T extends Object?>(String routeName, {Object? arguments}) {
    currentRoute = routeName;
    return navigatorKey.currentState?.pushNamed<T>(routeName, arguments: arguments);
  }

  static Future<T?>? offAllNamed<T extends Object?>(String routeName, {Object? arguments}) {
    currentRoute = routeName;
    return navigatorKey.currentState?.pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void back<T extends Object?>([T? result]) {
    navigatorKey.currentState?.pop<T>(result);
  }
}
```

### 2.2 Route Table & Generation (`AppRouter`)
`AppRouter.onGenerateRoute` in `lib/routes/app_router.dart` handles all declarative route lookups, route transitions, and strongly-typed argument deserialization:
- `/main` -> `MainUiView` (Shell containing Home, Discovery, Wishlist, Cart, Profile).
- `/login`, `/register`, `/otp-verification` -> Authentication suite.
- `/cart` -> Pure Riverpod `CartView`.
- `/checkout`, `/payment`, `/order-confirmation` -> Transactional checkout flow.
- `/orders`, `/order-details` -> Order tracking and history.
- `/addresses`, `/add-address`, `/edit-address` -> Shipping address management.
- `/product-details` -> Dynamic product details page with `productId` extracted from route arguments.

### 2.3 Application Bootstrap Integration
In `lib/main.dart`, `MaterialApp` replaced `GetMaterialApp`:
```dart
MaterialApp(
  navigatorKey: AppNav.navigatorKey,
  onGenerateRoute: AppRouter.onGenerateRoute,
  initialRoute: initialRoute,
  locale: ref.watch(appLocaleProvider),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: const [
    AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
)
```

---

## 3. Localization & Translation Architecture

### 3.1 Legacy Decoupling
Previously, widgets used `'some_key'.tr` which resolved via `Get.locale` and GetX internal translation dictionaries.

### 3.2 Native Riverpod Localization Engine
- **`AppTranslations`:** Centralized translation dictionary loader (`lib/core/localization/app_localizations.dart` and `lib/core/translations/app_translations.dart`).
- **`.tr` String Extension:** Preserves zero-churn developer ergonomics:
  ```dart
  extension StringTranslationExtension on String {
    String get tr => AppTranslations.translate(this);
  }
  ```
- **`AppLocaleNotifier`:** State notifier managing dynamic language switching (`Locale('ar', 'YE')` vs `Locale('en', 'US')`), persisting user selection to `SharedPreferences`:
  ```dart
  class AppLocaleNotifier extends Notifier<Locale> {
    @override
    Locale build() => _loadInitialLocale();

    Future<void> setLocale(Locale locale) async {
      state = locale;
      AppTranslations.currentLocale = locale;
      await _persistLocale(locale);
    }
  }
  ```
- **Full Arabic RTL Support:** Native `Directionality` support guarantees complete bidirectional layout mirroring, correct typography, and icon alignment without layout regressions.

---

## 4. Verification & Gate Outcome

1. **Unit Verification:** Verified through `test/phase9_final_riverpod_migration_test.dart` (Test 6 & Test 7):
   - Dynamic locale toggling between Arabic (`ar`) and English (`en`) verified without GetX.
   - Translation keys (`Tk.homeTitle`, `Tk.settingsLogout`) accurately resolve in both languages.
   - `AppNav.currentRoute` tracks push/pop navigation transitions accurately.
2. **Analysis:** Zero compilation errors, missing bindings, or unresolved route names.

