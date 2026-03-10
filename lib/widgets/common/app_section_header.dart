import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;

  final String? actionText;
  final IconData? actionIcon;

  final VoidCallback? onActionTap;

  final double titleFontSize;
  final FontWeight titleFontWeight;
  final Color? titleColor;

  final double actionFontSize;
  final FontWeight actionFontWeight;
  final Color? actionColor;

  final bool showArrowWithTextAction;
  final bool reserveActionSpace;
  final EdgeInsetsGeometry? padding;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.actionIcon,
    this.onActionTap,
    this.titleFontSize = 16,
    this.titleFontWeight = FontWeight.w900,
    this.titleColor,
    this.actionFontSize = 12.5,
    this.actionFontWeight = FontWeight.w800,
    this.actionColor,
    this.showArrowWithTextAction = true,
    this.reserveActionSpace = false,
    this.padding,
  }) : assert(
          !(actionText != null && actionIcon != null),
          'Use either actionText or actionIcon, not both.',
        );

  bool get _hasTextAction =>
      actionText != null &&
      actionText!.trim().isNotEmpty &&
      onActionTap != null;

  bool get _hasIconAction => actionIcon != null && onActionTap != null;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: titleColor ?? context.foreground,
              fontSize: titleFontSize,
              fontWeight: titleFontWeight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (_hasTextAction)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onActionTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionText!,
                  style: TextStyle(
                    color: actionColor ?? context.mutedForeground,
                    fontSize: actionFontSize,
                    fontWeight: actionFontWeight,
                  ),
                ),
                if (showArrowWithTextAction) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: context.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: context.shadow.withOpacity(
                            context.isDark ? 0.20 : 0.10,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: context.primaryForeground,
                      size: 16,
                    ),
                  ),
                ],
              ],
            ),
          )
        else if (_hasIconAction)
          AppActionIconButton(
            icon: actionIcon!,
            onTap: onActionTap!,
          )
        else if (reserveActionSpace)
          const SizedBox(width: 34, height: 34),
      ],
    );

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: child,
      );
    }

    return child;
  }
}