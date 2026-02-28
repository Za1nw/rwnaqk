import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

/// عنوان صف بسيط مع زر إجراء في الطرف.
class AppRowHeader extends StatelessWidget {
  final String title;
  final IconData actionIcon;
  final VoidCallback onActionTap;

  const AppRowHeader({
    super.key,
    required this.title,
    required this.actionIcon,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.mutedForeground,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        AppActionIconButton(
          icon: actionIcon,
          onTap: onActionTap,
        ),
      ],
    );
  }
}
