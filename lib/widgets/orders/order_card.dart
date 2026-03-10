import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/models/order_model.dart';
import 'package:rwnaqk/core/utils/app_date_utils.dart';
import 'package:rwnaqk/core/utils/app_money_utils.dart';
import 'package:rwnaqk/core/utils/app_order_utils.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final id = order.id;
    final status = order.status;
    final total = order.total;
    final itemsCount = order.itemsCount;
    final createdAt = order.createdAt;
    final address = order.addressLine;

    final statusColor = AppOrderUtils.statusColor(context, status);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: context.border.withOpacity(.40)),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withOpacity(.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: context.primary.withOpacity(.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long_rounded,
                        color: context.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'طلب #$id',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.foreground,
                              fontWeight: FontWeight.w900,
                              fontSize: 14.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'تفاصيل الطلب وحالة الشحنة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.mutedForeground,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    _OrderStatusBadge(
                      label: AppOrderUtils.statusLabel(status),
                      icon: AppOrderUtils.statusIcon(status),
                      color: statusColor,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// Info row
                Row(
                  children: [
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.calendar_month_outlined,
                        text: AppDateUtils.formatYmd(createdAt),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _InfoChip(
                        icon: Icons.shopping_bag_outlined,
                        text: '$itemsCount منتجات',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// Total + arrow
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: context.primary.withOpacity(.10),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: context.primary.withOpacity(.16),
                        ),
                      ),
                      child: Text(
                        AppMoneyUtils.riyal(total),
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          height: 1,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: context.input,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.border.withOpacity(.35),
                        ),
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: context.mutedForeground,
                        size: 20,
                      ),
                    ),
                  ],
                ),

                if ((address ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: context.input.withOpacity(.55),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.border.withOpacity(.28),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: context.mutedForeground,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            address!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.mutedForeground,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.2,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _OrderStatusBadge({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 11.5,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: context.input.withOpacity(.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border.withOpacity(.28)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.mutedForeground),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.mutedForeground,
                fontWeight: FontWeight.w800,
                fontSize: 11.8,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
