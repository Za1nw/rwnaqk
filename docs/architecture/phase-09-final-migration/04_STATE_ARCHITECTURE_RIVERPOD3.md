# Phase 09 — Riverpod 3 State Architecture & Topology Specification

## 1. Executive Architecture Overview

With the completion of **Phase 09**, Rawnaquk E-Commerce (رونقك) has completed its architectural transition to **pure Riverpod 3.5.0**. All state management, reactive view updates, and business logic orchestration are now owned exclusively by type-safe, immutable Riverpod Notifiers. 

Zero instances of GetX (`GetxController`, `Rx<T>`, `Obx`, `GetBuilder`, `GetConnect`) remain in the codebase.

```
+---------------------------------------------------------------------------------------------------+
|                                   RIVERPOD 3 APPLICATION STATE TOPOLOGY                           |
+---------------------------------------------------------------------------------------------------+
                                                  |
                         +------------------------+------------------------+
                         |                                                 |
             [App-Level Persistent State]                     [Session-Scoped State Engine]
             - appLocaleProvider                              - authSessionProvider
             - appThemeModeProvider                           (Single Authoritative Session Owner)
             - onboardingProvider                                          |
                         |                                                 | sessionGeneration
                         |                                                 | userId sync
                         +------------------------+------------------------+
                                                  |
              +-----------------------------------+-----------------------------------+
              |                                   |                                   |
     [Customer & Commerce]               [Catalog & Discovery]              [Transactional Flows]
     - addressesProvider                 - homeUiProvider                   - cartProvider
     - customerProfileDataProvider       - catalogFilterProvider            - cartQuoteProvider
     - wishlistProvider                  - searchProvider                   - checkoutProvider
                                                                            - ordersProvider
```

---

## 2. Single Authoritative State Ownership (SASO)

Every business domain is governed by exactly one Notifier acting as the single authoritative writer. Cross-domain coordination occurs through explicit, unidirectional provider subscriptions or immutable event dispatching.

| Provider / Notifier | Implementation Class | State Model | Scope & Mutability |
| :--- | :--- | :--- | :--- |
| `authSessionProvider` | `AuthSessionNotifier` | `AuthSessionState` | App/Session boundary; authoritative manager of JWT, token storage, and session generation. |
| `cartProvider` | `CartNotifier` | `CartState` | Session-scoped; handles client-side cart items, local quantities, and immediate line-total projections. |
| `cartQuoteProvider` | `CartQuoteNotifier` | `AsyncValue<CartQuoteState>` | Server-authoritative quote; calculates discounts, delivery fees, and taxes via Laravel engine. |
| `checkoutProvider` | `CheckoutNotifier` | `CheckoutState` | Transaction-scoped; controls delivery address selection, payment method, wallet receipts, and idempotency. |
| `ordersProvider` | `OrdersNotifier` | `OrdersState` | Customer-isolated order history, pagination, and atomic cancellation. |
| `addressesProvider` | `AddressesNotifier` | `AddressesState` | Customer shipping addresses, primary address designation, and geographic coverage. |
| `wishlistProvider` | `WishlistNotifier` | `WishlistState` | Customer favorites, recently viewed items, and temporal browsing filters. |
| `appLocaleProvider` | `AppLocaleNotifier` | `Locale` | App-level persistent language selection (`ar-YE`, `en-US`). |
| `appThemeModeProvider` | `AppThemeModeNotifier` | `ThemeMode` | App-level persistent visual theme (`system`, `light`, `dark`). |

---

## 3. Account Boundary & Session Invalidation Mechanics

To eliminate cross-account data leakage (OWASP A01 / A04), all session-scoped providers implement a standardized lifecycle synchronization contract:

```dart
void syncWithSession({
  required String? userId,
  required int generation,
});
```

### Lifecycle Rules:
1. **Login Transition:** When `AuthSessionNotifier.startSession(...)` executes, `sessionGeneration` increments, and `_syncSessionScopedProviders` is invoked.
2. **Account Boundary Detection:**
   ```dart
   final isAccountBoundary = (state.activeUserId != userId) || (userId == null);
   ```
3. **State Cleansing:** If an account boundary is detected (switching users or logging out), the notifier immediately purges all customer data (cart items, quote cache, saved addresses, wishlist, order history, and active idempotency keys).
4. **Stale Network Protection:** Long-running asynchronous operations check `currentGen < state.sessionGeneration` upon completion; if the session changed while the network request was in-flight, the response is discarded silently without corrupting the active user's state.

---

## 4. UI Layer Consumption Patterns

All customer-facing views extend `ConsumerWidget` or `ConsumerStatefulWidget`. Obsolete `Obx()` and `GetBuilder()` wrappers have been replaced with reactive `ref.watch()` bindings:

```dart
// Example: Pure Riverpod Screen Consumption
class CartView extends ConsumerWidget {
  const CartView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final quoteAsync = ref.watch(cartQuoteProvider);

    return Scaffold(
      appBar: AppBar(title: Text(Tk.cartTitle.tr)),
      body: cartState.isEmpty
          ? const EmptyCartView()
          : CartContentList(
              items: cartState.items,
              quote: quoteAsync.value,
              onQuantityChanged: (item, qty) =>
                  ref.read(cartProvider.notifier).updateQuantity(item, qty),
            ),
    );
  }
}
```

---

## 5. Architectural Invariants Verified

- **Zero Global Singletons:** `Get.find()` and `Get.put()` are completely removed.
- **ProviderContainer Injection:** Pure dependency injection via Riverpod `ref` and `ProviderScope`.
- **Compile-Time Safety:** All state mutations are type-checked and immutable (`copyWith`).
- **Memory Leak Protection:** State is automatically disposed or cleanly recycled based on explicit provider auto-dispose annotations and session generation resets.

