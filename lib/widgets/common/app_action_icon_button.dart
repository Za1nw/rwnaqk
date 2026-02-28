import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

/// زر أيقونة صغير موحّد للاستخدام داخل عناوين الأقسام أو الأدوات الجانبية.
class AppActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const AppActionIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.input.withOpacity(context.isDark ? 0.65 : 1.0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.border.withOpacity(0.45)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Icon(icon, size: 18, color: context.mutedForeground),
        ),
      ),
    );
  }
}
