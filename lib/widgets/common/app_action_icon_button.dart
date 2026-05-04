import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

/// زر أيقونة موحّد
/// ✅ الاستدعاء والمنطق كما هو
/// ✅ الشكل الافتراضي: دائرة ناعمة بخلفية primary خفيفة + أيقونة primary
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
    final bg = backgroundColor ?? context.primary.withValues(alpha: .10);
    final ic = iconColor ?? context.primary;
    final bd = borderColor;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: bd != null ? Border.all(color: bd) : null,
          ),
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
