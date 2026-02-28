import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class QuantityStepper extends StatelessWidget {
  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  final int min;
  final int? max;

  final double? buttonSize;
  final double? height;
  final double? radius;

  const QuantityStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.min = 1,
    this.max,
    this.buttonSize,
    this.height,
    this.radius,
  });

  bool get _canDec => value > min;
  bool get _canInc => max == null ? true : value < (max!);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 150;

        final bs = buttonSize ?? (compact ? 30.0 : 33.0);
        final h = height ?? (compact ? 30.0 : 33.0);
        final r = radius ?? (compact ? 14.0 : 16.0);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _CircleBtn(
              icon: Icons.remove,
              size: bs,
              enabled: _canDec,
              onTap: _canDec ? onDecrement : null,
            ),
            const SizedBox(width: 5),

            Container(
              width: compact ? 20 : 25,
              height: h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.border.withOpacity(context.isDark ? .22 : .18),
                borderRadius: BorderRadius.circular(r),
              ),
              child: Text(
                '$value',
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 13 : 14,
                  height: 1.0,
                ),
              ),
            ),

            const SizedBox(width: 5),
            _CircleBtn(
              icon: Icons.add,
              size: bs,
              enabled: _canInc,
              onTap: _canInc ? onIncrement : null,
            ),
          ],
        );
      },
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool enabled;
  final VoidCallback? onTap;

  const _CircleBtn({
    required this.icon,
    required this.size,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? context.primary : context.mutedForeground;
    final border = enabled
        ? context.primary.withOpacity(.90)
        : context.border.withOpacity(.35);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 2.2),
        ),
        child: Icon(icon, color: color, size: size * 0.52),
      ),
    );
  }
}