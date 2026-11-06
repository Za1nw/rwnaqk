import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_card.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/orders_filter_tabs.dart';

class OrdersScreen extends GetView<OrdersController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Row: Branded Title + Counter + Cart Button
              Obx(() {
                final count = controller.filteredOrders.length;
                final cartCount = Get.isRegistered<CartController>()
                    ? Get.find<CartController>().cartItems.length
                    : 0;

                return Row(
                  children: [
                    Text(
                      Tk.ordersTitle.tr,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E0A17),
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        fontFamily: 'Cairo',
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color:
                            (isDark ? BrandColors.gold : BrandColors.burgundy)
                                .withValues(alpha: isDark ? 0.20 : 0.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color:
                              (isDark ? BrandColors.gold : BrandColors.burgundy)
                                  .withValues(alpha: isDark ? 0.40 : 0.20),
                        ),
                      ),
                      child: Text(
                        '$count طلبات',
                        style: TextStyle(
                          color: isDark
                              ? BrandColors.gold
                              : BrandColors.burgundy,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: controller.openCart,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF261422)
                              : const Color(0xFFF7F1F5),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? BrandColors.gold.withValues(alpha: 0.25)
                                : BrandColors.burgundy.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.shopping_bag_outlined,
                              size: 21,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF261422),
                            ),
                            if (cartCount > 0)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFE53935),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 14),

              // 2. Orders Filter Segmented Tabs
              Obx(() {
                return OrdersFilterTabs(
                  value: controller.filter.value,
                  onChanged: controller.setFilter,
                );
              }),

              const SizedBox(height: 14),

              // 3. Orders List with 110dp bottom padding
              Expanded(
                child: Obx(() {
                  final list = controller.filteredOrders;

                  if (list.isEmpty) {
                    return _OrdersEmptyState(onExplore: controller.goToHome);
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(0, 4, 0, 110),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
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

class _OrdersEmptyState extends StatelessWidget {
  final VoidCallback onExplore;

  const _OrdersEmptyState({required this.onExplore});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Glowing Box Container
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                    .withValues(alpha: 0.12),
                border: Border.all(
                  color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                      .withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                        .withValues(alpha: isDark ? 0.25 : 0.10),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.receipt_long_outlined,
                  size: 40,
                  color: isDark ? BrandColors.gold : BrandColors.burgundy,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              Tk.ordersEmptyTitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
                fontWeight: FontWeight.w900,
                fontSize: 19,
                fontFamily: 'Cairo',
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Text(
              Tk.ordersEmptySubtitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF6E5664),
                fontWeight: FontWeight.w600,
                fontSize: 13,
                fontFamily: 'Cairo',
                height: 1.45,
              ),
            ),

            const SizedBox(height: 24),

            // Start Shopping Button
            InkWell(
              onTap: onExplore,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFFFAAD01), const Color(0xFFE59C00)]
                        : [const Color(0xFF8E0542), const Color(0xFF6E0131)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isDark
                                  ? const Color(0xFFFAAD01)
                                  : const Color(0xFF6E0131))
                              .withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: isDark ? const Color(0xFF1E0A17) : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ابدأ التسوق الآن',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF1E0A17) : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
