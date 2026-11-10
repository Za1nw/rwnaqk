import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_action_icon_button.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/favorite_added_dialog.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_discount_ribbon.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';

class ProductCardImageSection extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final isFav = wishlist.isInWishlist(item.id);
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
                color: context.isDark
                    ? const Color(0xFF190C18)
                    : const Color(0xFFF7F1F5),
                child: Image.network(
                  imageUrl,
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
            child: AppActionIconButton(
              icon: isFav
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              onTap: () {
                final wasFav = wishlist.isInWishlist(item.id);
                ref.read(wishlistProvider.notifier).toggle(item);

                if (!wasFav) {
                  FavoriteAddedDialog.show(context);
                }
              },
              size: 32,
              iconSize: 16,
              backgroundColor: context.background.withValues(alpha: 0.92),
              iconColor: isFav
                  ? const Color(0xFFD32F2F)
                  : context.foreground.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
