import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_action_icon_button.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/cart_added_dialog.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

import 'product_card_image_section.dart';

class ProductCard extends ConsumerWidget {
  final HomeProductItem item;
  final ValueChanged<HomeProductItem> onTap;
  final double radius;
  final bool showAddToCart;

  const ProductCard({
    super.key,
    required this.item,
    required this.onTap,
    this.radius = 16,
    this.showAddToCart = true,
  });

  void _addToCart(BuildContext context, WidgetRef ref) {
    ref.read(cartProvider.notifier).addToCart(item);
    CartAddedDialog.show(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDiscount = (item.discountPercent ?? 0) > 0;
    final originalPrice = item.price;
    final discountedPrice = hasDiscount
        ? originalPrice * (1 - (item.discountPercent! / 100))
        : originalPrice;

    final brandName = item.brand.trim().isNotEmpty
        ? item.brand.tr
        : (item.material != null && item.material!.trim().isNotEmpty
              ? item.material!.tr
              : '');

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final isBounded = c.hasBoundedHeight;

        final titleSize = w < 165 ? 12.0 : 13.0;
        final brandSize = w < 165 ? 9.5 : 10.5;
        final priceSize = w < 165 ? 12.5 : 13.5;
        final oldPriceSize = w < 165 ? 9.5 : 10.0;
        final cardPadding = w < 165 ? 8.0 : 10.0;
        final titleMaxLines = w < 155 ? 2 : 3;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: () => onTap(item),
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xFF24111F)
                    : Colors.white,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: context.isDark
                      ? BrandColors.gold.withValues(alpha: 0.18)
                      : const Color(0xFFEBE0E6),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: context.isDark ? 0.25 : 0.04,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image Section (with Discount ribbon & Wishlist button)
                  ProductCardImageSection(
                    item: item,
                    imageUrl: item.imageUrl,
                    radius: radius,
                  ),

                  // 2. Info Section (Brand, Title, Price, Add to Cart)
                  if (isBounded)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          cardPadding,
                          6,
                          cardPadding,
                          8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand Name (Direction-Safe start aligned)
                            if (brandName.isNotEmpty) ...[
                              Text(
                                brandName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.isDark
                                      ? BrandColors.gold
                                      : BrandColors.burgundy,
                                  fontWeight: FontWeight.w700,
                                  fontSize: brandSize,
                                  fontFamily: 'Cairo',
                                  letterSpacing: 0.2,
                                  height: 1.1,
                                ),
                              ),
                              const SizedBox(height: 2),
                            ],

                            // Product Title (Flexibly fills the middle space without overflowing)
                            Expanded(
                              child: Text(
                                item.title.tr,
                                maxLines: titleMaxLines,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.isDark
                                      ? Colors.white
                                      : const Color(0xFF1E0A17),
                                  fontWeight: FontWeight.w800,
                                  fontSize: titleSize,
                                  fontFamily: 'Cairo',
                                  height: 1.25,
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Price & Action Button Row (Pinned at bottom)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Prices Column
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Discounted / Current Price
                                      Text(
                                        AppMoneyUtils.formatCurrency(
                                          discountedPrice,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: context.isDark
                                              ? const Color(0xFFFAAD01)
                                              : const Color(0xFF6E0131),
                                          fontWeight: FontWeight.w900,
                                          fontSize: priceSize,
                                          fontFamily: 'Cairo',
                                          height: 1.1,
                                        ),
                                      ),

                                      // Original Price (if discounted)
                                      if (hasDiscount) ...[
                                        const SizedBox(height: 1),
                                        Text(
                                          AppMoneyUtils.formatCurrency(
                                            originalPrice,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: context.isDark
                                                ? Colors.white38
                                                : const Color(0xFF9E8E98),
                                            decoration:
                                                TextDecoration.lineThrough,
                                            fontSize: oldPriceSize,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Cairo',
                                            height: 1.1,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Add To Cart Quick Action
                                if (showAddToCart)
                                  AppActionIconButton(
                                    icon: Icons.add_shopping_cart_rounded,
                                    onTap: () => _addToCart(context, ref),
                                    size: 30,
                                    iconSize: 15,
                                    backgroundColor: context.isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy,
                                    iconColor: context.isDark
                                        ? const Color(0xFF1E0A17)
                                        : Colors.white,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        cardPadding,
                        6,
                        cardPadding,
                        8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand Name (Direction-Safe start aligned)
                          if (brandName.isNotEmpty) ...[
                            Text(
                              brandName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.isDark
                                    ? BrandColors.gold
                                    : BrandColors.burgundy,
                                fontWeight: FontWeight.w700,
                                fontSize: brandSize,
                                fontFamily: 'Cairo',
                                letterSpacing: 0.2,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 2),
                          ],

                          // Product Title
                          Text(
                            item.title.tr,
                            maxLines: titleMaxLines,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.isDark
                                  ? Colors.white
                                  : const Color(0xFF1E0A17),
                              fontWeight: FontWeight.w800,
                              fontSize: titleSize,
                              fontFamily: 'Cairo',
                              height: 1.25,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Price & Action Button Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Prices Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Discounted / Current Price
                                    Text(
                                      AppMoneyUtils.formatCurrency(
                                        discountedPrice,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.isDark
                                            ? const Color(0xFFFAAD01)
                                            : const Color(0xFF6E0131),
                                        fontWeight: FontWeight.w900,
                                        fontSize: priceSize,
                                        fontFamily: 'Cairo',
                                        height: 1.1,
                                      ),
                                    ),

                                    // Original Price (if discounted)
                                    if (hasDiscount) ...[
                                      const SizedBox(height: 1),
                                      Text(
                                        AppMoneyUtils.formatCurrency(
                                          originalPrice,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: context.isDark
                                              ? Colors.white38
                                              : const Color(0xFF9E8E98),
                                          decoration:
                                              TextDecoration.lineThrough,
                                          fontSize: oldPriceSize,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Cairo',
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),

                              // Add To Cart Quick Action
                              if (showAddToCart)
                                AppActionIconButton(
                                  icon: Icons.add_shopping_cart_rounded,
                                  onTap: () => _addToCart(context, ref),
                                  size: 30,
                                  iconSize: 15,
                                  backgroundColor: context.isDark
                                      ? BrandColors.gold
                                      : BrandColors.burgundy,
                                  iconColor: context.isDark
                                      ? const Color(0xFF1E0A17)
                                      : Colors.white,
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
      },
    );
  }
}
