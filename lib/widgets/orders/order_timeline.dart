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
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: dotColor.withOpacity(done ? 1 : .55),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 46,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: (done ? context.primary : context.border)
                          .withOpacity(.45),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.title,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                      ),
                    ),
                    if ((s.subtitle ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        s.subtitle!,
                        style: TextStyle(
                          color: context.muted,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.2,
                        ),
                      ),
                    ],
                    if (s.time != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${s.time!.year}/${s.time!.month.toString().padLeft(2, '0')}/${s.time!.day.toString().padLeft(2, '0')}  '
                        '${s.time!.hour.toString().padLeft(2, '0')}:${s.time!.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          color: context.muted.withOpacity(.85),
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
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