import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/orders/order_details_section_card.dart';

class OrderDetailsInfoCard extends StatelessWidget {
  final String title;
  final List<OrderDetailsInfoRow> rows;

  const OrderDetailsInfoCard({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return OrderDetailsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(rows.length, (index) {
            final row = rows[index];

            return Padding(
              padding: EdgeInsets.only(bottom: index == rows.length - 1 ? 0 : 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(row.icon, size: 18, color: context.mutedForeground),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.label,
                          style: TextStyle(
                            color: context.mutedForeground,
                            fontWeight: FontWeight.w700,
                            fontSize: 11.8,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          row.value,
                          style: TextStyle(
                            color: context.foreground,
                            fontWeight: FontWeight.w800,
                            fontSize: 12.8,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class OrderDetailsInfoRow {
  final IconData icon;
  final String label;
  final String value;

  const OrderDetailsInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
}
