import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  String _statusLabel(String s) {
    switch (s) {
      case 'pending':
        return 'قيد المعالجة';
      case 'confirmed':
        return 'مؤكد';
      case 'shipped':
        return 'قيد التوصيل';
      case 'delivered':
        return 'تم التسليم';
      case 'canceled':
        return 'ملغي';
      default:
        return s;
    }
  }

  Color _statusColor(BuildContext context, String s) {
    if (s == 'canceled') return context.destructive;
    if (s == 'delivered') return Colors.green;
    return context.primary;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ عدّل هذه المابات حسب OrderModel عندك
    final id = order.id; // مثال
    final status = order.status; // مثال
    final total = order.total; // مثال double
    final itemsCount = order.itemsCount; // مثال int
    final createdAt = order.createdAt; // مثال DateTime
    final address = order.addressLine; // مثال String?

    final c = _statusColor(context, status);

    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: context.border.withOpacity(.35)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: c.withOpacity(.10),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: c.withOpacity(.25)),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: TextStyle(
                        color: c.withOpacity(.95),
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.calendar_month_outlined,
                      size: 18, color: context.muted),
                  const SizedBox(width: 6),
                  Text(
                    '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: context.muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.shopping_bag_outlined,
                      size: 18, color: context.muted),
                  const SizedBox(width: 6),
                  Text(
                    '$itemsCount items',
                    style: TextStyle(
                      color: context.muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.3,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    total.toStringAsFixed(0),
                    style: TextStyle(
                      color: context.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if ((address ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 18, color: context.muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: context.muted, size: 22),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}