import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/controllers/orders_controller.dart';
import 'package:rwnaqk/models/order_model.dart';
import 'package:rwnaqk/widgets/orders/order_status_pill.dart';
import 'package:rwnaqk/widgets/orders/order_timeline.dart';

class OrderTrackingScreen extends GetView<OrdersController> {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ نستقبل OrderModel من arguments
    final order = Get.arguments as OrderModel;

    // ✅ نبني Steps من الكنترولر (نفس المنطق المركزي)
    final steps = controller.buildTrackingSteps(order);

    // ✅ عدّل هذه المابات حسب OrderModel عندك
    final id = order.id; // <-- عدّل إذا اسم الحقل مختلف
    final status = order.status; // <-- عدّل
    final addressLine = order.addressLine; // <-- عدّل (قد تكون order.address?.full)
    // ===================================

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.arrow_back_rounded, color: context.foreground),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'تتبع الطلب'.tr,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Material(
              color: context.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: context.border.withOpacity(.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            id,
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                        OrderStatusPill(status: status),
                      ],
                    ),
                    if ((addressLine ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 18, color: context.muted),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              addressLine!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.muted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            Text(
              'حالة الطلب'.tr,
              style: TextStyle(
                color: context.foreground,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),

            Material(
              color: context.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: BorderSide(color: context.border.withOpacity(.35)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: OrderTimeline(
                  steps: steps,
                  currentStatus: status,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}