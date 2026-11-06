import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_details_section_card.dart';

class OrderDetailsSummaryCard extends StatelessWidget {
  final double subtotal;
  final double shippingFee;
  final double total;

  const OrderDetailsSummaryCard({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return OrderDetailsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_outlined,
                size: 18,
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
              ),
              const SizedBox(width: 8),
              Text(
                Tk.ordersDetailsSummary.tr,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E0A17),
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            label: Tk.cartSubtotal.tr,
            value: AppMoneyUtils.riyal(subtotal),
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: Tk.cartPaymentShipping.tr,
            value: shippingFee <= 0
                ? Tk.cartFree.tr
                : AppMoneyUtils.riyal(shippingFee),
            isDark: isDark,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : BrandColors.burgundy.withValues(alpha: 0.06),
            ),
          ),
          _SummaryRow(
            label: Tk.cartTotal.tr,
            value: AppMoneyUtils.riyal(total),
            emphasize: true,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  final bool isDark;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: emphasize
                  ? (isDark ? Colors.white : const Color(0xFF1E0A17))
                  : (isDark ? Colors.white60 : const Color(0xFF6E5664)),
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              fontSize: emphasize ? 14 : 12.5,
              fontFamily: 'Cairo',
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: emphasize
                ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                : (isDark ? Colors.white : const Color(0xFF1E0A17)),
            fontWeight: FontWeight.w900,
            fontSize: emphasize ? 16 : 13,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
