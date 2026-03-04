import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/controllers/orders_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/widgets/orders/order_card.dart';

class OrdersScreen extends GetView<OrdersController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(18, 12, 18, 18),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'طلباتي'.tr,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Obx(() {
                return _Filters(
                  value: controller.filter.value,
                  onChanged: controller.setFilter,
                );
              }),
              const SizedBox(height: 12),

              Expanded(
                child: Obx(() {
                  final list = controller.filteredOrders;

                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        'لا يوجد طلبات حالياً'.tr,
                        style: TextStyle(
                          color: context.muted,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) {
                      final o = list[i]; // <- OrderModel
                      return OrderCard(
                        order: o,
                        onTap: () => Get.toNamed(
                          AppRoutes.orderTracking,
                          arguments: o,
                        ),
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

class _Filters extends StatelessWidget {
  final OrdersFilter value;
  final ValueChanged<OrdersFilter> onChanged;

  const _Filters({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    Widget chip(String text, OrdersFilter v) {
      final active = value == v;
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onChanged(v),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? context.primary.withOpacity(.12) : context.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: active
                  ? context.primary.withOpacity(.28)
                  : context.border.withOpacity(.35),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? context.primary : context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: 12.5,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          chip('الكل'.tr, OrdersFilter.all),
          const SizedBox(width: 8),
          chip('نشطة'.tr, OrdersFilter.active),
          const SizedBox(width: 8),
          chip('مسلّمة'.tr, OrdersFilter.delivered),
          const SizedBox(width: 8),
          chip('ملغاة'.tr, OrdersFilter.canceled),
        ],
      ),
    );
  }
}