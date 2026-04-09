import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

class AppBackHeader extends StatelessWidget {
  static const double _height = 40;

  final String title;
  final VoidCallback onBack;
  final VoidCallback? onTrailingTap;
  final IconData trailingIcon;

  const AppBackHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.onTrailingTap,
    this.trailingIcon = Icons.notifications_none_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: Row(
        children: [
          AppActionIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
            backgroundColor: context.card,
            iconColor: context.foreground,
            borderColor: context.border.withOpacity(.35),
            size: _height,
            radius: 14,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: context.foreground,
              ),
            ),
          ),
          AppActionIconButton(
            icon: trailingIcon,
            onTap: onTrailingTap ?? () {},
            backgroundColor: context.card,
            iconColor: context.foreground,
            borderColor: context.border.withOpacity(.35),
            size: _height,
            radius: 14,
          ),
        ],
      ),
    );
  }
}
