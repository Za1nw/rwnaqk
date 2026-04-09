import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool outlined;
  final bool enabled;
  final bool isLoading;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.outlined = false,
    this.enabled = true,
    this.isLoading = false,
    this.height = 52,
  });

  @override
  Widget build(BuildContext context) {
    final bg =
        backgroundColor ?? (outlined ? Colors.transparent : context.primary);

    final fg = foregroundColor ??
        (outlined ? context.primary : context.primaryForeground);

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          disabledBackgroundColor:
              outlined ? Colors.transparent : bg.withOpacity(.55),
          disabledForegroundColor: fg.withOpacity(.80),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: outlined ? BorderSide(color: fg) : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(fg),
                ),
              ),
              const SizedBox(width: 10),
            ] else if (icon != null) ...[
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
