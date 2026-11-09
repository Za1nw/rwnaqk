# Recommended feature-first structure (destination, not a mass rename)

```text
lib/
  app/
    bootstrap/                  # ProviderScope + existing GetMaterialApp bridge
    navigation/                 # Keep GetX router until a separate navigation gate
  core/
    network/                    # Pure Dio and API errors
    security/                   # IAuthTokenStorage + secure implementation
    config/                     # AppEnv + canonical endpoints
    di/                         # Shared dependency providers, temporary adapters
    theme/                      # Existing theme; migrate independently
    localization/               # Existing translations; migrate independently
    widgets/                    # Reusable UI
  features/
    auth/
      domain/                   # entities, repository interfaces
      data/                     # DTOs, repository implementations
      presentation/
        providers/              # Riverpod state + notifiers
        views/                  # ConsumerWidgets
        widgets/
    catalog/ ...
    cart/ ...
    checkout/ ...
    orders/ ...
```

During the migration, **do not rename the current `lib/modules/` tree en masse**. A migrated feature may temporarily live in `modules/<feature>/` with `presentation/providers` until imports and tests are stable. Move one module into the destination layout in its own reviewed commit, never during an unrelated state conversion.

## Explicit ownership

- `core/network/api_client.dart`: one HTTP client configuration; handles bearer token and typed errors; use existing working implementation.
- `core/constants/api_endpoints.dart` and `core/network/api_endpoints.dart`: **audit** duplicate-looking definitions; select one canonical owner only after checking all imports, then deprecate/remove the redundant file with full grep+tests.
- `core/bindings/initial_binding.dart`: legacy GetX composition root, do not delete while any GetX screen or service depends on it.
- `core/services/auth` and `core/services/geo`: audit for GetX usage. Prefer extracting pure interfaces/adapters and exposing them via providers. Do not simultaneously mutate or fork session state.
- `core/middleware/auth_middleware.dart`: GetX routing logic remains until navigation transition has its own route/redirect parity tests.
- `core/theme`, `core/translations`, `core/widgets`: their GetX dependencies can be bridged temporarily; changing state management does **not** require changing visual styles or all navigation.

## State example

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class IProductsRepository {
  Future<List<Product>> featured();
}

class Product {
  const Product(this.id, this.title);
  final int id;
  final String title;
}

final productsRepositoryProvider = Provider<IProductsRepository>((ref) {
  // The application bootstrap must provide an implementation.
  throw UnimplementedError('Provide IProductsRepository in bootstrap');
});

class FeaturedProductsNotifier extends AsyncNotifier<List<Product>> {
  @override
  Future<List<Product>> build() {
    return ref.watch(productsRepositoryProvider).featured();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(productsRepositoryProvider).featured(),
    );
  }
}

final featuredProductsProvider =
    AsyncNotifierProvider<FeaturedProductsNotifier, List<Product>>(
  FeaturedProductsNotifier.new,
);
```

This is conceptual standalone guidance, not a file ready to paste into this project without using its real model/repository definitions. For production code prefer real interfaces and error mapper, and account for automatic provider retries.

```dart
class FeaturedProductsView extends ConsumerWidget {
  const FeaturedProductsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(featuredProductsProvider);
    return products.when(
      data: (items) => items.isEmpty
          ? const Text('لا توجد منتجات')
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => Text(items[index].title),
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Text('تعذر تحميل المنتجات'),
    );
  }
}
```

Widget code also requires `material.dart` and `flutter_riverpod.dart` imports. Build code at the actual screen boundaries rather than copying this literally.
