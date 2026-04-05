import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const AppLinkButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: context.mutedForeground,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),

            // Clay Circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.primary,
                boxShadow: [
                  // light shadow (top-left)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.4),
                    offset: const Offset(-2, -2),
                    blurRadius: 6,
                  ),
                  // dark shadow (bottom-right)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(3, 3),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: context.primaryForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}