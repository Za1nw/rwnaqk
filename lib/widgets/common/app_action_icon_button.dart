import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

/// زر أيقونة موحّد
/// ✅ الافتراضي = Primary background + White icon
/// ✅ يمكن override الألوان من مكان الاستدعاء
class AppActionIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  /// Optional overrides
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? iconColor;

  /// Size
  final double size;
  final double iconSize;
  final double radius;

  const AppActionIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.iconColor,
    this.size = 42,
    this.iconSize = 20,
    this.radius = 14,
  });

  @override
  Widget build(BuildContext context) {
    /// ✅ defaults (نفس تصميمك الحالي)
    final bg = backgroundColor ?? context.primary;
    final ic = iconColor ?? Colors.white;
    final bd = borderColor;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: bd != null ? Border.all(color: bd) : null,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: ic,
            ),
          ),
        ),
      ),
    );
  }
}