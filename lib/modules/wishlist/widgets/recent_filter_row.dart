import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/wishlist/models/wishlist_state.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/widgets/recent_calendar_sheet.dart';

/// صف فلاتر المشاهدة الأخيرة لشاشة المفضلة [RecentFilterRow].
///
/// تمت هجرته إلى Riverpod 3 كـ ConsumerWidget مع إزالة أي Obx أو Get.find.
class RecentFilterRow extends ConsumerWidget {
  const RecentFilterRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wishlistProvider);
    final notifier = ref.read(wishlistProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final label = state.recentFilterLabel;
    final isDate = state.recentFilter == RecentFilter.date;

    final w = MediaQuery.sizeOf(context).width;
    final scale = (w / 390).clamp(.85, 1.0);

    final font = 12.0 * scale;
    final hp = 14.0 * scale;
    final vp = 8.0 * scale;
    final gap = 8.0 * scale;
    final iconSize = 18.0 * scale;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _Pill(
            text: Tk.wishlistFilterToday.tr,
            selected: state.recentFilter == RecentFilter.today,
            onTap: () => notifier.setRecentFilter(RecentFilter.today),
            fontSize: font,
            hp: hp,
            vp: vp,
            isDark: isDark,
          ),
          SizedBox(width: gap),
          _Pill(
            text: Tk.wishlistFilterYesterday.tr,
            selected: state.recentFilter == RecentFilter.yesterday,
            onTap: () => notifier.setRecentFilter(RecentFilter.yesterday),
            fontSize: font,
            hp: hp,
            vp: vp,
            isDark: isDark,
          ),
          SizedBox(width: gap),
          InkWell(
            onTap: () {
              AppNav.bottomSheet(
                child: RecentCalendarSheet(
                  initialDate: state.selectedDate,
                  onPick: (d) => notifier.chooseDate(d),
                ),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
              decoration: BoxDecoration(
                color: isDate
                    ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                          .withValues(alpha: isDark ? 0.22 : 0.12)
                    : (isDark ? const Color(0xFF24111F) : Colors.white),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDate
                      ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.12)
                            : BrandColors.burgundy.withValues(alpha: 0.10)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 110 * scale),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDate
                            ? (isDark
                                  ? BrandColors.gold
                                  : BrandColors.burgundy)
                            : (isDark
                                  ? Colors.white70
                                  : const Color(0xFF6E5664)),
                        fontWeight: FontWeight.w800,
                        fontSize: font,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                  SizedBox(width: 4 * scale),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: iconSize,
                    color: isDate
                        ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                        : (isDark ? Colors.white70 : const Color(0xFF6E5664)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  final double fontSize;
  final double hp;
  final double vp;
  final bool isDark;

  const _Pill({
    required this.text,
    required this.selected,
    required this.onTap,
    required this.fontSize,
    required this.hp,
    required this.vp,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hp, vertical: vp),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? BrandColors.gold : BrandColors.burgundy).withValues(
                  alpha: isDark ? 0.22 : 0.12,
                )
              : (isDark ? const Color(0xFF24111F) : Colors.white),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                : (isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : BrandColors.burgundy.withValues(alpha: 0.10)),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                : (isDark ? Colors.white70 : const Color(0xFF6E5664)),
            fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
            fontSize: fontSize,
            fontFamily: 'Cairo',
          ),
        ),
      ),
    );
  }
}
