import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';

class VipClubBanner extends StatelessWidget {
  const VipClubBanner({super.key});

  void _copyCoupon(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'RAWNAQ'));
    AppToast.copied(
      message:
          'تم نسخ الكود RAWNAQ بنجاح! سيتم تطبيق خصم 15% تلقائياً في السلة.',
      title: 'تم نسخ رمز الخصم',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF45021F),
                  BrandColors.burgundy,
                  const Color(0xFF1E000D),
                ]
              : [
                  const Color(0xFFFFF1F6),
                  const Color(0xFFFDE4ED),
                  const Color(0xFFF9D2E0),
                ],
        ),
        border: Border.all(
          color: BrandColors.gold.withValues(alpha: isDark ? 0.45 : 0.60),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.burgundy.withValues(alpha: isDark ? 0.35 : 0.12),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background luxury watermark ring
            PositionedDirectional(
              end: -25,
              bottom: -25,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BrandColors.gold.withValues(
                    alpha: isDark ? 0.08 : 0.12,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Crown VIP Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: BrandGradients.luxuryGold,
                      boxShadow: [
                        BoxShadow(
                          color: BrandColors.gold.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        color: Color(0xFF26141E),
                        size: 26,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Text Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              'نادي رونقك VIP',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : BrandColors.burgundy,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: BrandColors.gold,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'خصم 15%',
                                style: TextStyle(
                                  color: Color(0xFF26141E),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 9.5,
                                  fontFamily: 'Cairo',
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'استخدم الرمز RAWNAQ لتحصل على خصم فوري وشحن مجاني',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.85)
                                : context.foreground.withValues(alpha: 0.80),
                            fontWeight: FontWeight.w600,
                            fontSize: 10.5,
                            fontFamily: 'Cairo',
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Copy Coupon Button
                  InkWell(
                    onTap: () => _copyCoupon(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? BrandColors.gold : BrandColors.burgundy,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                (isDark
                                        ? BrandColors.gold
                                        : BrandColors.burgundy)
                                    .withValues(alpha: 0.28),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.copy_rounded,
                            size: 13,
                            color: isDark
                                ? const Color(0xFF26141E)
                                : Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'نسخ الكود',
                            style: TextStyle(
                              color: isDark
                                  ? const Color(0xFF26141E)
                                  : Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11,
                              fontFamily: 'Cairo',
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
