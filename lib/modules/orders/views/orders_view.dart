import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_card.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/orders_filter_tabs.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersProvider.notifier).loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final ordersState = ref.watch(ordersProvider);
    final filteredOrders = ordersState.filteredOrders;
    final count = filteredOrders.length;
    final cartCount = ref.watch(cartProvider).itemCount;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Row: Branded Title + Counter + Cart Button
              Row(
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
                      color: (isDark ? BrandColors.gold : BrandColors.burgundy)
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
                    onTap: () => AppNav.toNamed(AppRoutes.cart),
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
              ),

              const SizedBox(height: 14),

              // 2. Orders Filter Segmented Tabs
              OrdersFilterTabs(
                value: ordersState.filter,
                onChanged: (f) => ref.read(ordersProvider.notifier).setFilter(f),
              ),

              const SizedBox(height: 14),

              // 3. Orders List with 110dp bottom padding
              Expanded(
                child: ordersState.status == OrdersStatus.loading &&
                        ordersState.orders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : filteredOrders.isEmpty
                        ? _OrdersEmptyState(
                            onExplore: () => AppNav.toNamed(AppRoutes.main),
                          )
                        : ListView.separated(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(0, 4, 0, 110),
                            itemCount: filteredOrders.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 14),
                            itemBuilder: (_, i) {
                              final order = filteredOrders[i];
                              return OrderCard(
                                order: order,
                                onTap: () => AppNav.toNamed(
                                  AppRoutes.orderDetails,
                                  arguments: order,
                                ),
                              );
                            },
                          ),
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
                        .withValues(alpha: 0.14),
                    blurRadius: 18,
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
            const SizedBox(height: 18),
            Text(
              Tk.ordersEmptyTitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
                fontWeight: FontWeight.w900,
                fontSize: 18,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 6),
            Text(
              Tk.ordersEmptySubtitle.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark ? Colors.white60 : const Color(0xFF6E5664),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                fontFamily: 'Cairo',
                height: 1.4,
              ),
            ),
            const SizedBox(height: 22),
            InkWell(
              onTap: onExplore,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 11,
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
                      color: (isDark
                              ? const Color(0xFFFAAD01)
                              : const Color(0xFF6E0131))
                          .withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.storefront_outlined,
                      size: 17,
                      color: isDark ? const Color(0xFF1E0A17) : Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'تصفح المنتجات',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF1E0A17) : Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
