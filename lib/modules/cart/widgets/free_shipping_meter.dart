import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';

/// عداد الشحن المجاني التفاعلي (Free Shipping Progress Meter)
/// يشجع العميل على زيادة قيمة السلة للحصول على التوصيل المجاني.
class FreeShippingMeter extends StatelessWidget {
  final double currentSubtotal;
  final double targetThreshold;

  const FreeShippingMeter({
    super.key,
    required this.currentSubtotal,
    this.targetThreshold = 40000, // 40,000 ر.ي كحد أدنى للشحن المجاني
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isFree = currentSubtotal >= targetThreshold;
    final progress = (currentSubtotal / targetThreshold).clamp(0.0, 1.0);
    final remaining = (targetThreshold - currentSubtotal).clamp(
      0,
      targetThreshold,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? (isFree
                  ? const Color(0xFF10B981).withValues(alpha: 0.12)
                  : const Color(0xFF24111F))
            : (isFree ? const Color(0xFFE8F5E9) : const Color(0xFFFAF3F7)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFree
              ? const Color(0xFF10B981).withValues(alpha: 0.4)
              : (isDark
                    ? BrandColors.gold.withValues(alpha: 0.16)
                    : const Color(0xFFEDE3EA)),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isFree
                      ? const Color(0xFF10B981)
                      : (isDark ? BrandColors.gold : BrandColors.burgundy),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFree
                      ? Icons.celebration_rounded
                      : Icons.local_shipping_rounded,
                  size: 14,
                  color: isFree
                      ? Colors.white
                      : (isDark ? const Color(0xFF1E0A17) : Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isFree
                      ? 'تهانينا! لقد حصلت على توصيل مجاني لكامل طلبك 🎉'
                      : 'أضف بـ ${AppMoneyUtils.riyal(remaining)} إضافية لتستمتع بشحن مجاني!',
                  style: TextStyle(
                    color: isFree
                        ? (isDark
                              ? const Color(0xFF34D399)
                              : const Color(0xFF1B5E20))
                        : (isDark ? Colors.white : const Color(0xFF26141E)),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    fontFamily: 'Cairo',
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress Bar with Truck Icon
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Background Track
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.10)
                      : const Color(0xFFE6D9E1),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              // Animated Fill Bar
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isFree
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : (isDark
                                ? [
                                    const Color(0xFFFAAD01),
                                    const Color(0xFFE59C00),
                                  ]
                                : [
                                    const Color(0xFF8E0542),
                                    const Color(0xFF6E0131),
                                  ]),
                    ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
