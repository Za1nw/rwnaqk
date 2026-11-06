import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

/// شارة نص قابلة للإزالة (تستخدم عادة لعرض الاستعلام النشط).
class AppQueryChip extends StatelessWidget {
  final String text;
  final VoidCallback onRemove;

  const AppQueryChip({
    super.key,
    required this.text,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 6, 8, 6),
      decoration: BoxDecoration(
        color: context.input.withValues(alpha: context.isDark ? 0.65 : 1.0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              color: context.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 16, color: context.mutedForeground),
          ),
        ],
      ),
    );
  }
}