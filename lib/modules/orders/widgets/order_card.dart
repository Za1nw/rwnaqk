import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_date_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_order_utils.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final id = order.id;
    final status = order.status;
    final total = order.total;
    final itemsCount = order.itemsCount;
    final createdAt = order.createdAt;
    final address = order.addressLine;

    // First item title preview
    final firstItemTitle =
        (order.details != null && order.details!.items.isNotEmpty)
        ? order.details!.items.first.title
        : null;

    final statusColor = _resolveStatusColor(status);
    final statusLabel = AppOrderUtils.statusLabel(status).tr;
    final statusIcon = AppOrderUtils.statusIcon(status);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.22)
              : BrandColors.burgundy.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          splashColor: (isDark ? BrandColors.gold : BrandColors.burgundy)
              .withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Top Row: Order ID & Status Badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color:
                            (isDark ? BrandColors.gold : BrandColors.burgundy)
                                .withValues(alpha: isDark ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: isDark ? BrandColors.gold : BrandColors.burgundy,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            id,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E0A17),
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              fontFamily: 'Cairo',
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AppDateUtils.formatYmd(createdAt),
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white60
                                  : const Color(0xFF7E6674),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    _OrderStatusBadge(
                      label: statusLabel,
                      icon: statusIcon,
                      color: statusColor,
                      isDark: isDark,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 2. Product Items Preview (if present)
                if (firstItemTitle != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.04)
                          : const Color(0xFFF9F5F8),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : BrandColors.burgundy.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 15,
                          color: isDark
                              ? BrandColors.gold
                              : BrandColors.burgundy,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            itemsCount > 1
                                ? '$firstItemTitle + ${itemsCount - 1} منتجات أخرى'
                                : firstItemTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF4A3442),
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // 3. Address Info (if available)
                if ((address ?? '').trim().isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: isDark
                            ? BrandColors.gold.withValues(alpha: 0.7)
                            : BrandColors.burgundy.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF6E5664),
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Divider line
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : BrandColors.burgundy.withValues(alpha: 0.06),
                ),

                const SizedBox(height: 12),

                // 4. Bottom Row: Total & Action Buttons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Total Amount in Yemeni Rial
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الإجمالي',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white54
                                : const Color(0xFF8A7682),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          AppMoneyUtils.riyal(total),
                          style: TextStyle(
                            color: isDark
                                ? BrandColors.gold
                                : BrandColors.burgundy,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Action: Details Button
                    InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.06)
                              : const Color(0xFFF3EDF1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          Tk.ordersDetailsTitle.tr,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF26141E),
                            fontWeight: FontWeight.w800,
                            fontSize: 11.5,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Action: Tracking Button (for active/shipped/pending)
                    if (status != 'canceled')
                      InkWell(
                        onTap: () => AppNav.toNamed(
                          AppRoutes.orderTracking,
                          arguments: order,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
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
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isDark
                                            ? const Color(0xFFFAAD01)
                                            : const Color(0xFF6E0131))
                                        .withValues(alpha: 0.30),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFF1E0A17)
                                    : Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'تتبع الطلب',
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
        ),
      ),
    );
  }

  Color _resolveStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return const Color(0xFF10B981); // Emerald green
      case 'shipped':
        return const Color(0xFF0284C7); // Sky blue
      case 'pending':
        return const Color(0xFFF59E0B); // Amber gold
      case 'canceled':
        return const Color(0xFFEF4444); // Red
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _OrderStatusBadge({
    required this.label,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.22 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.50 : 0.30),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              fontFamily: 'Cairo',
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}
