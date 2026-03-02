import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class CartHeader extends StatelessWidget {
  final String title;
  final int? count;

  const CartHeader({
    super.key,
    required this.title,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final compact = c.maxWidth < 360;

        final titleSize = compact ? 22.0 : 26.0;
        final badgeFont = compact ? 12.5 : 13.5;

        return Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: context.foreground,
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
                  color: context.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.primary.withOpacity(.22),
                  ),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: badgeFont,
                    color: context.primary,
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