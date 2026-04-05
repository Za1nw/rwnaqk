import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/utils/app_order_utils.dart';

class OrderStatusPill extends StatelessWidget {
  final String status;

  const OrderStatusPill({super.key, required this.status});

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
        AppOrderUtils.statusLabel(status).tr,
        style: TextStyle(
          color: base.withOpacity(.95),
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}
