---
trigger: model_decision
description: "Use when adding or modifying a Flutter feature, class, component, controller, repository, service, or modular project structure."
---
# Feature work: conservative, feature-first architecture

1. Before creating folders, inspect existing conventions and reuse the current feature location. **Do not force a global tree migration** for a nearly complete storefront.
2. For a feature involving network data, target this dependency flow:

   `Page/Widget → GetX Controller (presentation) → repository interface (pure Dart) → repository implementation → Dio client → Laravel API`.

3. If needed for complex cross-repository business rules, add a **pure Dart** domain service/use-case. Do not create a use-case for straightforward CRUD.
4. Presentation controllers own `isLoading`, view state, form errors, request orchestration, retry and presentation-only mapping. Repositories own data retrieval, caching policies, API mapping and errors in plain Dart types. DTOs are not UI state.
5. Avoid business logic in widget `build()`, navigation middleware, custom painters or API client interceptors.
6. Shared reusable widgets expose value/callback parameters where practical; keep business policy in separate testable code. Avoid invoking controllers from deeply nested reusable widgets unless the existing architecture requires it.
7. Use descriptive Dart filenames (`product_repository.dart`, `cart_controller.dart`), null safety, bounded types, `final`/`const` where appropriate, and explicit ownership of disposable objects.
8. Do not add broad abstractions for a single use; prefer the smallest interface that protects the API/business layer from GetX.
9. If adding a shared abstraction, document its responsibility and a short usage example near the feature or in existing project docs, **only when it is genuinely reused or not obvious**.
10. Preserve the user's existing localization/theming implementation; don't introduce a second i18n or theme solution.

## Example of a portable boundary (illustrative, adapt names)
```dart
// Pure Dart: no GetX or Flutter import.
abstract interface class ProductRepository {
  Future<List<Product>> fetchProducts();
}

// GetX is only an adapter in presentation.
class ProductsController extends GetxController {
  ProductsController(this.repository);
  final ProductRepository repository;
  final products = <Product>[].obs;

  Future<void> load() async {
    final items = await repository.fetchProducts();
    if (isClosed) return;
    products.assignAll(items);
  }
}
```

Handle exceptions/loading/request races according to the feature; this snippet intentionally demonstrates only the boundary.
