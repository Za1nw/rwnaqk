import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_product_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/common/app_section_header.dart';
import 'package:rwnaqk/widgets/wishlist/wishlist_item_tile.dart';

class CartWishlistSection extends StatelessWidget {
  final ValueChanged<HomeProductItem> onAdd;
  final ValueChanged<HomeProductItem>? onTap;

  const CartWishlistSection({
    super.key,
    required this.onAdd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();

    return Obx(() {
      final items = wishlistController.wishlist.toList(growable: false);

      if (items.isEmpty) {
        return const SizedBox.shrink();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(
            title: Tk.cartFromWishlist.tr,
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
                variantText: AppProductUtils.variantText(item),
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
