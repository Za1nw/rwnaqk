import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/utils/app_date_utils.dart';
import 'package:rwnaqk/core/utils/app_order_utils.dart';
import 'package:rwnaqk/models/order_model.dart';

class OrderTimeline extends StatelessWidget {
  final List<OrderStatusStep> steps;
  final String currentStatus;

  const OrderTimeline({
    super.key,
    required this.steps,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final done = AppOrderUtils.isStepDone(
          currentStatus: currentStatus,
          key: step.key,
        );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title.tr,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                    ),
                  ),
                  if ((step.subtitle ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      step.subtitle!.tr,
                      style: TextStyle(
                        color: context.muted,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.2,
                      ),
                    ),
                  ],
                  if (step.time != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      AppDateUtils.formatYmdHm(step.time!),
                      style: TextStyle(
                        color: context.muted.withOpacity(.85),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
