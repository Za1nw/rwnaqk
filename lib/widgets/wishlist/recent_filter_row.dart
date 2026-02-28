import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/controllers/wishlist_controller.dart';
import 'package:rwnaqk/widgets/wishlist/recent_calendar_sheet.dart';

class RecentFilterRow extends StatelessWidget {
  const RecentFilterRow({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<WishlistController>();

    return Obx(() {

      final label = c.recentFilterLabel();
      final isDate = c.recentFilter.value == RecentFilter.date;

      final w = MediaQuery.sizeOf(context).width;

      /// scale between 0.82 → 1
      final scale = (w / 390).clamp(.82, 1.0);

      final font = 12.8 * scale;
      final hp = 14.0 * scale;
      final vp = 10.0 * scale;
      final gap = 10.0 * scale;
      final iconSize = 20.0 * scale;

      return Row(
        children: [

          _Pill(
            text: 'Today',
            selected: c.recentFilter.value == RecentFilter.today,
            onTap: () => c.setRecentFilter(RecentFilter.today),
            fontSize: font,
            hp: hp,
            vp: vp,
          ),

          SizedBox(width: gap),

          _Pill(
            text: 'Yesterday',
            selected: c.recentFilter.value == RecentFilter.yesterday,
            onTap: () => c.setRecentFilter(RecentFilter.yesterday),
            fontSize: font,
            hp: hp,
            vp: vp,
          ),


          InkWell(
            onTap: () {
              Get.bottomSheet(
                RecentCalendarSheet(
                  initialDate: c.selectedDate.value,
                  onPick: (d) => c.chooseDate(d),
                ),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              );
            },
            borderRadius: BorderRadius.circular(999),
            child: Ink(
              padding: EdgeInsets.symmetric(
                horizontal: hp,
                vertical: vp,
              ),
              decoration: BoxDecoration(
                color: isDate
                    ? context.primary.withOpacity(0.12)
                    : context.card,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isDate
                      ? context.primary.withOpacity(0.35)
                      : context.border.withOpacity(0.35),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [

                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 110 * scale,
                    ),
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDate
                            ? context.primary
                            : context.mutedForeground,
                        fontWeight: FontWeight.w900,
                        fontSize: font,
                      ),
                    ),
                  ),

                  SizedBox(width: 6 * scale),

                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: iconSize,
                    color: isDate
                        ? context.primary
                        : context.mutedForeground,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _Pill extends StatelessWidget {

  final String text;
  final bool selected;
  final VoidCallback onTap;

  final double fontSize;
  final double hp;
  final double vp;

  const _Pill({
    required this.text,
    required this.selected,
    required this.onTap,
    required this.fontSize,
    required this.hp,
    required this.vp,
  });

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: EdgeInsets.symmetric(
          horizontal: hp,
          vertical: vp,
        ),
        decoration: BoxDecoration(
          color: selected
              ? context.primary.withOpacity(0.12)
              : context.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? context.primary.withOpacity(0.35)
                : context.border.withOpacity(0.35),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? context.primary
                : context.mutedForeground,
            fontWeight: FontWeight.w900,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
}