import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.primary.withOpacity(.16),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: context.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${'الحالة'.tr}: $statusText  •  ${'الوصول المتوقع'.tr}: $etaText',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.primary,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}