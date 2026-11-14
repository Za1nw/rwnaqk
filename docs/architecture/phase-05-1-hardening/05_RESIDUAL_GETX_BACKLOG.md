# Residual GetX Backlog & Migration Status

## 1. Module Migration Status Overview

| Phase | Module | Target Framework | Status | Gate Verdict |
|---|---|---|---|---|
| Phase 01 | Core & Network Bridge | Riverpod 3.5.0 + Dio | Completed | Passed |
| Phase 02 | Support Module | Riverpod 3.5.0 | Completed | Passed |
| Phase 03 | Onboarding & Wishlist | Riverpod 3.5.0 | Completed | Passed |
| Phase 04 | Auth & Session Management | Riverpod 3.5.0 | Completed | Passed |
| Phase 05 | Customer Addresses & Geo | Riverpod 3.5.0 | Completed | Passed |
| **Phase 05.1** | **Address & Session Hardening** | **Riverpod 3.5.0** | **Completed** | **Passed** |
| Phase 06 | Catalog, Search & Categories | Riverpod 3.5.0 | Ready for Execution | Pending |
| Phase 07 | Cart & Pricing Quote | Riverpod 3.5.0 | Scheduled | Pending |
| Phase 08 | Checkout & Orders | Riverpod 3.5.0 | Scheduled | Pending |
| Phase 09 | Routing, Localization & Polish | Riverpod 3.5.0 / GoRouter | Scheduled | Pending |

---

## 2. Active Legacy GetX Controllers & Compatibility Inventory

The following legacy controllers remain active in the repository and are safely bridged:

1. **`CartController` & `CartUiController`** (`lib/modules/cart/`):
   - Retained on GetX for checkout stability until Phase 07.
   - Guarded by aggressive cache fencing in `AuthSessionNotifier._purgeLegacyGetXStores()`.
2. **`OrdersController` & `OrdersUiController`** (`lib/modules/orders/`):
   - Retained on GetX until Phase 08.
   - Memory collection forced wipe in `_purgeLegacyGetXStores()`.
3. **`ProfileStoreService`** (`lib/modules/customer/`):
   - Serves as a read-only projection facade for `addresses` via `ReadOnlyRxList`.
   - Direct mutations prohibited; sync driven exclusively by Riverpod 3.5.0.
4. **`AddressesController` & `AddressesService`** (`lib/modules/customer/`):
   - `AddressesService` acts as a Single-Writer delegation facade routing all CRUD actions to `AddressesNotifier`.
   - UI views in `AddressesScreen` still utilize GetView/GetBuilder/Obx during transition, fully compatible with the Riverpod single-writer store.

---

## 3. Residual Technical Debt & Future Removal Milestones

| Component / Artifact | Current Role | Scheduled Phase for Full Removal |
|---|---|---|
| `ReadOnlyRxList` | Protects legacy GetX views from mutating Riverpod state | Phase 08/09 (When all views use `ConsumerWidget`) |
| `AddressesService` (Facade) | Bridges legacy GetX calls to Riverpod notifier | Phase 08 (When checkout directly reads `addressesProvider`) |
| `_purgeLegacyGetXStores()` | Purges GetX controllers on logout/401 | Phase 08 (Post-Orders & Cart migration) |
| `Get.toNamed` / GetX Routing | App-wide navigation | Phase 09 |

