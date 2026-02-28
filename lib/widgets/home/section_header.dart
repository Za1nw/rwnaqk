import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        const Spacer(),
        if (actionText != null && onAction != null)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onAction,
            child: Row(
              children: [
                Text(
                  actionText!,
                  style: TextStyle(
                    color: context.mutedForeground,
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: context.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: context.shadow.withOpacity(context.isDark ? 0.20 : 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: context.primaryForeground,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
