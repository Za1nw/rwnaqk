import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_action_icon_button.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/cart_added_dialog.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

import 'product_card_image_section.dart';

class ProductCard extends StatelessWidget {
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

  void _addToCart(BuildContext context) {
    if (Get.isRegistered<CartController>()) {
      final cartController = Get.find<CartController>();
      cartController.addToCart(item);
    }
    CartAddedDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
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

        final titleSize = w < 165 ? 12.5 : 13.5;
        final brandSize = w < 165 ? 10.0 : 11.0;
        final priceSize = w < 165 ? 13.0 : 14.0;
        final oldPriceSize = w < 165 ? 10.0 : 10.5;
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
                  color: context.border.withValues(alpha: 0.35),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.shadow.withValues(
                      alpha: context.isDark ? 0.16 : 0.05,
                    ),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
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
                      8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand Name
                        if (brandName.isNotEmpty) ...[
                          Text(
                            brandName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: brandSize,
                              fontWeight: FontWeight.w700,
                              color: context.primary.withValues(alpha: 0.85),
                              fontFamily: 'Cairo',
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(height: 3),
                        ],

                        // Title
                        Text(
                          item.title.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: context.foreground,
                            fontFamily: 'Cairo',
                            height: 1.2,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // Rating row (clean, no awkward yellow box)
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: BrandColors.gold,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: context.foreground,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '(120+)',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: context.mutedForeground,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        // Price and Add to Cart Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${discountedPrice.toStringAsFixed(0)} ${Tk.homeCurrency.tr}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: priceSize,
                                      fontWeight: FontWeight.w900,
                                      color: context.foreground,
                                      fontFamily: 'Cairo',
                                      height: 1.0,
                                    ),
                                  ),
                                  if (hasDiscount) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '${originalPrice.toStringAsFixed(0)} ${Tk.homeCurrency.tr}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: oldPriceSize,
                                        fontWeight: FontWeight.w600,
                                        color: context.mutedForeground,
                                        decoration: TextDecoration.lineThrough,
                                        fontFamily: 'Cairo',
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (showAddToCart)
                              AppActionIconButton(
                                icon: Icons.shopping_bag_outlined,
                                onTap: () => _addToCart(context),
                                size: 30,
                                iconSize: 15,
                                backgroundColor: context.primary,
                                iconColor: Colors.white,
                                borderColor: Colors.transparent,
                                radius: 8,
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
