import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/common/app_action_icon_button.dart';

class EditableInfoCard extends StatelessWidget {
  final String title;
  final List<String> lines;
  final int maxLines;

  final VoidCallback? onEdit;
  final IconData editIcon;

  const EditableInfoCard({
    super.key,
    required this.title,
    required this.lines,
    this.maxLines = 2,
    this.onEdit,
    this.editIcon = Icons.edit_location_alt_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final hasLines = lines.any((e) => e.trim().isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF24111F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? BrandColors.gold.withValues(alpha: 0.16)
              : const Color(0xFFEDE3EA),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Pin Icon Container
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? BrandColors.gold.withValues(alpha: 0.12)
                    : BrandColors.burgundy.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on_rounded,
                size: 20,
                color: isDark ? BrandColors.gold : BrandColors.burgundy,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1E0A17),
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      fontFamily: 'Cairo',
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasLines)
                    ...lines
                        .where((e) => e.trim().isNotEmpty)
                        .map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              t,
                              maxLines: maxLines,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF6E5664),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                fontFamily: 'Cairo',
                                height: 1.25,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),

            if (onEdit != null) ...[
              const SizedBox(width: 10),
              AppActionIconButton(
                icon: editIcon,
                onTap: onEdit,
                size: 34,
                iconSize: 18,
                radius: 10,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
