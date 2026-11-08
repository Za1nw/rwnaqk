import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// بطاقة المحفظة والمكافآت والكوبونات القياسية في المتاجر الفاخرة
class EcommerceWalletHub extends StatelessWidget {
  final String walletBalance;
  final String activeCouponsCount;
  final String loyaltyPoints;
  final VoidCallback? onWalletTap;
  final VoidCallback? onCouponsTap;
  final VoidCallback? onPointsTap;

  const EcommerceWalletHub({
    super.key,
    required this.walletBalance,
    this.activeCouponsCount = '2 قسائم',
    this.loyaltyPoints = '250 نقطة',
    this.onWalletTap,
    this.onCouponsTap,
    this.onPointsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.border.withValues(alpha: isDark ? 0.35 : 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. رصيد المحفظة
          Expanded(
            child: _MetricTile(
              label: 'رصيد المحفظة',
              value: walletBalance,
              icon: Icons.account_balance_wallet_outlined,
              accentColor: BrandColors.gold,
              onTap: onWalletTap ?? () => Get.toNamed(AppRoutes.profile),
            ),
          ),

          _HubDivider(isDark: isDark),

          // 2. الكوبونات
          Expanded(
            child: _MetricTile(
              label: 'كوبونات الخصم',
              value: activeCouponsCount,
              icon: Icons.confirmation_number_outlined,
              accentColor: isDark
                  ? const Color(0xFF75D6A5)
                  : const Color(0xFF176B45),
              onTap: onCouponsTap ?? () => Get.toNamed(AppRoutes.cart),
            ),
          ),

          _HubDivider(isDark: isDark),

          // 3. نقاط الولاء
          Expanded(
            child: _MetricTile(
              label: 'نقاط رونق',
              value: loyaltyPoints,
              icon: Icons.auto_awesome_outlined,
              accentColor: isDark ? AppColors.gold : AppColors.burgundy,
              onTap: onPointsTap ?? () => Get.toNamed(AppRoutes.profile),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 15, color: accentColor),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTheme.cairo(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.cairo(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HubDivider extends StatelessWidget {
  final bool isDark;

  const _HubDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(
        alpha: 0.6,
      ),
    );
  }
}
