import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import '../../models/home_product_item.dart';

class ProductCard extends StatelessWidget {
  final HomeProductItem item;
  final ValueChanged<HomeProductItem> onTap;

  final double radius;
  final bool showAddToCart;

  const ProductCard({
    super.key,
    required this.item,
    required this.onTap,
    this.radius = 18,
    this.showAddToCart = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = (item.discountPercent ?? 0) > 0;
    final originalPrice = item.price;
    final discountedPrice =
        hasDiscount ? originalPrice * (1 - (item.discountPercent! / 100)) : null;

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;

        /// responsive sizes based on width
        final titleSize = w < 150 ? 11.5 : w < 180 ? 12.5 : 14.0;
        final priceSize = w < 150 ? 13.0 : w < 180 ? 14.0 : 16.0;
        final iconSize = w < 150 ? 16.0 : 18.0;
        final pad = w < 150 ? 8.0 : 10.0;

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
                  color: context.border.withOpacity(.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.shadow.withOpacity(.10),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                 mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// ✅ responsive image ratio (no overflow ever)
                  AspectRatio(
                    aspectRatio: 1.05, // الصورة كبيرة دائمًا
                    child: _ImageSection(
                      imageUrl: item.imageUrl,
                      radius: radius,
                      hasDiscount: hasDiscount,
                      discountPercent: item.discountPercent ?? 0,
                    ),
                  ),

                  /// content tight
                  Padding( 
                    padding: EdgeInsets.all(pad),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        /// name + icon
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: titleSize,
                                  fontWeight: FontWeight.w700,
                                  height: 1.0,
                                  color: context.foreground,
                                ),
                              ),
                            ),

                            if (showAddToCart) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: iconSize + 12,
                                height: iconSize + 12,
                                decoration: BoxDecoration(
                                  color: context.primary.withOpacity(.10),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add_shopping_cart_rounded,
                                  size: iconSize,
                                  color: context.primary,
                                ),
                              ),
                            ],
                          ],
                        ),


                        /// price
                        Row(
                          children: [

                            Flexible(
                              child: Text(
                                '${'home.currency'.tr}${(hasDiscount ? discountedPrice! : originalPrice).toStringAsFixed(0)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: priceSize,
                                  fontWeight: FontWeight.w900,
                                  color: hasDiscount
                                      ? context.primary
                                      : context.foreground,
                                ),
                              ),
                            ),

                            if (hasDiscount) ...[
                              const SizedBox(width: 6),
                              Text(
                                '${'home.currency'.tr}${originalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: priceSize - 3,
                                  fontWeight: FontWeight.w700,
                                  color: context.mutedForeground,
                                  decoration:
                                      TextDecoration.lineThrough,
                                ),
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

class _ImageSection extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool hasDiscount;
  final int discountPercent;

  const _ImageSection({
    required this.imageUrl,
    required this.radius,
    required this.hasDiscount,
    required this.discountPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Positioned.fill(
          child: ClipRRect(
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(radius)),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),

        if (hasDiscount)
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: context.destructive,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '-$discountPercent%',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
            ),
          ),

        Positioned(
          top: 8,
          right: 8,
          child: Container(
            decoration: BoxDecoration(
              color: context.background.withOpacity(.9),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 18,
              color: context.primary,
            ),
          ),
        ),
      ],
    );
  }
}