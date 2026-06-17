import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/constants/app_lottie_assets.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_toast.dart';
import 'package:rwnaqk/core/utils/app_order_utils.dart';
import 'package:rwnaqk/models/order_model.dart';
import 'package:rwnaqk/widgets/common/app_empty_state.dart';
import 'package:rwnaqk/widgets/dialogs/review_dialog.dart';
import 'package:rwnaqk/widgets/orders/order_timeline.dart';
import 'package:rwnaqk/widgets/orders/order_tracking_actions.dart';
import 'package:rwnaqk/widgets/orders/order_tracking_eta_card.dart';
import 'package:rwnaqk/widgets/orders/order_tracking_header.dart';
import 'package:rwnaqk/widgets/orders/order_tracking_summary_card.dart';

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
              child: AppEmptyState(
                icon: Icons.receipt_long_outlined,
                lottieAsset: EmptyStateLottieAssets.orders,
                title: Tk.ordersTrackingMissingTitle.tr,
                subtitle: Tk.ordersTrackingMissingMessage.tr,
                buttonText: Tk.commonBack.tr,
                onButtonPressed: Get.back,
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
              etaText: AppOrderUtils.etaText(order.status).tr,
            ),
            const SizedBox(height: 16),
            Text(
              Tk.ordersTrackingStatus.tr,
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
                AppToast.show(
                  context,
                  title: Tk.ordersActionCancel.tr,
                  message: Tk.commonMockAction.tr,
                  type: AppToastType.info,
                  duration: const Duration(seconds: 3),
                );
              },
              onHelpOrReorder: () {
                AppToast.show(
                  context,
                  title: Tk.commonDone.tr,
                  message: Tk.commonMockAction.tr,
                  type: AppToastType.success,
                  duration: const Duration(seconds: 3),
                );
              },
              onReview: () {
                ReviewDialog.show(
                  context,
                  title: Tk.reviewsDialogTitle.tr,
                  userName: 'Zain Alzubair',
                  orderId: order.id,
                  onSubmit: (_, __) {
                    AppToast.show(
                      context,
                      title: Tk.commonDone.tr,
                      message: Tk.reviewsSubmitted.tr,
                      type: AppToastType.success,
                      duration: const Duration(seconds: 3),
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
