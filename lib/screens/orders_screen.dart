import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/common/app_empty_state.dart';
import 'package:rwnaqk/widgets/common/app_page_header.dart';
import 'package:rwnaqk/widgets/orders/order_card.dart';
import 'package:rwnaqk/widgets/orders/orders_filter_tabs.dart';

class OrdersScreen extends GetView<OrdersController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 0),
          child: Obx(() {
            final list = controller.filteredOrders;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppPageHeader(
                  title: Tk.ordersTitle.tr,
                  info: '${list.length}',
                ),
                const SizedBox(height: 12),
                OrdersFilterTabs(
                  value: controller.filter.value,
                  onChanged: controller.setFilter,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: list.isEmpty
                      ? AppEmptyState(
                          icon: Icons.receipt_long_outlined,
                          title: Tk.ordersEmptyTitle.tr,
                          subtitle: Tk.ordersEmptySubtitle.tr,
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: list.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (_, i) {
                            final order = list[i];

                            return OrderCard(
                              order: order,
                              onTap: () => Get.toNamed(
                                AppRoutes.orderDetails,
                                arguments: order,
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
