import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class CartHeader extends StatelessWidget {
  final String title;
  final int? count;

  const CartHeader({super.key, required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return LayoutBuilder(
      builder: (_, c) {
        final compact = c.maxWidth < 360;

        final titleSize = compact ? 20.0 : 24.0;
        final badgeFont = compact ? 12.0 : 13.0;

        return Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF1E0A17),
                fontFamily: 'Cairo',
                height: 1.05,
              ),
            ),
            if (count != null) ...[
              const SizedBox(width: 10),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: compact ? 8 : 10,
                  vertical: compact ? 3 : 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? BrandColors.gold.withValues(alpha: 0.15)
                      : BrandColors.burgundy.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? BrandColors.gold.withValues(alpha: 0.25)
                        : BrandColors.burgundy.withValues(alpha: 0.20),
                  ),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: badgeFont,
                    color: isDark ? BrandColors.gold : BrandColors.burgundy,
                    fontFamily: 'Cairo',
                    height: 1.0,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
