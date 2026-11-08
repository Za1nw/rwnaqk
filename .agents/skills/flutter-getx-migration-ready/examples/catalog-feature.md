# Worked example: catalog connected to Laravel, portable data layer

**Illustrative feature** — not a patch to the actual app. Match installed `get` and Dio versions, real backend JSON, project conventions and app-specific imports. All endpoints below are hypothetical; do not assume `/products` is live.

## 1. Domain — plain Dart

`lib/features/catalog/domain/product.dart`

```dart
class Product {
  const Product({required this.id, required this.name});
  final int id;
  final String name;
}
```

`lib/features/catalog/domain/product_repository.dart`

```dart
import 'product.dart';

abstract class ProductRepository {
  Future<List<Product>> fetchProducts();
}
```

## 2. Data — Dio, no GetX

`lib/features/catalog/data/laravel_product_repository.dart`

```dart
import 'package:dio/dio.dart';
import '../domain/product.dart';
import '../domain/product_repository.dart';

class LaravelProductRepository implements ProductRepository {
  LaravelProductRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Product>> fetchProducts() async {
    // EXAMPLE contract: GET /products -> {"data": [{"id": 1, "name": "..."}]}.
    // Validate actual Laravel response, auth and pagination first.
    final response = await _dio.get<Map<String, dynamic>>('/products');
    final payload = response.data;
    if (payload == null || payload['data'] is! List) {
      throw const FormatException('Unexpected products response');
    }
    return (payload['data'] as List<dynamic>).map((row) {
      if (row is! Map<String, dynamic> ||
          row['id'] is! int || row['name'] is! String) {
        throw const FormatException('Invalid product object');
      }
      return Product(id: row['id'] as int, name: row['name'] as String);
    }).toList(growable: false);
  }
}
```

In actual code, use the shared Dio instance and error normalization (e.g. 401/422/429), rather than constructing clients per request. If the API is paginated, return a typed `Page<Product>` with page metadata instead of silently discarding it.

## 3. GetX adapter — async-safe and injectable

`lib/features/catalog/presentation/controllers/products_controller.dart`

```dart
import 'package:get/get.dart';
import '../../domain/product.dart';
import '../../domain/product_repository.dart';

class ProductsController extends GetxController {
  ProductsController(this._repository);
  final ProductRepository _repository;

  final products = <Product>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  bool _disposed = false;
  int _requestId = 0;

  @override
  void onInit() {
    super.onInit();
    loadProducts(); // fire-and-forget onInit; errors are handled inside.
  }

  Future<void> loadProducts() async {
    if (_disposed) return;
    final request = ++_requestId;
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await _repository.fetchProducts();
      if (_disposed || request != _requestId) return;
      products.assignAll(result);
    } catch (_) {
      if (_disposed || request != _requestId) return;
      errorMessage.value = 'Could not load products. Try again.';
    } finally {
      if (!_disposed && request == _requestId) {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    _disposed = true;
    _requestId++; // invalidate in-flight result
    super.onClose();
  }
}
```

Here `requestId` implements last-request-wins and guards results after disposal. For a real catalog implement Dio `CancelToken` ownership if useful, and distinguish user-facing errors from diagnostic logs. **Do not** use this guard alone to protect non-idempotent checkout: Laravel must enforce idempotency.

## 4. Bindings — GetX only at composition

`lib/features/catalog/bindings/catalog_binding.dart`

```dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../data/laravel_product_repository.dart';
import '../domain/product_repository.dart';
import '../presentation/controllers/products_controller.dart';

class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    // Requires app-wide configured Dio already registered in initialBinding.
    Get.lazyPut<ProductRepository>(
      () => LaravelProductRepository(Get.find<Dio>()),
    );
    Get.lazyPut<ProductsController>(
      () => ProductsController(Get.find<ProductRepository>()),
    );
  }
}
```

Register the binding in the existing `GetPage` for the route. Do not move all app registrations or change SmartManagement globally for this example.

## 5. Existing GetX view can remain

`lib/features/catalog/presentation/pages/products_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/products_controller.dart';

class ProductsPage extends StatelessWidget {
  const ProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductsController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return Center(
            child: TextButton(
              onPressed: controller.loadProducts,
              child: const Text('Retry loading products'),
            ),
          );
        }
        final items = controller.products;
        if (items.isEmpty) {
          return const Center(child: Text('No products'));
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, index) => ListTile(title: Text(items[index].name)),
        );
      }),
    );
  }
}
```

GetX still lives in the view/controller. **Later migration replaces their reactive wiring**, not the pure model, contract, or Dio implementation. For reusable product tiles, prefer passing `Product` and callbacks rather than a controller.

For complete pure/controller tests, read [catalog-test.md](catalog-test.md).
