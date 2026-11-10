# Product Details, Dynamic Variants & Pricing Calculations

## 1. Domain Modeling: `ProductDetailsState`

In `lib/modules/catalog/models/product_details_state.dart`, product details and multi-attribute variant selection are structured as an immutable domain model:

```dart
@immutable
class ProductDetailsState {
  final HomeProductItem? product;
  final bool isLoading;
  final String? errorMessage;
  final String selectedColorId;
  final String selectedSize;
  final Map<String, String> selectedAttributes;
  final List<ProductAttributeGroup> attributeGroups;
  final int selectedThumb;
  final int quantity;
  final String deliverySelected;
  final List<ProductReview> reviews;
  final List<HomeProductItem> mostPopular;
  final List<HomeProductItem> recommended;
  final bool isFavorite;
}
```

---

## 2. Dynamic Attribute Groups & Variant Selection

Products in Rawnaquk can feature arbitrary attribute groups (`color`, `size`, `style`, `material`). The state tracks both structured `attributeGroups` and a key-value selection map:

```dart
// lib/modules/catalog/providers/catalog_providers.dart
void selectAttribute(String groupId, String optionId) {
  final nextAttrs = Map<String, String>.from(state.selectedAttributes);
  nextAttrs[groupId] = optionId;

  String nextColor = state.selectedColorId;
  String nextSize = state.selectedSize;
  int nextThumb = state.selectedThumb;

  if (groupId == 'color') nextColor = optionId;
  if (groupId == 'size') nextSize = optionId;
  if (groupId == 'style') {
    final index = int.tryParse(optionId.replaceAll('style_', ''));
    if (index != null && index >= 0 && index < state.variationImages.length) {
      nextThumb = index;
    }
  }

  state = state.copyWith(
    selectedAttributes: nextAttrs,
    selectedColorId: nextColor,
    selectedSize: nextSize,
    selectedThumb: nextThumb,
  );
}
```

---

## 3. Pure Mathematical Calculations

The state model exposes purely calculated properties derived from base inputs, eliminating state desynchronization:

- **Discount Flag**: `hasDiscount => discount > 0`
- **Unit Price**: `hasDiscount ? (price * (1 - discount / 100)) : price`
- **Total Price**: `unitPrice * quantity`
- **Formatted Total**: `totalPrice.toStringAsFixed(2)`
- **Quantity Invariant**: `decrementQuantity()` strictly guards `quantity > 1`.
- **Options Summary**: Dynamically joins localized attribute labels (e.g., `أحمر • M • الموديل: 1`).

---

## 4. Family Scoping via `productDetailsFamily`

Product details notifiers are scoped by product ID using `NotifierProvider.family`:
```dart
final productDetailsFamily =
    NotifierProvider.family<ProductDetailsNotifier, ProductDetailsState, String>(
  (arg) => ProductDetailsNotifier(arg),
);
```
Each product ID maintains its own isolated state instance, allowing multiple product screens or bottom sheets to coexist without interfering with each other's variant selections or quantities.

