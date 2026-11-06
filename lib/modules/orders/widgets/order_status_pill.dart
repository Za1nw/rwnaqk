import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/utils/app_order_utils.dart';

class OrderStatusPill extends StatelessWidget {
  final String status;

  const OrderStatusPill({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final color = _resolveStatusColor(status);
    final icon = AppOrderUtils.statusIcon(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
            AppOrderUtils.statusLabel(status).tr,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
              fontFamily: 'Cairo',
              height: 1.1,
            ),
          ),
        ],
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
