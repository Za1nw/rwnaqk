# Wishlist & Cart Interoperability Architecture

## 1. Context and Modernization Goal

During the transitional modernization program, state management is migrated module by module:
- **Phase 03**: `WishlistNotifier` migrated to Riverpod 3.5.0.
- **Phase 06**: Catalog, Search & Product Details migrated to Riverpod 3.5.0.
- **Phase 07**: Cart & Server-Side Pricing Quote scheduled for Riverpod 3.5.0.
- **Phase 08**: Checkout & Orders scheduled for Riverpod 3.5.0.

Because `CartController` is scheduled for Phase 07, `ProductDetailsNotifier` must support:
1. **Direct Riverpod Wishlist Synchronization**: Toggling favorites updates `wishlistProvider` directly without invoking GetX controllers.
2. **Safe Cart Interoperability**: "Add to Cart" and "Buy Now" dispatch structured product payloads and variant strings to `CartController` safely.

---

## 2. Direct Riverpod Wishlist Integration

In `ProductDetailsNotifier`:
```dart
void toggleFavorite([BuildContext? context]) {
  final current = state.product;
  if (current == null) return;

  final wasFavorite = state.isFavorite;
  
  // Single Authoritative State Mutation in Riverpod
  ref.read(wishlistProvider.notifier).toggleWishlist(current);

  final nowFavorite = ref.read(wishlistProvider).isInWishlist(current.id);
  state = state.copyWith(isFavorite: nowFavorite);

  if (!wasFavorite && nowFavorite && context != null) {
    FavoriteAddedDialog.show(context);
  }
}
```
When `ProductDetailsScreen` initializes, its state automatically queries `ref.watch(wishlistProvider).isInWishlist(arg)`. Any wishlist addition made anywhere in the application reactively reflects on the product page.

---

## 3. Cart Dispatch Facade (`addToCart`)

When the customer adds a product with specific options to the cart:
```dart
void addToCart([BuildContext? context]) {
  final current = state.product;
  if (current == null) return;

  if (Get.isRegistered<CartController>()) {
    final cart = Get.find<CartController>();
    final variant = AppProductUtils.joinInline(state.selectedOptionChips);
    cart.addToCart(
      current,
      quantity: state.quantity,
      variantText: variant.trim().isEmpty ? null : variant,
      rating: state.hasReviews ? state.averageRating : null,
      reviewsCount: state.hasReviews ? state.reviewsCount : null,
    );
  }

  if (context != null) {
    CartAddedDialog.show(context);
  }
}
```

### Safety Attributes:
- **Line Item Isolation**: `CartController` builds unique line-item keys based on `id` + `variantText` (e.g. `prod_0_أحمر - S`), preventing different variants of the same product from colliding in the cart.
- **Graceful Degradation**: If `CartController` is not registered (e.g. during standalone testing), the call returns cleanly without throwing runtime exceptions.

---

## 4. Interaction Diagram

```mermaid
sequenceDiagram
    autonumber
    actor User as Customer
    participant Details as ProductDetailsNotifier (Riverpod)
    participant Wishlist as WishlistNotifier (Riverpod)
    participant Cart as CartController (Legacy GetX)

    User->>Details: toggleFavorite()
    Details->>Wishlist: toggleWishlist(product)
    Wishlist-->>Details: Updated state (inWishlist = true)
    Details-->>User: Heart icon animates to active

    User->>Details: addToCart()
    Details->>Cart: addToCart(product, quantity: 2, variant: "أحمر - M")
    Cart->>Cart: cartItems.add(lineItem), quantities['prod_0_أحمر - M'] = 2
    Details-->>User: CartAddedDialog displayed
```

