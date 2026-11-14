import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/app_network_image.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';

/// بطاقة عنصر السلة بتصميم فاخر ومختلف
/// - هيكل عصري يبرز صور وفئات وأسعار المنتجات بوضوح استثنائي
/// - كبسولة كمية مخصصة ومريحة للمستخدم
/// - تناسق لوني مثالي في الوضعين الليلي والنهاري
class CartItemTile extends StatelessWidget {
  final HomeProductItem item;
  final int quantity;
  final String? variantText;
  final double? rating;
  final int? reviewsCount;

  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback? onTap;

  const CartItemTile({
    super.key,
    required this.item,
    required this.quantity,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    this.variantText,
    this.rating,
    this.reviewsCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasDiscount = item.hasDiscount;
    final salePrice = item.salePrice;
    final originalPrice = item.price;
    final lineTotal = salePrice * quantity;
    final brandTitle = item.brand.isNotEmpty ? item.brand : 'رَوْنَقُك';
    final stock = item.stockText.isNotEmpty
        ? item.stockText
        : 'متوفر في المخزون';
    final isLowStock = stock.contains('متبقي') || stock.contains('قليل');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.18)
              : const Color(0xFFECE1E8),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Content Row: Image + Main Details + Delete
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Thumbnail
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 96,
                            height: 104,
                            color: isDark
                                ? const Color(0xFF1B0B17)
                                : const Color(0xFFF9F5F8),
                            child: AppNetworkImage(
                              url: item.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (hasDiscount)
                          PositionedDirectional(
                            top: 6,
                            start: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEF4444),
                                    Color(0xFFB91C1C),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Text(
                                '-${item.discountPercent}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Cairo',
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(width: 12),

                    // Product Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand Pill + Delete Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? BrandColors.gold.withValues(alpha: 0.14)
                                      : BrandColors.burgundy.withValues(
                                          alpha: 0.08,
                                        ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  brandTitle,
                                  style: TextStyle(
                                    color: isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),

                              // Quick Delete Icon Button
                              InkWell(
                                onTap: onRemove,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.06)
                                        : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: isDark
                                        ? const Color(0xFFFCA5A5)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Product Title
                          Text(
                            item.title.tr,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E0A17),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Cairo',
                              height: 1.25,
                            ),
                          ),

                          // Variations (Size / Color)
                          if (variantText != null &&
                              variantText!.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              variantText!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white60
                                    : const Color(0xFF7E6674),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],

                          const SizedBox(height: 6),

                          // Stock indicator
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isLowStock
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                stock,
                                style: TextStyle(
                                  color: isLowStock
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFF10B981),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),

                          // Unit price
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text(
                                AppMoneyUtils.riyal(salePrice),
                                style: TextStyle(
                                  color: isDark
                                      ? BrandColors.gold
                                      : BrandColors.burgundy,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              if (hasDiscount)
                                Text(
                                  AppMoneyUtils.riyal(originalPrice),
                                  style: TextStyle(
                                    color: isDark
                                        ? Colors.white38
                                        : const Color(0xFFA5909E),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.lineThrough,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Divider line
                Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : const Color(0xFFF3EAF0),
                ),

                const SizedBox(height: 10),

                // Bottom Controls Row: Custom Stepper + Line Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Custom Capsule Stepper
                    _buildStepperCapsule(context, isDark: isDark),

                    // Item Line Subtotal
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${Tk.cartTotal.tr}: ',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF6E5664),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          AppMoneyUtils.riyal(lineTotal),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E0A17),
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// كبسولة الكمية ذات التصميم المريح
  Widget _buildStepperCapsule(BuildContext context, {required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B0B17) : const Color(0xFFF7F1F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : const Color(0xFFE8DCE4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement Button
          _stepperButton(
            icon: Icons.remove_rounded,
            onTap: onDecrement,
            isDark: isDark,
          ),

          // Quantity text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                fontFamily: 'Cairo',
              ),
            ),
          ),

          // Increment Button
          _stepperButton(
            icon: Icons.add_rounded,
            onTap: onIncrement,
            isDark: isDark,
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isHighlight = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isHighlight
              ? (isDark ? BrandColors.gold : BrandColors.burgundy)
              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          boxShadow: isHighlight
              ? [
                  BoxShadow(
                    color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                        .withValues(alpha: 0.25),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: isHighlight
                ? (isDark ? const Color(0xFF1E0A17) : Colors.white)
                : (isDark ? Colors.white70 : const Color(0xFF4A3443)),
          ),
        ),
      ),
    );
  }
}
