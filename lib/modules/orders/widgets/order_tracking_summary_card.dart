import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_date_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_status_pill.dart';

class OrderTrackingSummaryCard extends StatelessWidget {
  final String id;
  final String status;
  final DateTime createdAt;
  final int itemsCount;
  final double total;
  final String? addressLine;
  final String? deliveryName;
  final String? deliveryPhone;

  const OrderTrackingSummaryCard({
    super.key,
    required this.id,
    required this.status,
    required this.createdAt,
    required this.itemsCount,
    required this.total,
    this.addressLine,
    this.deliveryName,
    this.deliveryPhone,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.20)
              : BrandColors.burgundy.withValues(alpha: 0.08),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  id,
                  style: TextStyle(
                    color: isDark ? Colors.white : const Color(0xFF1E0A17),
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              OrderStatusPill(status: status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _MiniInfo(
                icon: Icons.calendar_month_outlined,
                text: AppDateUtils.formatYmd(createdAt),
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _MiniInfo(
                icon: Icons.shopping_bag_outlined,
                text: Tk.ordersItemsCount.trParams({'count': '$itemsCount'}),
                isDark: isDark,
              ),
              const Spacer(),
              Text(
                AppMoneyUtils.riyal(total),
                style: TextStyle(
                  color: isDark ? BrandColors.gold : BrandColors.burgundy,
                  fontWeight: FontWeight.w900,
                  fontSize: 15.5,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          if ((addressLine ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: isDark
                      ? BrandColors.gold.withValues(alpha: 0.7)
                      : BrandColors.burgundy.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    addressLine!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : const Color(0xFF6E5664),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (((deliveryName ?? '').trim().isNotEmpty) ||
              ((deliveryPhone ?? '').trim().isNotEmpty)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF7F1F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : BrandColors.burgundy.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: isDark ? BrandColors.gold : BrandColors.burgundy,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if ((deliveryName ?? '').trim().isNotEmpty)
                          Text(
                            deliveryName!,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E0A17),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        if ((deliveryPhone ?? '').trim().isNotEmpty)
                          Text(
                            deliveryPhone!,
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
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;

  const _MiniInfo({
    required this.icon,
    required this.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF7F1F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : BrandColors.burgundy.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDark ? BrandColors.gold : BrandColors.burgundy,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF4A3442),
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
