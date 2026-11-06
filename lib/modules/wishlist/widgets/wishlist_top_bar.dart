import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';

class WishlistTopBar extends StatelessWidget {
  final String title;

  const WishlistTopBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WishlistController>();
    final isDark = context.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Top Header Row: Title + Count Badge + Quick Cart Button
        Obx(() {
          final idx = c.tabIndex.value;
          final count = idx == 0 ? c.wishlist.length : c.recentlyViewed.length;
          final cartCount = Get.isRegistered<CartController>()
              ? Get.find<CartController>().cartItems.length
              : 0;

          return Row(
            children: [
              // Title
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E0A17),
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                  fontFamily: 'Cairo',
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(width: 8),

              // Items Count Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                      .withValues(alpha: isDark ? 0.20 : 0.10),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                        .withValues(alpha: isDark ? 0.40 : 0.20),
                  ),
                ),
                child: Text(
                  '$count عناصر',
                  style: TextStyle(
                    color: isDark ? BrandColors.gold : BrandColors.burgundy,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),

              const Spacer(),

              // Quick Cart Button with Badge
              InkWell(
                onTap: () => c.openCart(),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF261422)
                        : const Color(0xFFF7F1F5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? BrandColors.gold.withValues(alpha: 0.25)
                          : BrandColors.burgundy.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        size: 21,
                        color: isDark ? Colors.white : const Color(0xFF261422),
                      ),
                      if (cartCount > 0)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(
                                0xFFE53935,
                              ), // Vibrant red notification dot
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),

        const SizedBox(height: 14),

        // 2. Segmented Navigation Tab Pill
        Obx(() {
          final idx = c.tabIndex.value;
          final wishlistCount = c.wishlist.length;
          final recentCount = c.recentlyViewed.length;

          return Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF24111F) : const Color(0xFFF5EEF3),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? BrandColors.gold.withValues(alpha: 0.20)
                    : BrandColors.burgundy.withValues(alpha: 0.08),
              ),
            ),
            child: Row(
              children: [
                _TabPill(
                  text: '${Tk.wishlistTitle.tr} ($wishlistCount)',
                  icon: Icons.favorite_rounded,
                  selected: idx == 0,
                  onTap: () => c.setTab(0),
                ),
                _TabPill(
                  text: '${Tk.wishlistRecentlyViewed.tr} ($recentCount)',
                  icon: Icons.history_rounded,
                  selected: idx == 1,
                  onTap: () => c.setTab(1),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _TabPill extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.text,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? BrandColors.gold : BrandColors.burgundy)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                        .withValues(alpha: isDark ? 0.35 : 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(11),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: selected
                        ? (isDark ? const Color(0xFF1E0A17) : Colors.white)
                        : (isDark ? Colors.white60 : const Color(0xFF6E5664)),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? (isDark ? const Color(0xFF1E0A17) : Colors.white)
                            : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF6E5664)),
                        fontWeight: selected
                            ? FontWeight.w900
                            : FontWeight.w700,
                        fontSize: 12.5,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
