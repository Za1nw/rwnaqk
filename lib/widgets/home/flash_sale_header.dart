import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/utils/app_date_utils.dart';

class FlashSaleHeader extends StatelessWidget {
  final int hh;
  final int mm;
  final int ss;
  final VoidCallback? onSeeAll;

  const FlashSaleHeader({
    super.key,
    required this.hh,
    required this.mm,
    required this.ss,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final timeText = AppDateUtils.formatTimer(hh: hh, mm: mm, ss: ss);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== Line 1: Title =====
        Text(
          'home.flash_sale'.tr,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 10),

        // ===== Line 2: Timer (left) + See all (right) =====
        LayoutBuilder(
          builder: (_, c) {
            final narrow = c.maxWidth < 360;

            return Row(
              children: [
                Expanded(
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _TimerPill(text: timeText, compact: narrow),
                  ),
                ),
                if (onSeeAll != null) ...[
                  const SizedBox(width: 10),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _SeeAllPill(onTap: onSeeAll!, compact: narrow),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _TimerPill extends StatelessWidget {
  final String text;
  final bool compact;

  const _TimerPill({required this.text, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 9,
      ),
      decoration: BoxDecoration(
        color: context.input.withOpacity(context.isDark ? 0.65 : 1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(context.isDark ? 0.14 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer_outlined,
            color: context.primary,
            size: compact ? 16 : 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
              fontSize: compact ? 12.5 : 13,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeeAllPill extends StatelessWidget {
  final VoidCallback onTap;
  final bool compact;

  const _SeeAllPill({required this.onTap, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: context.primary.withOpacity(context.isDark ? 0.16 : 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.primary.withOpacity(0.32)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 10 : 12,
              vertical: compact ? 8 : 9,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'home.see_all'.tr,
                  style: TextStyle(
                    color: context.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: compact ? 12.5 : 13,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: compact ? 16 : 18,
                  color: context.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
