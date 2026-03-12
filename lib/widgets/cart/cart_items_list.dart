import 'package:flutter/material.dart';
import '../../models/home_product_item.dart';
import 'cart_item_tile.dart';

class CartItemsList extends StatelessWidget {
  final List<HomeProductItem> items;
  final Function(String id) onRemove;

  const CartItemsList({
    super.key,
    required this.items,
    required this.onRemove,
  });

  String? _variantText(HomeProductItem item) {
    final parts = <String>[];

    if (item.availableColors.isNotEmpty) {
      final colorName = item.availableColors.first.name.trim();
      if (colorName.isNotEmpty) parts.add(colorName);
    }

    if (item.availableSizes.isNotEmpty) {
      final size = item.availableSizes.first.trim();
      if (size.isNotEmpty) parts.add(size);
    }

    if (parts.isEmpty) return null;
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final item = items[i];

        return CartItemTile(
          item: item,
          quantity: 1,
          variantText: _variantText(item),
          onIncrement: () {},
          onDecrement: () {},
          onRemove: () => onRemove(item.id),
        );
      },
    );
  }
}