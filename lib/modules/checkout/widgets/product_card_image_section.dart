import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_action_icon_button.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/favorite_added_dialog.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

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
      aspectRatio: 1.05,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Image with Luxury Fallback
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(radius),
                topRight: Radius.circular(radius),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      context.primary.withValues(alpha: 0.08),
                      context.card,
                    ],
                  ),
                ),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.primary.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, _, _) {
                    return Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: context.primary.withValues(alpha: 0.06),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          color: context.primary.withValues(alpha: 0.45),
                          size: 32,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Discount Badge (Direction-Safe Top-Start)
          if (hasDiscount)
            PositionedDirectional(
              top: 8,
              start: 8,
              child: ProductDiscountRibbon(text: '-${item.discountPercent}%'),
            ),

          // Wishlist Action Button (Direction-Safe Top-End)
          PositionedDirectional(
            top: 8,
            end: 8,
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
                size: 32,
                iconSize: 16,
                backgroundColor: context.background.withValues(alpha: 0.92),
                borderColor: context.border.withValues(alpha: 0.25),
                iconColor: isFav
                    ? context.destructive
                    : context.mutedForeground,
              );
            }),
          ),
        ],
      ),
    );
  }
}
