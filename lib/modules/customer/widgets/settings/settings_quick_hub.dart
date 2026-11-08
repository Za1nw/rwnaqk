import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شريط الوصول السريع لأهم خدمات الحساب (الطلبات، العناوين، رصيد المحفظة)
class SettingsQuickHub extends StatelessWidget {
  final String ordersCount;
  final String defaultCity;
  final String walletBalance;
  final VoidCallback? onOrdersTap;
  final VoidCallback? onAddressesTap;

  const SettingsQuickHub({
    super.key,
    required this.ordersCount,
    required this.defaultCity,
    required this.walletBalance,
    this.onOrdersTap,
    this.onAddressesTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.border.withValues(alpha: isDark ? 0.35 : 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. الطلبات
          Expanded(
            child: _QuickHubItem(
              icon: Icons.local_shipping_outlined,
              title: Tk.settingsOrders.tr,
              subtitle: '$ordersCount شحنة',
              accentColor: isDark ? AppColors.gold : AppColors.burgundy,
              onTap: onOrdersTap ?? () => Get.toNamed(AppRoutes.orders),
            ),
          ),
          _HubDivider(isDark: isDark),

          // 2. العناوين
          Expanded(
            child: _QuickHubItem(
              icon: Icons.location_on_outlined,
              title: Tk.settingsAddresses.tr,
              subtitle: defaultCity.trim().isEmpty
                  ? 'إضافة عنوان'
                  : defaultCity,
              accentColor: isDark
                  ? const Color(0xFF75D6A5)
                  : const Color(0xFF176B45),
              onTap: onAddressesTap ?? () => Get.toNamed(AppRoutes.addresses),
            ),
          ),
          _HubDivider(isDark: isDark),

          // 3. رصيد المحفظة
          Expanded(
            child: _QuickHubItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'المحفظة',
              subtitle: walletBalance,
              accentColor: BrandColors.gold,
              onTap: onOrdersTap ?? () => Get.toNamed(AppRoutes.profile),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickHubItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _QuickHubItem({
    required this.icon,
    required this.title,
    required this.subtitle,
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: isDark ? 0.20 : 0.10),
                border: Border.all(
                  color: accentColor.withValues(alpha: isDark ? 0.40 : 0.25),
                  width: 1,
                ),
              ),
              child: Center(child: Icon(icon, size: 19, color: accentColor)),
            ),
            const SizedBox(height: 7),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.cairo(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
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
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: (isDark ? AppColors.borderDark : AppColors.borderLight).withValues(
        alpha: 0.6,
      ),
    );
  }
}
