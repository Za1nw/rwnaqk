import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class OrderTrackingHorizontalProgress extends StatelessWidget {
  final String status;

  const OrderTrackingHorizontalProgress({super.key, required this.status});

  int get _currentStepIndex {
    switch (status.toLowerCase()) {
      case 'pending':
        return 0;
      case 'confirmed':
        return 1;
      case 'shipped':
        return 2;
      case 'delivered':
        return 3;
      case 'canceled':
        return -1;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isCanceled = status.toLowerCase() == 'canceled';

    if (isCanceled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444)
              .withValues(alpha: isDark ? 0.16 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        child: Row(
          children: const [
            Icon(Icons.cancel_outlined, color: Color(0xFFEF4444), size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'تم إلغاء هذا الطلب ولا يمكن مواصلة تتبعه.',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      );
    }

    final currentIndex = _currentStepIndex;

    final steps = [
      _MilestoneSpec(title: 'تم الاستلام', icon: Icons.receipt_long_rounded),
      _MilestoneSpec(title: 'التجهيز الفاخر', icon: Icons.inventory_2_rounded),
      _MilestoneSpec(title: 'في الطريق', icon: Icons.local_shipping_rounded),
      _MilestoneSpec(title: 'تم التسليم', icon: Icons.home_rounded),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: context.border.withValues(alpha: isDark ? 0.35 : 0.45),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withValues(alpha: isDark ? 0.16 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'مسار الشحنة المباشر',
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                  fontFamily: 'Cairo',
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'تحديث مباشر',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                // Connecting line
                final lineIndex = i ~/ 2;
                final isPassed = currentIndex > lineIndex;

                return Expanded(
                  child: Container(
                    height: 3,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: isPassed
                          ? const Color(0xFF10B981)
                          : context.border.withValues(
                              alpha: isDark ? 0.25 : 0.40,
                            ),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                );
              }

              // Step Circle and Label
              final stepIndex = i ~/ 2;
              final spec = steps[stepIndex];
              final isDone = stepIndex < currentIndex;
              final isCurrent = stepIndex == currentIndex;

              Color circleBg;
              Color circleBorder;
              Color iconColor;
              Color textColor;
              FontWeight textWeight;

              if (isDone) {
                circleBg = const Color(0xFF10B981);
                circleBorder = const Color(0xFF10B981);
                iconColor = Colors.white;
                textColor = context.foreground;
                textWeight = FontWeight.w700;
              } else if (isCurrent) {
                circleBg = isDark ? BrandColors.gold : BrandColors.burgundy;
                circleBorder = isDark ? BrandColors.gold : BrandColors.burgundy;
                iconColor = isDark ? const Color(0xFF26141E) : Colors.white;
                textColor = isDark ? BrandColors.gold : BrandColors.burgundy;
                textWeight = FontWeight.w900;
              } else {
                circleBg = isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF1E9EE);
                circleBorder = context.border.withValues(
                  alpha: isDark ? 0.30 : 0.40,
                );
                iconColor = context.mutedForeground.withValues(alpha: 0.6);
                textColor = context.mutedForeground;
                textWeight = FontWeight.w600;
              }

              return SizedBox(
                width: 62,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: circleBg,
                        shape: BoxShape.circle,
                        border: Border.all(color: circleBorder, width: 1.5),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: circleBg.withValues(alpha: 0.35),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: Colors.white,
                              )
                            : Icon(spec.icon, size: 16, color: iconColor),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      spec.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: textWeight,
                        color: textColor,
                        fontFamily: 'Cairo',
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MilestoneSpec {
  final String title;
  final IconData icon;

  const _MilestoneSpec({required this.title, required this.icon});
}
