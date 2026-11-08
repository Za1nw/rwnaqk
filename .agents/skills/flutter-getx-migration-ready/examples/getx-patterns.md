# GetX cookbook — implementation patterns and safe choices

## `Obx` reactive list

```dart
class ItemsController extends GetxController {
  final names = <String>[].obs;
  void replaceAll(List<String> value) => names.assignAll(value);
  void add(String value) => names.add(value);
}

Obx(() => Text('${controller.names.length} items'));
```

`Obx` subscribes when it *reads* `names.length` inside its builder. Do not expect it to subscribe if you read a non-reactive snapshot outside and only use that snapshot inside.

## Nested object mutation pitfall

When storing ordinary mutable objects inside an Rx list, a mutation to an object's field may not notify:

```dart
// Potentially silent, depending on the model and observation pattern:
// controller.products[0].quantity++;

// Preferred: immutable model replacement (model needs copyWith):
controller.products[0] = controller.products[0].copyWith(quantity: 2);
```

Use `refresh()` only when replacing the object is impractical and you can explain the side effects. Do not use it after `assignAll()`; that method already notifies observers.

## `GetBuilder` manual update

```dart
class SelectionController extends GetxController {
  int selectedIndex = 0;

  void select(int index) {
    selectedIndex = index;
    update(['selection']);
  }
}

// Assumes SelectionController is registered in route Binding.
GetBuilder<SelectionController>(
  id: 'selection',
  builder: (c) => Text('Selected: ${c.selectedIndex}'),
);
```

Unlike `Obx`, changing a plain field requires `update()` / `update([id])`. Avoid mixing both modes on the same widget without demonstrated need.

## App-wide dependencies versus route dependencies

```dart
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // These are examples. Configure Dio securely and choose lifecycle deliberately.
    Get.put<Dio>(configuredDio, permanent: true);
  }
}

class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsController>(
      () => ProductsController(Get.find<ProductRepository>()),
    );
  }
}
```

The snippet presumes `configuredDio` and `ProductRepository` are provided by real project code. The app-wide binding, feature binding, registration owner and `SmartManagement` must be designed together. Do not mark *all* controllers `permanent`. Do not use `fenix` as a persistence mechanism for cart contents.

## Resource cleanup

```dart
class QueryController extends GetxController {
  final query = ''.obs;
  Worker? _worker;

  @override
  void onInit() {
    super.onInit();
    _worker = debounce<String>(query, (_) => loadResults());
  }

  void loadResults() {
    // Delegate to injected repository; do not call raw Dio here.
  }

  @override
  void onClose() {
    _worker?.dispose();
    super.onClose();
  }
}
```

For an async search, additionally guard out-of-order requests and requests completing after disposal, as shown in `getx-official.md` and `catalog-feature.md`.
