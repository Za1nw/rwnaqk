import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/models/order_model.dart';
import 'package:rwnaqk/widgets/dialogs/review_dialog.dart';
import 'package:rwnaqk/widgets/orders/order_timeline.dart';
import 'package:rwnaqk/widgets/orders/order_tracking_actions.dart';
import 'package:rwnaqk/widgets/orders/order_tracking_eta_card.dart';
import 'package:rwnaqk/widgets/orders/order_tracking_header.dart';
import 'package:rwnaqk/widgets/orders/order_tracking_summary_card.dart';
import 'package:rwnaqk/core/utils/app_order_utils.dart';

class OrderTrackingScreen extends GetView<OrdersController> {
  const OrderTrackingScreen({super.key});

  OrderModel? _getOrderFromArgs() {
    final args = Get.arguments;
    if (args is OrderModel) return args;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final order = _getOrderFromArgs();

    if (order == null) {
      return Scaffold(
        backgroundColor: context.background,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 56,
                    color: context.muted,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'بيانات الطلب غير متوفرة'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'يبدو أن صفحة تتبع الطلب فُتحت بدون تمرير بيانات الطلب.'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 140,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: context.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'رجوع'.tr,
                        style: TextStyle(
                          color: context.primaryForeground,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final steps = controller.buildTrackingSteps(order);

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          children: [
            const OrderTrackingHeader(),
            const SizedBox(height: 12),

            OrderTrackingSummaryCard(
              id: order.id,
              status: order.status,
              createdAt: order.createdAt,
              itemsCount: order.itemsCount,
              total: order.total,
              addressLine: order.addressLine,
              deliveryName: order.deliveryName,
              deliveryPhone: order.deliveryPhone,
            ),

            const SizedBox(height: 12),

            OrderTrackingEtaCard(
              icon: AppOrderUtils.statusIcon(order.status, trackingStyle: true),
              statusText: AppOrderUtils.statusLabel(order.status).tr,
              etaText: AppOrderUtils.etaText(order.status),
            ),

            const SizedBox(height: 16),

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
                child: OrderTimeline(steps: steps, currentStatus: order.status),
              ),
            ),

            const SizedBox(height: 16),

            OrderTrackingActions(
              canCancel: AppOrderUtils.canCancel(order.status),
              canReorder: AppOrderUtils.canReorder(order.status),
              showReview: order.status == 'delivered',
              onCancel: () {
                Get.snackbar('إلغاء الطلب'.tr, 'تم تنفيذ العملية تجريبيًا'.tr);
              },
              onHelpOrReorder: () {
                Get.snackbar('تم'.tr, 'Mock action'.tr);
              },
              onReview: () {
                ReviewDialog.show(
                  context,
                  title: 'Review',
                  userName: 'Zain Alzubair',
                  orderId: order.id,
                  onSubmit: (rating, comment) {
                    Get.snackbar('Done', 'Review submitted');
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
