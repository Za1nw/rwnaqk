import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// مركز متابعة الطلبات والشحنات القياسي للمتاجر الإلكترونية العالمية
/// يوفر وصولاً مباشراً وفورياً للمراحل الأربع للطلبات (قيد الانتظار، التجهيز، في الطريق، التقييم)
class EcommerceOrdersHub extends StatelessWidget {
  final int totalOrders;
  final VoidCallback? onAllOrders;

  const EcommerceOrdersHub({
    super.key,
    required this.totalOrders,
    this.onAllOrders,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.border.withValues(alpha: isDark ? 0.35 : 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // شريط العنوان العلوي مع زر "عرض كافة الطلبات"
          InkWell(
            onTap: onAllOrders ?? () => AppNav.toNamed(AppRoutes.orders),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (isDark ? AppColors.gold : AppColors.burgundy)
                          .withValues(alpha: 0.12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.receipt_long_rounded,
                        size: 17,
                        color: isDark ? AppColors.gold : AppColors.burgundy,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    Tk.settingsOrders.tr,
                    style: AppTextTheme.cairo(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        totalOrders > 0
                            ? 'عرض الكل ($totalOrders)'
                            : 'عرض كافة الطلبات',
                        style: AppTextTheme.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.gold : AppColors.burgundy,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 11,
                        color: isDark ? AppColors.gold : AppColors.burgundy,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Divider(
            height: 1,
            thickness: 0.8,
            indent: 14,
            endIndent: 14,
            color: (isDark ? AppColors.borderDark : AppColors.borderLight)
                .withValues(alpha: 0.5),
          ),

          // المراحل الأربع القياسية للطلبات في التجارة الإلكترونية
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _OrderStatusItem(
                  icon: Icons.hourglass_top_rounded,
                  label: 'قيد الانتظار',
                  badgeCount: 1,
                  onTap: () => AppNav.toNamed(AppRoutes.orders),
                ),
                _OrderStatusItem(
                  icon: Icons.inventory_2_outlined,
                  label: 'قيد التجهيز',
                  badgeCount: 2,
                  onTap: () => AppNav.toNamed(AppRoutes.orders),
                ),
                _OrderStatusItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'في الطريق',
                  badgeCount: 1,
                  isHighlighted: true,
                  onTap: () => AppNav.toNamed(AppRoutes.orders),
                ),
                _OrderStatusItem(
                  icon: Icons.rate_review_outlined,
                  label: 'بانتظار التقييم',
                  badgeCount: 0,
                  onTap: () => AppNav.toNamed(AppRoutes.orders),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderStatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int badgeCount;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _OrderStatusItem({
    required this.icon,
    required this.label,
    this.badgeCount = 0,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isHighlighted
        ? (isDark ? AppColors.gold : AppColors.burgundy)
        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isHighlighted
                        ? (isDark ? AppColors.gold : AppColors.burgundy)
                              .withValues(alpha: isDark ? 0.20 : 0.10)
                        : (isDark
                              ? const Color(0xFF2E1626)
                              : const Color(0xFFF7EFF3)),
                    border: Border.all(
                      color: isHighlighted
                          ? (isDark ? AppColors.gold : AppColors.burgundy)
                                .withValues(alpha: 0.4)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Center(child: Icon(icon, size: 21, color: color)),
                ),
                if (badgeCount > 0)
                  PositionedDirectional(
                    end: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.gold : AppColors.burgundy,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.card, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Center(
                        child: Text(
                          '$badgeCount',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFF1E0A17)
                                : Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextTheme.cairo(
                fontSize: 11.5,
                fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
