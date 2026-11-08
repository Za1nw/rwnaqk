import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_order_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/review_dialog.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_timeline.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_tracking_actions.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_tracking_courier_card.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_tracking_header.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_tracking_horizontal_progress.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_tracking_summary_card.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class OrderTrackingScreen extends GetView<OrdersController> {
  const OrderTrackingScreen({super.key});

  OrderModel? _getOrderFromArgs() {
    final args = Get.arguments;
    if (args is OrderModel) {
      return controller.orders.firstWhereOrNull((item) => item.id == args.id) ??
          args;
    }
    if (args is String) {
      return controller.orders.firstWhereOrNull((item) => item.id == args);
    }
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
                    color: context.mutedForeground,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    Tk.ordersTrackingMissingTitle.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Tk.ordersTrackingMissingMessage.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.mutedForeground,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 140,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: Get.back,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: context.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        Tk.commonBack.tr,
                        style: TextStyle(
                          color: context.primaryForeground,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Cairo',
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
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 30),
          children: [
            // 1. Prestigious Top Bar (Back + Title + Order ID + Status Pill)
            OrderTrackingHeader(orderId: order.id, status: order.status),

            const SizedBox(height: 14),

            // 2. Horizontal 4-Stage Connected Milestones Bar
            OrderTrackingHorizontalProgress(status: order.status),

            const SizedBox(height: 14),

            // 3. Live Courier & Estimated Delivery Card (Direct Call & Chat)
            OrderTrackingCourierCard(
              courierName: order.status == 'delivered'
                  ? 'وليد الصبري (تم التسليم بنجاح)'
                  : 'وليد الصبري',
              courierPhone: '+967 775 489 312',
              etaText: AppOrderUtils.etaText(order.status).tr,
            ),

            const SizedBox(height: 14),

            // 4. Order Information & Destination Summary Card
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

            const SizedBox(height: 18),

            // 5. Timeline Heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: context.isDark
                          ? BrandColors.gold
                          : BrandColors.burgundy,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    Tk.ordersTrackingStatus.tr,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 6. Chronological Checkpoints Timeline
            Container(
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: context.border.withValues(
                    alpha: context.isDark ? 0.35 : 0.45,
                  ),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.shadow.withValues(
                      alpha: context.isDark ? 0.16 : 0.04,
                    ),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: OrderTimeline(steps: steps, currentStatus: order.status),
            ),

            const SizedBox(height: 20),

            // 7. Order Tracking Actions (Cancel, Reorder, Help, Share, Invoice)
            OrderTrackingActions(
              canCancel: AppOrderUtils.canCancel(order.status),
              canReorder: AppOrderUtils.canReorder(order.status),
              showReview: order.status == 'delivered',
              orderId: order.id,
              onCancel: () {
                AppToast.info(
                  'تم تقديم طلب إلغاء الشحنة وسيقوم فريق العمل بالتواصل معك.',
                  title: 'طلب الإلغاء',
                );
              },
              onHelpOrReorder: () {
                if (AppOrderUtils.canReorder(order.status)) {
                  controller.openCart();
                } else {
                  Get.toNamed(AppRoutes.supportChat);
                }
              },
              onViewDetails: () {
                Get.toNamed(AppRoutes.orderDetails, arguments: order);
              },
              onReview: () {
                ReviewDialog.show(
                  context,
                  title: Tk.reviewsDialogTitle.tr,
                  userName: order.deliveryName ?? 'عميل رَوْنَقُك',
                  orderId: order.id,
                  onSubmit: (_, _) {
                    AppToast.success(
                      Tk.reviewsSubmitted.tr,
                      title: Tk.commonDone.tr,
                    );
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
