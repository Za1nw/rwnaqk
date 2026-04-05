import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_date_utils.dart';
import 'package:rwnaqk/core/utils/app_money_utils.dart';
import 'package:rwnaqk/widgets/orders/order_status_pill.dart';

class OrderTrackingSummaryCard extends StatelessWidget {
  final String id;
  final String status;
  final DateTime createdAt;
  final int itemsCount;
  final double total;
  final String? addressLine;
  final String? deliveryName;
  final String? deliveryPhone;

  const OrderTrackingSummaryCard({
    super.key,
    required this.id,
    required this.status,
    required this.createdAt,
    required this.itemsCount,
    required this.total,
    this.addressLine,
    this.deliveryName,
    this.deliveryPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: context.border.withOpacity(.35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    id,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                OrderStatusPill(status: status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniInfo(
                  icon: Icons.calendar_month_outlined,
                  text: AppDateUtils.formatYmd(createdAt),
                ),
                const SizedBox(width: 12),
                _MiniInfo(
                  icon: Icons.shopping_bag_outlined,
                  text: Tk.ordersItemsCount.trParams({
                    'count': '$itemsCount',
                  }),
                ),
                const Spacer(),
                Text(
                  AppMoneyUtils.whole(total),
                  style: TextStyle(
                    color: context.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            if ((addressLine ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: context.muted,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      addressLine!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (((deliveryName ?? '').trim().isNotEmpty) ||
                ((deliveryPhone ?? '').trim().isNotEmpty)) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.input,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: context.border.withOpacity(.25)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 18,
                      color: context.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if ((deliveryName ?? '').trim().isNotEmpty)
                            Text(
                              deliveryName!,
                              style: TextStyle(
                                color: context.foreground,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.8,
                              ),
                            ),
                          if ((deliveryPhone ?? '').trim().isNotEmpty)
                            Text(
                              deliveryPhone!,
                              style: TextStyle(
                                color: context.muted,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniInfo extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MiniInfo({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: context.input,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: context.muted),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
