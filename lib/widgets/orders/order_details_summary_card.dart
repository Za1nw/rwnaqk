import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_money_utils.dart';
import 'package:rwnaqk/widgets/orders/order_details_section_card.dart';

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
    return OrderDetailsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Tk.ordersDetailsSummary.tr,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: Tk.cartSubtotal.tr,
            value: AppMoneyUtils.riyal(subtotal),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: Tk.cartPaymentShipping.tr,
            value: shippingFee <= 0
                ? Tk.cartFree.tr
                : AppMoneyUtils.riyal(shippingFee),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          _SummaryRow(
            label: Tk.cartTotal.tr,
            value: AppMoneyUtils.riyal(total),
            emphasize: true,
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

  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = emphasize ? context.foreground : context.mutedForeground;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              fontSize: emphasize ? 13.5 : 12.5,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: emphasize ? context.primary : context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: emphasize ? 14 : 12.8,
          ),
        ),
      ],
    );
  }
}
