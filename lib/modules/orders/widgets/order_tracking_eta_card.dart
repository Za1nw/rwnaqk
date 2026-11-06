import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class OrderTrackingEtaCard extends StatelessWidget {
  final IconData icon;
  final String statusText;
  final String etaText;

  const OrderTrackingEtaCard({
    super.key,
    required this.icon,
    required this.statusText,
    required this.etaText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final primaryColor = isDark ? BrandColors.gold : BrandColors.burgundy;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.40 : 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${Tk.ordersLabelStatus.tr}: $statusText  •  ${Tk.ordersLabelExpectedDelivery.tr}: $etaText',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
                fontWeight: FontWeight.w800,
                fontSize: 12.5,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
