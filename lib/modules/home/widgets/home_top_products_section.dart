import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_action_icon_button.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_section_header.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/cart_added_dialog.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_card_image_section.dart';
import 'package:rwnaqk_frontend/modules/home/providers/home_providers.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

class HomeTopProductsSection extends ConsumerWidget {
  final double itemWidth;
  final double height;

  const HomeTopProductsSection({
    super.key,
    this.itemWidth = 165,
    this.height = 280,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeContentProvider);
    final notifier = ref.read(homeContentProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(
          title: Tk.homeTopProducts.tr,
          actionText: Tk.homeSeeAll.tr,
          onActionTap: notifier.onSeeAllMostPopular,
        ),
        const SizedBox(height: 12),
        if (state.topProducts.isNotEmpty)
          SizedBox(
            height: height,
            child: ListView.separated(
              clipBehavior: Clip.none,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: state.topProducts.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                return SizedBox(
                  width: itemWidth,
                  child: _RankedProductCard(
                    item: state.topProducts[i],
                    rank: i + 1,
                    onTap: () => notifier.openProduct(state.topProducts[i]),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _RankedProductCard extends ConsumerWidget {
  final HomeProductItem item;
  final int rank;
  final VoidCallback onTap;

  const _RankedProductCard({
    required this.item,
    required this.rank,
    required this.onTap,
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
        : 'رَوْنَقُك';

    // Rank styling
    final isTop1 = rank == 1;
    final isTop2 = rank == 2;
    final isTop3 = rank == 3;

    final Color rankColor;
    final String rankLabel;

    if (isTop1) {
      rankColor = BrandColors.gold;
      rankLabel = '👑 #1 الأكثر طلباً';
    } else if (isTop2) {
      rankColor = const Color(0xFFC0C0C0);
      rankLabel = '🥈 #2 الأكثر مبيعاً';
    } else if (isTop3) {
      rankColor = const Color(0xFFCD7F32);
      rankLabel = '🥉 #3 تقييم 4.9';
    } else {
      rankColor = context.primary;
      rankLabel = '#$rank متميز';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final titleSize = w < 165 ? 12.0 : 13.0;
        final priceSize = w < 165 ? 12.5 : 13.5;
        final cardPadding = w < 165 ? 8.0 : 10.0;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isTop1
                      ? BrandColors.gold.withValues(
                          alpha: context.isDark ? 0.60 : 0.80,
                        )
                      : context.border.withValues(alpha: 0.35),
                  width: isTop1 ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isTop1
                        ? BrandColors.gold.withValues(
                            alpha: context.isDark ? 0.20 : 0.12,
                          )
                        : context.shadow.withValues(
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
                  Stack(
                    children: [
                      ProductCardImageSection(
                        item: item,
                        imageUrl: item.imageUrl,
                        radius: 16,
                      ),
                      // Rank Badge (Direction-Safe Start-Bottom of Image)
                      PositionedDirectional(
                        bottom: 6,
                        start: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.80),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: rankColor.withValues(alpha: 0.80),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            rankLabel,
                            style: TextStyle(
                              color: rankColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              fontFamily: 'Cairo',
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                        Text(
                          brandName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: context.primary.withValues(alpha: 0.85),
                            fontFamily: 'Cairo',
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(height: 3),
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

                        // Rating row
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: BrandColors.gold,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: context.foreground,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '(280+)',
                              style: TextStyle(
                                fontSize: 9.5,
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
                                    AppMoneyUtils.riyal(discountedPrice),
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
                                      AppMoneyUtils.riyal(originalPrice),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 9.5,
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
                            AppActionIconButton(
                              icon: Icons.shopping_bag_outlined,
                              onTap: () => _addToCart(context, ref),
                              size: 28,
                              iconSize: 14,
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
