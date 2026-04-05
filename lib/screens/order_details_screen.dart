import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_date_utils.dart';
import 'package:rwnaqk/models/order_model.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/common/app_back_header.dart';
import 'package:rwnaqk/widgets/orders/order_details_info_card.dart';
import 'package:rwnaqk/widgets/orders/order_details_items_card.dart';
import 'package:rwnaqk/widgets/orders/order_details_summary_card.dart';
import 'package:rwnaqk/widgets/orders/order_tracking_summary_card.dart';

class OrderDetailsScreen extends GetView<OrdersController> {
  const OrderDetailsScreen({super.key});

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
                    Tk.ordersTrackingMissingTitle.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Tk.ordersTrackingMissingMessage.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: context.muted,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final details = controller.buildOrderDetails(order);

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          children: [
            AppBackHeader(
              title: Tk.ordersDetailsTitle.tr,
              onBack: Get.back,
              trailingIcon: Icons.local_shipping_outlined,
              onTrailingTap: () => Get.toNamed(
                AppRoutes.orderTracking,
                arguments: order,
              ),
            ),
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
            OrderDetailsItemsCard(items: details.items),
            const SizedBox(height: 12),
            OrderDetailsInfoCard(
              title: Tk.ordersDetailsDeliveryInfo.tr,
              rows: [
                OrderDetailsInfoRow(
                  icon: Icons.person_outline_rounded,
                  label: Tk.addressesContactInformation.tr,
                  value: '${details.deliveryName}\n${details.deliveryPhone}',
                ),
                OrderDetailsInfoRow(
                  icon: Icons.location_on_outlined,
                  label: Tk.addressesShippingAddress.tr,
                  value: details.addressLine,
                ),
                OrderDetailsInfoRow(
                  icon: Icons.local_shipping_outlined,
                  label: Tk.cartPaymentShipping.tr,
                  value: details.shippingMethodKey.tr,
                ),
                OrderDetailsInfoRow(
                  icon: Icons.calendar_month_outlined,
                  label: Tk.ordersDetailsDate.tr,
                  value: AppDateUtils.formatYmd(order.createdAt),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OrderDetailsInfoCard(
              title: Tk.ordersDetailsPaymentInfo.tr,
              rows: [
                OrderDetailsInfoRow(
                  icon: Icons.payments_outlined,
                  label: Tk.cartPaymentMethod.tr,
                  value: details.paymentMethodKey.tr,
                ),
                OrderDetailsInfoRow(
                  icon: Icons.receipt_long_outlined,
                  label: Tk.ordersDetailsOrderId.tr,
                  value: order.id,
                ),
              ],
            ),
            const SizedBox(height: 12),
            OrderDetailsSummaryCard(
              subtotal: details.subtotal,
              shippingFee: details.shippingFee,
              total: details.total,
            ),
            const SizedBox(height: 16),
            AppButton(
              text: Tk.ordersDetailsTrackOrder.tr,
              icon: Icons.local_shipping_outlined,
              onPressed: () => Get.toNamed(
                AppRoutes.orderTracking,
                arguments: order,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
