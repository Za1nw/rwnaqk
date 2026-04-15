import 'package:flutter/material.dart';
import 'package:rwnaqk/core/utils/app_product_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/cart/cart_item_tile.dart';

class CartItemsList extends StatelessWidget {
  final List<HomeProductItem> items;
  final Map<String, int> quantities;
  final Map<String, String> variantTexts;
  final Map<String, double> ratings;
  final Map<String, int> reviewsCounts;
  final Function(String id) onRemove;
  final Function(String id) onIncrement;
  final Function(String id) onDecrement;

  const CartItemsList({
    super.key,
    required this.items,
    required this.quantities,
    this.variantTexts = const {},
    this.ratings = const {},
    this.reviewsCounts = const {},
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final item = items[i];
        final variant =
            variantTexts[item.id] ?? AppProductUtils.variantText(item);

        return CartItemTile(
          item: item,
          quantity: quantities[item.id] ?? 1,
          variantText: variant,
          rating: ratings[item.id],
          reviewsCount: reviewsCounts[item.id],
          onIncrement: () => onIncrement(item.id),
          onDecrement: () => onDecrement(item.id),
          onRemove: () => onRemove(item.id),
        );
      },
    );
  }
}
