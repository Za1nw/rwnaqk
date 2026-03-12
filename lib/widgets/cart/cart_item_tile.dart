import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_network_image.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

import '../../models/home_product_item.dart';
import '../common/quantity_stepper.dart';

/// ✅ Cart item card (same layout as WishlistItemTile)
/// - Image + delete
/// - Title + optional variant
/// - Price (small, always visible)
/// - QuantityStepper at the edge (instead of add-to-cart button)
class CartItemTile extends StatelessWidget {
  final HomeProductItem item;

  final int quantity;
  final String? variantText;

  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  final VoidCallback? onTap;

  // Layout
  final double imageSize;
  final double tileRadius;
  final double imageRadius;
  final EdgeInsetsDirectional contentPadding;

  const CartItemTile({
    super.key,
    required this.item,
    required this.quantity,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    this.variantText,
    this.onTap,
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
    final hasDiscount = item.hasDiscount;
    final salePrice = item.salePrice;
    final originalPrice = item.price;
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

                    // VARIANT
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

                    // ✅ PRICE (left) + STEPPER (right edge)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            runSpacing: 4,
                            children: [
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
                                  '\$${salePrice.toStringAsFixed(2)}',
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
                              if (hasDiscount)
                                Text(
                                  '\$${originalPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color: context.mutedForeground,
                                    fontWeight: FontWeight.w700,
                                    fontSize: isSmall ? 11 : 12,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        QuantityStepper(
                          value: quantity,
                          onIncrement: onIncrement,
                          onDecrement: onDecrement,
                          min: 1,
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
