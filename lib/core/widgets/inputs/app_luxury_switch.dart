import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

/// مفتاح تبديل فاخر وخفيف الوزن (Boutique Luxury Toggle Switch)
/// مصمم خصيصاً لهوية رَوْنَقُك ليحل محل المفاتيح النظامية الافتراضية
class AppLuxurySwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final Color? thumbColor;

  const AppLuxurySwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultActive =
        activeTrackColor ?? (isDark ? BrandColors.gold : BrandColors.burgundy);
    final defaultInactive =
        inactiveTrackColor ??
        (isDark ? const Color(0xFF33162A) : const Color(0xFFE5D8DF));
    final defaultThumb = thumbColor ?? Colors.white;

    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 48,
          height: 28,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: value ? defaultActive : defaultInactive,
            border: Border.all(
              color: value
                  ? (isDark
                        ? BrandColors.gold.withValues(alpha: 0.4)
                        : BrandColors.burgundy.withValues(alpha: 0.3))
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08)),
              width: 1,
            ),
            boxShadow: [
              if (value)
                BoxShadow(
                  color: (isDark ? BrandColors.gold : BrandColors.burgundy)
                      .withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: defaultThumb,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  value ? Icons.check_rounded : Icons.close_rounded,
                  size: 12,
                  color: value ? defaultActive : Colors.black38,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
