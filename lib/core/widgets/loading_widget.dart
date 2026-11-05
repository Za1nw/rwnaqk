import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/constants/app_dimensions.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// Reusable centralized loading indicator with Cairo label and brand primary color.
class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(color ?? context.primary),
          ),
          if (message != null) ...[
            AppDimensions.gapV16,
            Text(
              message!,
              style: TextStyle(
                fontFamily: AppTextTheme.fontFamily,
                fontSize: AppDimensions.font14,
                color: context.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
