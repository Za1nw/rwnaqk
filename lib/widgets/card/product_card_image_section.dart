import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';
import 'package:rwnaqk/widgets/dialogs/favorite_added_dialog.dart';
import '../../models/home_product_item.dart';
import 'product_discount_ribbon.dart';

class ProductCardImageSection extends StatelessWidget {
  final HomeProductItem item;
  final String imageUrl;
  final double radius;

  const ProductCardImageSection({
    super.key,
    required this.item,
    required this.imageUrl,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WishlistController>();
    final hasDiscount = (item.discountPercent ?? 0) > 0;

    return AspectRatio(
      aspectRatio: 1.02,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
              ),
              child: Container(
                color: context.input,
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      color: context.input,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: context.mutedForeground,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          if (hasDiscount)
            Positioned(
              top: 12,
              left: -10,
              child: ProductDiscountRibbon(
                text: '${item.discountPercent}% OFF',
              ),
            ),

          Positioned(
            top: 8,
            right: 8,
            child: Obx(() {
              final isFav = controller.isInWishlist(item.id);

              return AppActionIconButton(
                icon: isFav
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                onTap: () {
                  final wasFav = controller.isInWishlist(item.id);
                  controller.toggleWishlist(item);

                  if (!wasFav) {
                    FavoriteAddedDialog.show(context);
                  }
                },
                size: 30,
                iconSize: 15,
                backgroundColor: context.background.withOpacity(.78),
                borderColor: context.border.withOpacity(.45),
                iconColor:
                    isFav ? context.destructive : context.mutedForeground,
              );
            }),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Container(
                  width: index == 0 ? 6 : 5,
                  height: index == 0 ? 6 : 5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? Colors.white
                        : Colors.white.withOpacity(.38),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}