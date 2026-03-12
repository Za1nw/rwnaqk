import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/wishlist/wishlist_item_tile.dart';

import '../../models/home_product_item.dart';

class CartWishlistSection extends StatelessWidget {
  /// Called when user taps add to cart from wishlist section.
  final ValueChanged<HomeProductItem> onAdd;

  /// Optional open product details
  final ValueChanged<HomeProductItem>? onTap;

  const CartWishlistSection({
    super.key,
    required this.onAdd,
    this.onTap,
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
    final wishlistController = Get.find<WishlistController>();

    return Obx(() {
      final items = wishlistController.wishlist.toList(growable: false);

      if (items.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSectionHeader(
            title: 'From Your Wishlist',
            titleFontSize: 16,
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
                item: item,
                variantText: _variantText(item),
                onTap: () {
                  if (onTap != null) {
                    onTap!(item);
                  } else {
                    wishlistController.openProduct(item);
                  }
                },
                onRemove: () => wishlistController.removeFromWishlist(item.id),
                onAddToCart: () => onAdd(item),
              );
            },
          ),
        ],
      );
    });
  }
}