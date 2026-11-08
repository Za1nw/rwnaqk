import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// بطاقة مزايا العضوية الملكية ونادي رَوْنَقُك الخاص
class ProfileMembershipBanner extends StatelessWidget {
  final String tierName;
  final String discountText;

  const ProfileMembershipBanner({
    super.key,
    this.tierName = 'عضوية التميز الملكية (VIP Gold)',
    this.discountText = 'خصم 15% فوري وتوصيل مجاني لكافة طلباتك',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF381228),
                  const Color(0xFF220917),
                  const Color(0xFF16040F),
                ]
              : [
                  const Color(0xFF5A0227),
                  const Color(0xFF6E0131),
                  const Color(0xFF42001A),
                ],
        ),
        border: Border.all(
          color: BrandColors.gold.withValues(alpha: isDark ? 0.45 : 0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E0131)
                .withValues(alpha: isDark ? 0.40 : 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -10,
            bottom: -15,
            child: Icon(
              Icons.stars_rounded,
              size: 110,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: BrandColors.gold.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: BrandColors.gold.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: BrandColors.gold,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        tierName,
                        style: AppTextTheme.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: BrandColors.gold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'نشط ✓',
                        style: AppTextTheme.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  discountText,
                  style: AppTextTheme.cairo(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.95),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _PerkPill(
                      icon: Icons.flash_on_rounded,
                      text: 'توصيل مجاني فوري',
                    ),
                    const SizedBox(width: 8),
                    _PerkPill(
                      icon: Icons.card_giftcard_rounded,
                      text: 'هدايا وتغليف فاخر',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PerkPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _PerkPill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: BrandColors.gold),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextTheme.cairo(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}
