import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class OrderStatusPill extends StatelessWidget {
  final String status;
  const OrderStatusPill({super.key, required this.status});

  String get _label {
    switch (status) {
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
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDanger = status == 'canceled';
    final isSuccess = status == 'delivered';

    final base = isDanger
        ? context.destructive
        : (isSuccess ? Colors.green : context.primary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: base.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: base.withOpacity(.25)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: base.withOpacity(.95),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}