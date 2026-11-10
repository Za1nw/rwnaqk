import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Flame Icon
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: BrandColors.burgundy.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.local_fire_department_rounded,
            color: BrandColors.burgundy,
            size: 18,
          ),
        ),
        const SizedBox(width: 6),

        // Title
        Text(
          Tk.homeFlashSale.tr,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 10),

        // Countdown Boxes
        _DigitalCountdown(hh: hh, mm: mm, ss: ss),

        const Spacer(),

        // See All action
        if (onSeeAll != null)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onSeeAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Tk.homeSeeAll.tr,
                    style: TextStyle(
                      color: context.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: context.primary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DigitalCountdown extends StatelessWidget {
  final int hh;
  final int mm;
  final int ss;

  const _DigitalCountdown({
    required this.hh,
    required this.mm,
    required this.ss,
  });

  String _format(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _TimeDigitCard(text: _format(hh)),
        _ColonSeparator(),
        _TimeDigitCard(text: _format(mm)),
        _ColonSeparator(),
        _TimeDigitCard(text: _format(ss)),
      ],
    );
  }
}

class _TimeDigitCard extends StatelessWidget {
  final String text;
  const _TimeDigitCard({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: BrandColors.burgundy,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: BrandColors.burgundy.withValues(alpha: 0.22),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          fontFamily: 'Cairo',
          height: 1.0,
        ),
      ),
    );
  }
}

class _ColonSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        ':',
        style: TextStyle(
          color: context.foreground,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          height: 1.0,
        ),
      ),
    );
  }
}
