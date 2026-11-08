import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class StorePerksStrip extends StatelessWidget {
  const StorePerksStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final perks = [
      _PerkItem(
        icon: Icons.flash_on_rounded,
        title: 'شحن سريع وآمن',
        subtitle: 'لكافة المحافظات',
        accentColor: BrandColors.gold,
      ),
      _PerkItem(
        icon: Icons.verified_rounded,
        title: 'أصلية 100%',
        subtitle: 'ماركات مضمونة',
        accentColor: const Color(0xFF22C55E),
      ),
      _PerkItem(
        icon: Icons.published_with_changes_rounded,
        title: 'استبدال مرن',
        subtitle: 'خلال 14 يوماً',
        accentColor: const Color(0xFF38BDF8),
      ),
      _PerkItem(
        icon: Icons.account_balance_wallet_rounded,
        title: 'دفع عند الاستلام',
        subtitle: 'ونقاط ومحافظ',
        accentColor: BrandColors.burgundy,
      ),
    ];

    return SizedBox(
      height: 58,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: perks.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final item = perks[i];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.border.withValues(
                  alpha: context.isDark ? 0.35 : 0.45,
                ),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.shadow.withValues(
                    alpha: context.isDark ? 0.12 : 0.04,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: item.accentColor.withValues(
                      alpha: context.isDark ? 0.18 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Center(
                    child: Icon(item.icon, size: 18, color: item.accentColor),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                        fontFamily: 'Cairo',
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        color: context.mutedForeground,
                        fontWeight: FontWeight.w600,
                        fontSize: 9.5,
                        fontFamily: 'Cairo',
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PerkItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;

  const _PerkItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });
}

