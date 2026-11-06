import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_details_section_card.dart';

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
    final isDark = context.isDark;

    return OrderDetailsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E0A17),
              fontWeight: FontWeight.w900,
              fontSize: 14.5,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(height: 14),
          ...List.generate(rows.length, (index) {
            final row = rows[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == rows.length - 1 ? 0 : 12,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                          .withValues(alpha: isDark ? 0.16 : 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      row.icon,
                      size: 16,
                      color: isDark ? BrandColors.gold : BrandColors.burgundy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.label,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF7E6674),
                            fontWeight: FontWeight.w700,
                            fontSize: 11.5,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row.value,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1E0A17),
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            fontFamily: 'Cairo',
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
