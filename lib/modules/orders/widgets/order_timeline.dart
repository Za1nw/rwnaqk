import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/utils/app_date_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_order_utils.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';

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
    final isDark = context.isDark;
    final primaryColor = isDark ? BrandColors.gold : BrandColors.burgundy;

    return Column(
      children: List.generate(steps.length, (i) {
        final step = steps[i];
        final done = AppOrderUtils.isStepDone(
          currentStatus: currentStatus,
          key: step.key,
        );
        final isCurrent = step.key == currentStatus;
        final isLast = i == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Node
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                        : (isDark
                              ? const Color(0xFF2E1728)
                              : const Color(0xFFEDE4E9)),
                    border: Border.all(
                      color: done
                          ? primaryColor
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.black.withValues(alpha: 0.12)),
                      width: 2,
                    ),
                    boxShadow: (done && isCurrent)
                        ? [
                            BoxShadow(
                              color: primaryColor.withValues(
                                alpha: isDark ? 0.40 : 0.25,
                              ),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      done ? Icons.check_rounded : Icons.circle,
                      size: done ? 14 : 6,
                      color: done
                          ? (isDark ? const Color(0xFF1E0A17) : Colors.white)
                          : (isDark ? Colors.white30 : Colors.black26),
                    ),
                  ),
                ),

                // Connecting Line
                if (!isLast)
                  Container(
                    width: 2.5,
                    height: 52,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: done
                          ? primaryColor.withValues(alpha: isDark ? 0.70 : 0.50)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.10)
                                : Colors.black.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title.tr,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E0A17),
                      fontWeight: done ? FontWeight.w900 : FontWeight.w700,
                      fontSize: 14,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  if ((step.subtitle ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle!.tr,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white60
                            : const Color(0xFF6E5664),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                        height: 1.3,
                      ),
                    ),
                  ],
                  if (step.time != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.formatYmdHm(step.time!),
                      style: TextStyle(
                        color: isDark
                            ? BrandColors.gold.withValues(alpha: 0.8)
                            : BrandColors.burgundy.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        fontFamily: 'Cairo',
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
