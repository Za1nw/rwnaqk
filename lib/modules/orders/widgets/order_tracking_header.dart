import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class OrderTrackingHeader extends StatelessWidget {
  const OrderTrackingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Row(
      children: [
        InkWell(
          onTap: Get.back,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF261422) : const Color(0xFFF7F1F5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? BrandColors.gold.withValues(alpha: 0.25)
                    : BrandColors.burgundy.withValues(alpha: 0.12),
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: isDark ? Colors.white : const Color(0xFF1E0A17),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            Tk.ordersTrackingTitle.tr,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF1E0A17),
              fontWeight: FontWeight.w900,
              fontSize: 18,
              fontFamily: 'Cairo',
            ),
          ),
        ),
      ],
    );
  }
}
