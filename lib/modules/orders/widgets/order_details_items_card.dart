import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/widgets/order_details_section_card.dart';

class OrderDetailsItemsCard extends StatelessWidget {
  final List<OrderDetailsItem> items;

  const OrderDetailsItemsCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return OrderDetailsSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 18,
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
              ),
              const SizedBox(width: 8),
              Text(
                Tk.ordersDetailsItems.tr,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1E0A17),
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Cairo',
                ),
              ),
              const Spacer(),
              Text(
                '${items.length} منتجات',
                style: TextStyle(
                  color: isDark ? BrandColors.gold : BrandColors.burgundy,
                  fontWeight: FontWeight.w700,
                  fontSize: 11.5,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(items.length, (index) {
            final item = items[index];

            return Padding(
              padding: EdgeInsets.only(
                bottom: index == items.length - 1 ? 0 : 12,
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : const Color(0xFFF9F5F8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.06)
                        : BrandColors.burgundy.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            (isDark ? BrandColors.gold : BrandColors.burgundy)
                                .withValues(alpha: isDark ? 0.20 : 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.inventory_2_outlined,
                        color: isDark ? BrandColors.gold : BrandColors.burgundy,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1E0A17),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white60
                                  : const Color(0xFF6E5664),
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Tk.cartQty.trParams({'count': '${item.quantity}'}),
                            style: TextStyle(
                              color: isDark
                                  ? BrandColors.gold
                                  : BrandColors.burgundy,
                              fontWeight: FontWeight.w800,
                              fontSize: 11.5,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppMoneyUtils.riyal(item.lineTotal),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1E0A17),
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
