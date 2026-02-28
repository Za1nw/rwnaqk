import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/wishlist/wishlist_item_tile.dart';

import '../../models/home_product_item.dart';

class CartWishlistSection extends StatelessWidget {
  final List<HomeProductItem> items;

  /// Called when user taps "Add to cart" for an item from wishlist section.
  final ValueChanged<HomeProductItem> onAdd;

  /// Optional: remove from wishlist
  final ValueChanged<HomeProductItem>? onRemove;

  const CartWishlistSection({
    super.key,
    required this.items,
    required this.onAdd,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "From Your Wishlist",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: context.foreground,
          ),
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final item = items[i];

            return WishlistItemTile(
              item: HomeProductItem(
                id: "p1",
                title: "Apple AirPods Pro (2nd Gen)",
                imageUrl: "https://picsum.photos/300",
                price: 49.99,
              ),

              variantText: "Black • Size M",

              onTap: () {
                debugPrint("open details");
              },

              onRemove: () {
                debugPrint("removed from wishlist");
              },

              onAddToCart: () {
                debugPrint("added to cart");
              },
            );
          },
        ),
      ],
    );
  }
}
