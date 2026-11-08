import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_status_pill.dart';

class OrderTrackingHeader extends StatelessWidget {
  final String? orderId;
  final String? status;

  const OrderTrackingHeader({super.key, this.orderId, this.status});

  void _copyOrderId(String id) {
    Clipboard.setData(ClipboardData(text: id));
    AppToast.copied(
      message: 'تم نسخ رقم الطلب $id بنجاح إلى الحافظة',
      title: 'تم النسخ',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Row(
      children: [
        // Back Button
        InkWell(
          onTap: Get.back,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
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

        // Title and Order ID
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Tk.ordersTrackingTitle.tr,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E0A17),
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  fontFamily: 'Cairo',
                  height: 1.1,
                ),
              ),
              if (orderId != null && orderId!.isNotEmpty) ...[
                const SizedBox(height: 2),
                InkWell(
                  onTap: () => _copyOrderId(orderId!),
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        orderId!,
                        style: TextStyle(
                          color: isDark
                              ? BrandColors.gold
                              : BrandColors.burgundy,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.copy_rounded,
                        size: 13,
                        color: isDark
                            ? BrandColors.gold.withValues(alpha: 0.8)
                            : BrandColors.burgundy.withValues(alpha: 0.8),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Status Pill
        if (status != null && status!.isNotEmpty)
          OrderStatusPill(status: status!),
      ],
    );
  }
}
