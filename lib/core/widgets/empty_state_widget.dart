import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/constants/app_dimensions.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// Reusable empty state display widget styled with Cairo font and brand colors.
class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? actionButton;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppDimensions.padding24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 72,
              color: context.mutedForeground.withValues(alpha: 0.5),
            ),
            AppDimensions.gapV16,
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTextTheme.fontFamily,
                fontSize: AppDimensions.font18,
                fontWeight: FontWeight.bold,
                color: context.foreground,
              ),
            ),
            if (subtitle != null) ...[
              AppDimensions.gapV8,
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTextTheme.fontFamily,
                  fontSize: AppDimensions.font14,
                  color: context.mutedForeground,
                ),
              ),
            ],
            if (actionButton != null) ...[
              AppDimensions.gapV24,
              actionButton!,
            ],
          ],
        ),
      ),
    );
  }
}
