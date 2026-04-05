import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class PaymentOptionTile extends StatelessWidget {
  final bool selected;
  final String title;
  final String subtitle;
  final IconData leadingIcon;
  final VoidCallback onTap;

  const PaymentOptionTile({
    super.key,
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final compact = c.maxWidth < 360;

        final bg = selected
            ? context.primary.withOpacity(context.isDark ? .18 : .12)
            : context.card;

        final borderColor = selected
            ? context.primary.withOpacity(.35)
            : context.border.withOpacity(.35);

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsetsDirectional.fromSTEB(
              compact ? 12 : 14,
              compact ? 10 : 12,
              compact ? 12 : 14,
              compact ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: context.shadow.withOpacity(context.isDark ? .08 : .05),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                _RadioLike(selected: selected, size: compact ? 20 : 22),
                const SizedBox(width: 10),
                Container(
                  width: compact ? 32 : 34,
                  height: compact ? 32 : 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: context.muted.withOpacity(
                      context.isDark ? .22 : .45,
                    ),
                    border: Border.all(color: context.border.withOpacity(.35)),
                  ),
                  child: Icon(
                    leadingIcon,
                    size: compact ? 18 : 19,
                    color: context.mutedForeground,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: compact ? 13.5 : 14.5,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontWeight: FontWeight.w600,
                          fontSize: compact ? 11.5 : 12.5,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _RadioLike extends StatelessWidget {
  final bool selected;
  final double size;

  const _RadioLike({
    required this.selected,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? context.primary : context.border.withOpacity(.55),
          width: 2,
        ),
      ),
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: selected ? size * .52 : 0,
          height: selected ? size * .52 : 0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.primary,
          ),
        ),
      ),
    );
  }
}