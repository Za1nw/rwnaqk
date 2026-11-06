import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/app_network_image.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

class WishlistItemTile extends StatelessWidget {
  final HomeProductItem item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback onAddToCart;
  final String? variantText;
  final bool showRemoveButton;

  const WishlistItemTile({
    super.key,
    required this.item,
    required this.onAddToCart,
    this.onRemove,
    this.onTap,
    this.variantText,
    this.showRemoveButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final hasDiscount = item.hasDiscount;
    final salePrice = item.salePrice;
    final originalPrice = item.price;
    final w = MediaQuery.sizeOf(context).width;
    final isSmall = w < 360;

    final brandName = item.brand.trim().isNotEmpty
        ? item.brand.tr
        : (item.material != null && item.material!.trim().isNotEmpty
              ? item.material!.tr
              : 'رَوْنَقُك');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.22)
              : BrandColors.burgundy.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: (isDark ? BrandColors.gold : BrandColors.burgundy)
              .withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Product Image with Discount & Rating Badges
                _WishlistProductThumbnail(
                  imageUrl: item.imageUrl,
                  discountPercent: item.discountPercent,
                  rating: 4.8,
                  isDark: isDark,
                ),

                const SizedBox(width: 12),

                // 2. Product Information & Actions
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: Brand & Delete Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              brandName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? BrandColors.gold.withValues(alpha: 0.85)
                                    : BrandColors.burgundy.withValues(
                                        alpha: 0.85,
                                      ),
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                fontFamily: 'Cairo',
                                height: 1.1,
                              ),
                            ),
                          ),
                          if (showRemoveButton && onRemove != null)
                            InkWell(
                              onTap: onRemove,
                              borderRadius: BorderRadius.circular(999),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: isDark
                                      ? const Color(0xFFFF5252)
                                      : const Color(0xFFD32F2F),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Title
                      Text(
                        item.title.tr,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E0A17),
                          fontWeight: FontWeight.w800,
                          fontSize: isSmall ? 13 : 14,
                          fontFamily: 'Cairo',
                          height: 1.25,
                        ),
                      ),

                      // Variant Chip if available
                      if (variantText != null &&
                          variantText!.trim().isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : const Color(0xFFF3EDF1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            variantText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF6E5664),
                              fontWeight: FontWeight.w600,
                              fontSize: 10.5,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 6),

                      // Stock status
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF10B981), // Emerald green
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'متوفر في المخزون',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF34D399)
                                  : const Color(0xFF059669),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Bottom Row: Price & Add to Cart Button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Price in Yemeni Rial (ر.ي)
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Text(
                                  '${salePrice.toStringAsFixed(0)} ر.ي',
                                  style: TextStyle(
                                    color: isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy,
                                    fontWeight: FontWeight.w900,
                                    fontSize: isSmall ? 14 : 15.5,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                if (hasDiscount)
                                  Text(
                                    '${originalPrice.toStringAsFixed(0)} ر.ي',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white38
                                          : const Color(0xFF9E8A95),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 11,
                                      fontFamily: 'Cairo',
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Quick Add to Cart button
                          InkWell(
                            onTap: onAddToCart,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDark
                                      ? [
                                          const Color(0xFFFAAD01),
                                          const Color(0xFFE59C00),
                                        ]
                                      : [
                                          const Color(0xFF8E0542),
                                          const Color(0xFF6E0131),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? const Color(0xFFFAAD01)
                                                : const Color(0xFF6E0131))
                                            .withValues(alpha: 0.30),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.shopping_bag_outlined,
                                    size: 15,
                                    color: isDark
                                        ? const Color(0xFF1E0A17)
                                        : Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'أضف للسلة',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFF1E0A17)
                                          : Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 11.5,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
      ),
    );
  }
}

class _WishlistProductThumbnail extends StatelessWidget {
  final String imageUrl;
  final int? discountPercent;
  final double rating;
  final bool isDark;

  const _WishlistProductThumbnail({
    required this.imageUrl,
    required this.discountPercent,
    required this.rating,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const size = 104.0;
    final hasDiscount = (discountPercent ?? 0) > 0;

    return Stack(
      children: [
        // Image Container with graceful luxury fallback
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF331A2D), const Color(0xFF1F0C1B)]
                  : [const Color(0xFFF7F1F5), const Color(0xFFEDE2E9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : BrandColors.burgundy.withValues(alpha: 0.06),
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl.trim().isNotEmpty
              ? AppNetworkImage(url: imageUrl, fit: BoxFit.cover)
              : Center(
                  child: Icon(
                    Icons.checkroom_rounded,
                    size: 34,
                    color: isDark
                        ? BrandColors.gold.withValues(alpha: 0.3)
                        : BrandColors.burgundy.withValues(alpha: 0.25),
                  ),
                ),
        ),

        // Discount Badge (-20%)
        if (hasDiscount)
          PositionedDirectional(
            top: 6,
            start: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFD81B60), // Hot luxury pink/magenta
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD81B60).withValues(alpha: 0.4),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                '-%$discountPercent',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  fontFamily: 'Cairo',
                  height: 1.1,
                ),
              ),
            ),
          ),

        // Rating Badge (★ 4.8)
        PositionedDirectional(
          bottom: 6,
          start: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  size: 11,
                  color: Color(0xFFFFB300),
                ),
                const SizedBox(width: 2),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 9.5,
                    fontFamily: 'Cairo',
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
