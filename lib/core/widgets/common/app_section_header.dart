import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_action_icon_button.dart';

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
    this.titleFontSize = 17,
    this.titleFontWeight = FontWeight.w900,
    this.titleColor,
    this.actionFontSize = 13,
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
    final effectiveActionColor = actionColor ?? context.primary;

    final child = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
              letterSpacing: -0.2,
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (_hasTextAction)
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onActionTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText!,
                    style: TextStyle(
                      color: effectiveActionColor,
                      fontSize: actionFontSize,
                      fontWeight: actionFontWeight,
                    ),
                  ),
                  if (showArrowWithTextAction) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.chevron_left_rounded
                          : Icons.chevron_right_rounded,
                      color: effectiveActionColor,
                      size: 18,
                    ),
                  ],
                ],
              ),
            ),
          )
        else if (_hasIconAction)
          AppActionIconButton(icon: actionIcon!, onTap: onActionTap!)
        else if (reserveActionSpace)
          const SizedBox(width: 34, height: 34),
      ],
    );

    if (padding != null) {
      return Padding(padding: padding!, child: child);
    }

    return child;
  }
}
