import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class OrderTrackingCourierCard extends StatelessWidget {
  final String courierName;
  final String courierPhone;
  final String etaText;

  const OrderTrackingCourierCard({
    super.key,
    this.courierName = 'وليد الصبري',
    this.courierPhone = '+967 775 489 312',
    this.etaText = 'خلال 35 إلى 50 دقيقة (اليوم قبل 06:00 م)',
  });

  void _callCourier(BuildContext context) {
    Clipboard.setData(ClipboardData(text: courierPhone));
    AppToast.copied(
      message: 'تم نسخ رقم هاتف المندوب ($courierPhone) إلى الحافظة بنجاح.',
      title: 'الاتصال بالمندوب',
    );
  }

  void _chatWithSupport() {
    AppNav.toNamed(AppRoutes.supportChat);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Delivery ETA
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: BrandColors.gold.withValues(
                    alpha: isDark ? 0.20 : 0.14,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  size: 20,
                  color: BrandColors.gold,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'موعد التسليم المتوقع',
                      style: TextStyle(
                        color: context.mutedForeground,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    Text(
                      etaText,
                      style: TextStyle(
                        color: context.foreground,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: context.border.withValues(alpha: 0.25)),
          const SizedBox(height: 14),

          // Courier Details
          Row(
            children: [
              // Courier Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: BrandGradients.royalBurgundy,
                  border: Border.all(
                    color: BrandColors.gold.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.two_wheeler_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          courierName,
                          style: TextStyle(
                            color: context.foreground,
                            fontWeight: FontWeight.w900,
                            fontSize: 13.5,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'كابتن معتمد ✓',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: BrandColors.gold,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '4.9',
                          style: TextStyle(
                            color: context.foreground,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• رَوْنَقُك إكسبريس السريع',
                          style: TextStyle(
                            color: context.mutedForeground,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.5,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Action Buttons: Call & Chat
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => _callCourier(context),
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: const Text(
                      'اتصال بالكابتن',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: _chatWithSupport,
                    icon: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 16,
                      color: context.primary,
                    ),
                    label: Text(
                      'محادثة مباشرة',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: context.foreground,
                        fontFamily: 'Cairo',
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: context.border.withValues(alpha: 0.45),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
