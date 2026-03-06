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

class _Filters extends StatelessWidget {
  final OrdersFilter value;
  final ValueChanged<OrdersFilter> onChanged;

  const _Filters({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    Widget chip({
      required String text,
      required OrdersFilter v,
      required IconData icon,
    }) {
      final active = value == v;

      final bg = active ? context.primary.withOpacity(.12) : context.card;
      final bd = active
          ? context.primary.withOpacity(.28)
          : context.border.withOpacity(.35);
      final fg = active ? context.primary : context.foreground;

      return Semantics(
        button: true,
        selected: active,
        label: text,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onChanged(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: bd),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: context.primary.withOpacity(.10),
                          offset: const Offset(0, 6),
                          blurRadius: 14,
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w900,
                      fontSize: 12.5,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ✅ تحطها داخل "كرت" خفيف يعطيها شكل احترافي مثل باقي التطبيق
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.border.withOpacity(.35)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            if (isRtl) const SizedBox(width: 2),

            chip(
              text: 'الكل'.tr,
              v: OrdersFilter.all,
              icon: Icons.grid_view_rounded,
            ),
            const SizedBox(width: 8),

            chip(
              text: 'نشطة'.tr,
              v: OrdersFilter.active,
              icon: Icons.timelapse_rounded,
            ),
            const SizedBox(width: 8),

            chip(
              text: 'مسلّمة'.tr,
              v: OrdersFilter.delivered,
              icon: Icons.check_circle_rounded,
            ),
            const SizedBox(width: 8),

            chip(
              text: 'ملغاة'.tr,
              v: OrdersFilter.canceled,
              icon: Icons.cancel_rounded,
            ),

            if (!isRtl) const SizedBox(width: 2),
          ],
        ),
      ),
    );
  }
}
