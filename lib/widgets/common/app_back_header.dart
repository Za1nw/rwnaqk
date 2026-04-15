import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

class AppBackHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onTrailingTap;
  final IconData trailingIcon;
  final bool showTrailing;
  final Widget? trailing;

  const AppBackHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.onTrailingTap,
    this.trailingIcon = Icons.notifications_none_rounded,
    this.showTrailing = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppActionIconButton(
          icon: Icons.arrow_back_rounded,
          onTap: onBack,
          backgroundColor: context.card,
          iconColor: context.foreground,
          borderColor: context.border.withOpacity(.35),
          size: 40,
          radius: 14,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: context.foreground,
            ),
          ),
        ),
        if (showTrailing)
          trailing ??
              AppActionIconButton(
                icon: trailingIcon,
                onTap: onTrailingTap ?? () {},
                backgroundColor: context.card,
                iconColor: context.foreground,
                borderColor: context.border.withOpacity(.35),
                size: 40,
                radius: 14,
              ),
      ],
    );
  }
}
