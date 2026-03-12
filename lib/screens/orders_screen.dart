import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/widgets/common/app_empty_state.dart';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طلباتي'.tr,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                return OrdersFilterTabs(
                  value: controller.filter.value,
                  onChanged: controller.setFilter,
                );
              }),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  final list = controller.filteredOrders;

                  if (list.isEmpty) {
                    return const AppEmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'لا يوجد طلبات',
                      subtitle: 'ستظهر طلباتك هنا عند تنفيذ أي طلب جديد.',
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final o = list[i];

                      return OrderCard(
                        order: o,
                        onTap: () =>
                            Get.toNamed(AppRoutes.orderTracking, arguments: o),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}