import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/orders/models/orders_state.dart';

class OrdersFilterTabs extends StatelessWidget {
  final OrdersFilter value;
  final ValueChanged<OrdersFilter> onChanged;

  const OrdersFilterTabs({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget chip({
      required String text,
      required OrdersFilter v,
      required IconData icon,
    }) {
      final active = value == v;
      final activeColor = isDark ? BrandColors.gold : BrandColors.burgundy;
      final activeTextColor = isDark ? const Color(0xFF1E0A17) : Colors.white;

      return Semantics(
        button: true,
        selected: active,
        label: text,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onChanged(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? activeColor
                    : (isDark ? const Color(0xFF261422) : Colors.white),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active
                      ? activeColor
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : BrandColors.burgundy.withValues(alpha: 0.10)),
                  width: 1.2,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: activeColor.withValues(
                            alpha: isDark ? 0.35 : 0.22,
                          ),
                          offset: const Offset(0, 3),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 15,
                    color: active
                        ? activeTextColor
                        : (isDark ? Colors.white60 : const Color(0xFF6E5664)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active
                          ? activeTextColor
                          : (isDark ? Colors.white70 : const Color(0xFF6E5664)),
                      fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 12,
                      fontFamily: 'Cairo',
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF200F1E) : const Color(0xFFF7F1F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : BrandColors.burgundy.withValues(alpha: 0.06),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            chip(
              text: Tk.ordersFilterAll.tr,
              v: OrdersFilter.all,
              icon: Icons.grid_view_rounded,
            ),
            const SizedBox(width: 6),
            chip(
              text: Tk.ordersFilterActive.tr,
              v: OrdersFilter.active,
              icon: Icons.local_shipping_outlined,
            ),
            const SizedBox(width: 6),
            chip(
              text: Tk.ordersFilterDelivered.tr,
              v: OrdersFilter.delivered,
              icon: Icons.check_circle_outline_rounded,
            ),
            const SizedBox(width: 6),
            chip(
              text: Tk.ordersFilterCanceled.tr,
              v: OrdersFilter.canceled,
              icon: Icons.cancel_outlined,
            ),
          ],
        ),
      ),
    );
  }
}
