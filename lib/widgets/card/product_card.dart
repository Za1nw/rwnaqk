import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';
import '../../models/home_product_item.dart';
import 'product_card_image_section.dart';
import 'product_rating_badge.dart';

class ProductCard extends StatelessWidget {
  final HomeProductItem item;
  final ValueChanged<HomeProductItem> onTap;
  final double radius;
  final bool showAddToCart;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.item,
    required this.onTap,
    this.radius = 22,
    this.showAddToCart = true,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = (item.discountPercent ?? 0) > 0;
    final originalPrice = item.price;
    final discountedPrice = hasDiscount
        ? originalPrice * (1 - (item.discountPercent! / 100))
        : originalPrice;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;

        final titleSize = w < 165 ? 13.0 : 14.5;
        final subtitleSize = w < 165 ? 9.8 : 10.8;
        final priceSize = w < 165 ? 12.5 : 13.8;
        final oldPriceSize = w < 165 ? 9.5 : 10.5;
        final ratingSize = w < 165 ? 9.8 : 10.8;
        final cardPadding = w < 165 ? 8.0 : 10.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: () => onTap(item),
            child: Container(
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: context.border.withOpacity(.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.shadow.withOpacity(.08),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductCardImageSection(
                    item: item,
                    imageUrl: item.imageUrl,
                    radius: radius,
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      cardPadding,
                      8,
                      cardPadding,
                      10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w800,
                                  color: context.foreground,
                                  height: 1.1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            ProductRatingBadge(fontSize: ratingSize),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Men Slim Fit Opaque Casual Shirt',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            fontWeight: FontWeight.w500,
                            color: context.mutedForeground,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  _PriceBadge(
                                    text: '₹${discountedPrice.toStringAsFixed(0)}',
                                    fontSize: priceSize,
                                  ),
                                  if (hasDiscount)
                                    Text(
                                      '₹${originalPrice.toStringAsFixed(0)}',
                                      style: TextStyle(
                                        fontSize: oldPriceSize,
                                        fontWeight: FontWeight.w700,
                                        color: context.mutedForeground,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            if (showAddToCart) ...[
                              const SizedBox(width: 8),
                              AppActionIconButton(
                                icon: Icons.shopping_cart_outlined,
                                onTap: onAddToCart,
                                size: 30,
                                iconSize: 15,
                                backgroundColor:
                                    context.primary.withOpacity(.10),
                                iconColor: context.primary,
                                borderColor: context.primary.withOpacity(.14),
                              ),
                            ],
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
      },
    );
  }
}

class _PriceBadge extends StatelessWidget {
  final String text;
  final double fontSize;

  const _PriceBadge({
    required this.text,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: context.primary.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: context.primary.withOpacity(.12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: context.primary,
          height: 1,
        ),
      ),
    );
  }
}