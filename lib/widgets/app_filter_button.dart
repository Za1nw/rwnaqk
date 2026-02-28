import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

class AppFilterButton extends StatelessWidget {
  final VoidCallback onTap;
  final double size;

  const AppFilterButton({
    super.key,
    required this.onTap,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border.withOpacity(0.45)),
          boxShadow: [
            BoxShadow(
              color: context.shadow.withOpacity(context.isDark ? 0.14 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Icon(
            Icons.tune_rounded,
            color: context.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}