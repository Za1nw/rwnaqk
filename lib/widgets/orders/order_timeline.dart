import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/models/order_model.dart';

class OrderTimeline extends StatelessWidget {
  final List<OrderStatusStep> steps;
  final String currentStatus;

  const OrderTimeline({
    super.key,
    required this.steps,
    required this.currentStatus,
  });

  bool _isDone(String key) {
    const order = ['pending', 'confirmed', 'shipped', 'delivered'];

    if (currentStatus == 'canceled') {
      return key == 'pending' || key == 'canceled';
    }

    final ci = order.indexOf(currentStatus);
    final ki = order.indexOf(key);

    if (ki == -1) return key == currentStatus;

    return ki <= ci;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final s = steps[i];
        final done = _isDone(s.key);
        final isLast = i == steps.length - 1;

        final dotColor = done ? context.primary : context.border;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    color: done ? context.primary : context.border,
                  ),
              ],
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    if ((s.subtitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        s.subtitle!,
                        style: TextStyle(
                          color: context.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}