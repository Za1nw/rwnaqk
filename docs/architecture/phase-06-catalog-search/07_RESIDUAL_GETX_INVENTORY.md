# Residual GetX Inventory & Migration Path

## 1. Inventory of Active GetX Controllers

Following the completion of Phase 06, the state management status across the codebase is:

| Module | Legacy Controller | Current Role | Target Phase for Pure Riverpod Views |
|---|---|---|---|
| **Catalog Listing** | `ProductsListingController` | Single-Writer Delegation Facade to `productsListingProvider` | Phase 09 (Full Router Migration) |
| **Product Details** | `ProductDetailsController` | Single-Writer Delegation Facade to `productDetailsFamily` | Phase 09 |
| **Search** | `AppSearchController` | Single-Writer Delegation Facade to `productSearchProvider` | Phase 09 |
| **Flash Sale** | `FlashSaleController` | Local timer countdown & discount filtering | Phase 09 |
| **Reviews** | `ReviewsController` | Local review listing | Phase 09 |
| **Customer Addresses** | `AddressesController` | Delegation facade to `AddressesNotifier` | Phase 08 |
| **Customer Profile** | `ProfileStoreService` | Read-only projection via `ReadOnlyRxList` | Phase 08 |
| **Cart & Pricing Quote** | `CartController` | **Active Core State** (To be migrated in Phase 07) | **Phase 07** |
| **Checkout & Orders** | `OrdersController`, `PaymentController` | **Active Core State** (To be migrated in Phase 08) | **Phase 08** |
| **Navigation & Routing** | GetX Pages & Bindings | Global application routing | **Phase 09** |

---

## 2. Decoupling & Portability Status

- **Business Logic Portability**: All business logic for catalog listing, pagination, filters, sorting, product details, dynamic attributes, and search now resides purely in Riverpod notifiers and pure models in `lib/modules/catalog/` and `lib/modules/search/`.
- **Pure Interfaces**: `IProductsRepository` is completely independent of Flutter or GetX, using only Dio `CancelToken` and standard Dart types.
- **Transitional Facades**: Legacy controllers now act strictly as thin adapters translating GetX widget calls into Riverpod notifier method calls. When GetX navigation is replaced in Phase 09 with GoRouter, these controllers can be deleted without modifying business logic.

