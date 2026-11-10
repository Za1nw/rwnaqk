import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_details_section_card.dart';

class OrderDetailsSummaryCard extends StatelessWidget {
  final double subtotal;
  final double shippingFee;
  final double discountAmount;
  final double total;

  const OrderDetailsSummaryCard({
    super.key,
    required this.subtotal,
    required this.shippingFee,
    this.discountAmount = 0.0,
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
          if (discountAmount > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: 'خصم الكوبون',
              value: '- ${AppMoneyUtils.riyal(discountAmount)}',
              isHighlight: true,
              isDark: isDark,
            ),
          ],
          const SizedBox(height: 8),
          _SummaryRow(
            label: Tk.cartPaymentShipping.tr,
            value: shippingFee <= 0
                ? Tk.cartFree.tr
                : AppMoneyUtils.riyal(shippingFee),
            isHighlight: shippingFee <= 0,
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
  final bool isHighlight;
  final bool isDark;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
    this.isHighlight = false,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    Color labelColor;
    Color valueColor;

    if (emphasize) {
      labelColor = isDark ? Colors.white : const Color(0xFF1E0A17);
      valueColor = isDark ? BrandColors.gold : BrandColors.burgundy;
    } else if (isHighlight) {
      labelColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
      valueColor = isDark ? const Color(0xFF34D399) : const Color(0xFF059669);
    } else {
      labelColor = isDark ? Colors.white70 : const Color(0xFF6E5664);
      valueColor = isDark ? Colors.white : const Color(0xFF1E0A17);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontWeight: emphasize
                ? FontWeight.w900
                : (isHighlight ? FontWeight.w800 : FontWeight.w700),
            fontSize: emphasize ? 14 : 12.5,
            fontFamily: 'Cairo',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: emphasize ? FontWeight.w900 : FontWeight.w800,
            fontSize: emphasize ? 16 : 13,
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
