import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
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

        Color nodeBg;
        Color nodeBorder;
        Widget nodeContent;

        if (done && !isCurrent) {
          nodeBg = const Color(0xFF10B981);
          nodeBorder = const Color(0xFF10B981);
          nodeContent = const Icon(
            Icons.check_rounded,
            size: 14,
            color: Colors.white,
          );
        } else if (isCurrent) {
          nodeBg = isDark ? BrandColors.gold : BrandColors.burgundy;
          nodeBorder = isDark ? BrandColors.gold : BrandColors.burgundy;
          nodeContent = Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF1E0A17) : Colors.white,
              ),
            ),
          );
        } else {
          nodeBg = isDark
              ? Colors.white.withValues(alpha: 0.06)
              : const Color(0xFFEDE4E9);
          nodeBorder = context.border.withValues(alpha: isDark ? 0.35 : 0.45);
          nodeContent = Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.mutedForeground.withValues(alpha: 0.45),
              ),
            ),
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Node
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: nodeBg,
                    border: Border.all(color: nodeBorder, width: 2),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: nodeBg.withValues(alpha: 0.40),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(child: nodeContent),
                ),

                // Connecting Line
                if (!isLast)
                  Container(
                    width: 2.5,
                    height: 58,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: done
                          ? (isCurrent
                                ? primaryColor.withValues(alpha: 0.6)
                                : const Color(0xFF10B981))
                          : context.border.withValues(
                              alpha: isDark ? 0.20 : 0.35,
                            ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? primaryColor.withValues(alpha: isDark ? 0.12 : 0.06)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : const Color(0xFFFAF6F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCurrent
                        ? primaryColor.withValues(alpha: isDark ? 0.45 : 0.30)
                        : context.border.withValues(alpha: 0.20),
                    width: isCurrent ? 1.2 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            step.title.tr,
                            style: TextStyle(
                              color: isCurrent
                                  ? (isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy)
                                  : context.foreground,
                              fontWeight: isCurrent || done
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              fontSize: 13.5,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'المرحلة الحالية',
                              style: TextStyle(
                                color: isDark
                                    ? const Color(0xFF1E0A17)
                                    : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 9.5,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                      ],
                    ),
                    if ((step.subtitle ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        step.subtitle!.tr,
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.5,
                          fontFamily: 'Cairo',
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (step.time != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 12,
                            color: isDark
                                ? BrandColors.gold.withValues(alpha: 0.8)
                                : BrandColors.burgundy.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            AppDateUtils.formatYmdHm(step.time!),
                            style: TextStyle(
                              color: isDark
                                  ? BrandColors.gold.withValues(alpha: 0.85)
                                  : BrandColors.burgundy.withValues(
                                      alpha: 0.75,
                                    ),
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ],
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
