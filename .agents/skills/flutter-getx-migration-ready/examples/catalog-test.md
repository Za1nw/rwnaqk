# Real unit-test pattern: GetX controller with a fake repository

Assumes the `Product`, `ProductRepository`, and `ProductsController` from [catalog-feature.md](catalog-feature.md) have been placed in a Flutter project. Replace `your_app` with the real package name from `pubspec.yaml`. This example tests the controller without contacting Laravel and without registering global GetX dependencies.

`test/features/catalog/products_controller_test.dart`

```dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/features/catalog/domain/product.dart';
import 'package:your_app/features/catalog/domain/product_repository.dart';
import 'package:your_app/features/catalog/presentation/controllers/products_controller.dart';

class FakeProducts implements ProductRepository {
  FakeProducts(this.fetch);
  final Future<List<Product>> Function() fetch;

  @override
  Future<List<Product>> fetchProducts() => fetch();
}

void main() {
  test('loads products from repository', () async {
    final controller = ProductsController(
      FakeProducts(() async => [const Product(id: 1, name: 'Shelf')]),
    );
    await controller.loadProducts();
    expect(controller.isLoading.value, false);
    expect(controller.errorMessage.value, isNull);
    expect(controller.products.single.name, 'Shelf');
    controller.onClose();
  });

  test('maps repository error to UI error state', () async {
    final controller = ProductsController(
      FakeProducts(() async => throw Exception('offline')),
    );
    await controller.loadProducts();
    expect(controller.isLoading.value, false);
    expect(controller.errorMessage.value, isNotNull);
    controller.onClose();
  });

  test('stale response cannot overwrite newer response', () async {
    final first = Completer<List<Product>>();
    final second = Completer<List<Product>>();
    var calls = 0;
    final controller = ProductsController(FakeProducts(() {
      calls++;
      return calls == 1 ? first.future : second.future;
    }));

    final oldRequest = controller.loadProducts();
    final newRequest = controller.loadProducts();
    second.complete([const Product(id: 2, name: 'New')]);
    await newRequest;
    first.complete([const Product(id: 1, name: 'Old')]);
    await oldRequest;

    expect(controller.products.single.name, 'New');
    expect(controller.isLoading.value, false);
    controller.onClose();
  });

  test('closed controller ignores late response', () async {
    final pending = Completer<List<Product>>();
    final controller = ProductsController(FakeProducts(() => pending.future));
    final future = controller.loadProducts();
    controller.onClose();
    pending.complete([const Product(id: 1, name: 'Late')]);
    await future;
    expect(controller.products, isEmpty);
  });
}
```

If testing route Bindings/navigation instead of direct constructor injection, configure GetX test DI in `setUp`, call `Get.reset()` in `tearDown`, and use `Get.testMode = true` when exercising contextless navigation in tests. Do not assume automatic `onInit` on directly constructed controllers; call the command explicitly as shown.

Recommended additional tests: `GetBuilder` requires `update()`, correct `Obx` reactive reads, `RxList` nested object updates, auth expiry, cart/session invalidation, price/stock conflict, duplicate checkout and backend idempotency.
