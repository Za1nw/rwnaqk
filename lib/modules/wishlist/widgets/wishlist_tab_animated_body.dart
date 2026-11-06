import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/core/utils/app_breakpoints.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_grid_section.dart';
import 'package:rwnaqk_frontend/modules/wishlist/widgets/recent_filter_row.dart';
import 'package:rwnaqk_frontend/modules/wishlist/widgets/wishlist_item_tile.dart';

class WishlistTabAnimatedBody extends StatelessWidget {
  final WishlistController controller;
  final bool isWishlist;

  const WishlistTabAnimatedBody({
    super.key,
    required this.controller,
    required this.isWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      reverseDuration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
        final slide =
            Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

        return FadeTransition(
          opacity: fade,
          child: SlideTransition(position: slide, child: child),
        );
      },
      child: isWishlist
          ? _WishlistTabContent(
              key: const ValueKey('wishlist_tab_content'),
              controller: controller,
            )
          : _RecentTabContent(
              key: const ValueKey('recent_tab_content'),
              controller: controller,
            ),
    );
  }
}

class _WishlistTabContent extends StatelessWidget {
  final WishlistController controller;

  const _WishlistTabContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller.wishlist.isEmpty) {
      return _WishlistEmptyState(onExplore: controller.goToHome);
    }

    return Column(
      children: [
        // Bulk Actions Bar (Add All to Cart)
        _WishlistBulkActionBar(
          count: controller.wishlist.length,
          onAddAll: controller.addAllToCart,
          onClear: controller.clearWishlist,
        ),

        const SizedBox(height: 10),

        // Products List
        Expanded(
          child: ListView.separated(
            key: const ValueKey('wishlist_list'),
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 110),
            itemCount: controller.wishlist.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final item = controller.wishlist[i];

              return WishlistItemTile(
                item: item,
                onTap: () => controller.openProduct(item),
                onRemove: () => controller.removeFromWishlist(item.id),
                onAddToCart: () => controller.addToCart(item),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WishlistBulkActionBar extends StatelessWidget {
  final int count;
  final VoidCallback onAddAll;
  final VoidCallback onClear;

  const _WishlistBulkActionBar({
    required this.count,
    required this.onAddAll,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : const Color(0xFFFAF5F8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.18)
              : BrandColors.burgundy.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 17,
            color: isDark ? BrandColors.gold : BrandColors.burgundy,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$count منتجات محفوظة',
              style: TextStyle(
                color: isDark ? Colors.white70 : const Color(0xFF4A3442),
                fontWeight: FontWeight.w700,
                fontSize: 12,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          InkWell(
            onTap: onAddAll,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                    .withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                      .withValues(alpha: isDark ? 0.45 : 0.25),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_shopping_cart_rounded,
                    size: 14,
                    color: isDark ? BrandColors.gold : BrandColors.burgundy,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'إضافة الكل للسلة',
                    style: TextStyle(
                      color: isDark ? BrandColors.gold : BrandColors.burgundy,
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
    );
  }
}

class _WishlistEmptyState extends StatelessWidget {
  final VoidCallback onExplore;

  const _WishlistEmptyState({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Heart Icon Container
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFFFF2D55) : BrandColors.burgundy)
                    .withValues(alpha: 0.12),
                border: Border.all(
                  color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                      .withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF2D55)
                        .withValues(alpha: isDark ? 0.25 : 0.10),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 42,
                  color: Color(0xFFFF2D55),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              'قائمة أمنياتك فارغة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
                fontWeight: FontWeight.w900,
                fontSize: 19,
                fontFamily: 'Cairo',
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              'لم تقم بحفظ أي منتجات بعد.\nاستكشف أحدث الأزياء والمنتجات الفاخرة وأضف ما يعجبك لتتسوقها لاحقاً بكل سهولة.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF6E5664),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Cairo',
                height: 1.45,
              ),
            ),

            const SizedBox(height: 24),

            // Start Shopping Button
            InkWell(
              onTap: onExplore,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFFFAAD01), const Color(0xFFE59C00)]
                        : [const Color(0xFF8E0542), const Color(0xFF6E0131)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? const Color(0xFFFAAD01)
                                  : const Color(0xFF6E0131))
                              .withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: isDark ? const Color(0xFF1E0A17) : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ابدأ التسوق الآن',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF1E0A17) : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _RecentTabContent extends StatelessWidget {
  final WishlistController controller;

  const _RecentTabContent({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    if (controller.recentlyViewed.isEmpty) {
      return Column(
        key: const ValueKey('recent_empty_column'),
        children: [
          const RecentFilterRow(),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 46,
                    color: isDark ? Colors.white38 : const Color(0xFF9E8A95),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد عناصر تمت مشاهدتها مؤخراً',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF261422),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      key: const ValueKey('recent_scroll'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const RecentFilterRow(),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (_, c) {
              final w = c.maxWidth;
              final cols = AppBreakpoints.productGridColumns(w);
              final ratio = w >= AppBreakpoints.compact ? 0.78 : 0.70;

              return ProductGridSection(
                items: controller.recentlyViewed,
                crossAxisCount: cols,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: ratio,
                onTap: controller.openProduct,
              );
            },
          ),
        ],
      ),
    );
  }
}
