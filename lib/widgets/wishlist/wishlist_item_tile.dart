import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_network_image.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';
import '../../models/home_product_item.dart';

/// ✅ Wishlist card (similar to cart card)
/// - Image + delete
/// - Title + optional variant
/// - Price
/// - Add-to-cart icon button (instead of stepper)
class WishlistItemTile extends StatelessWidget {
  final HomeProductItem item;

  /// open product details
  final VoidCallback? onTap;

  /// remove from wishlist
  final VoidCallback onRemove;

  /// add item to cart
  final VoidCallback onAddToCart;

  /// optional variant line
  final String? variantText;

  // Layout
  final double imageSize;
  final double tileRadius;
  final double imageRadius;
  final EdgeInsetsDirectional contentPadding;

  const WishlistItemTile({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onAddToCart,
    this.onTap,
    this.variantText,
    this.imageSize = 90,
    this.tileRadius = 18,
    this.imageRadius = 14,
    this.contentPadding = const EdgeInsetsDirectional.all(10),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(tileRadius);
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;

    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.border.withOpacity(.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: context.primary.withOpacity(0.05),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: contentPadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageWithDelete(
                imageUrl: item.imageUrl,
                size: imageSize,
                radius: imageRadius,
                onRemove: onRemove,
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TITLE
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: isSmall ? 13 : 14.5,
                        height: 1.2,
                        letterSpacing: 0.1,
                      ),
                    ),

                    // VARIANT (مرة واحدة فقط)
                    if (variantText != null &&
                        variantText!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.mutedForeground.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          variantText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.mutedForeground,
                            fontWeight: FontWeight.w700,
                            fontSize: isSmall ? 10.5 : 11.5,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 10),

                    // PRICE + ADD TO CART ICON (الزر في طرف الكرت)
                    Row(
                      children: [
                        // PRICE
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: context.primary.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${item.price.toStringAsFixed(2)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: isSmall ? 13.5 : 15,
                              height: 1.0,
                            ),
                          ),
                        ),

                        const Spacer(),

                        AppActionIconButton(
                          icon: Icons.shopping_cart_outlined,
                          onTap: onAddToCart,
                          size: isSmall ? 40 : 44,
                          iconSize: isSmall ? 18 : 20,
                          radius: 14,

                          // اختياري: لو تبغاه يطلع "برايمري" مثل زرّك القديم:
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageWithDelete extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double radius;
  final VoidCallback onRemove;

  const _ImageWithDelete({
    required this.imageUrl,
    required this.size,
    required this.radius,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: size,
            height: size,
            child: AppNetworkImage(url: imageUrl, fit: BoxFit.cover),
          ),
        ),
        PositionedDirectional(
          top: -6,
          end: -6,
          child: AppActionIconButton(
            icon: Icons.delete_outline_rounded,
            iconColor: context.destructive,
            onTap: onRemove,

            size: 30,
            iconSize: 25,
            radius: 99,
            borderColor: context.background,
            backgroundColor: context.destructive.withOpacity(.5),
            // iconColor = أبيض افتراضياً
          ),
        ),
      ],
    );
  }
}
