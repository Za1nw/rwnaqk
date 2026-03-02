import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart'; // عدّل المسار

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
    this.editIcon = Icons.edit_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final hasLines = lines.any((e) => e.trim().isNotEmpty);

    return Material(
      color: context.card,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.border.withOpacity(.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (hasLines)
                    ...lines.where((e) => e.trim().isNotEmpty).map(
                          (t) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Text(
                              t,
                              maxLines: maxLines,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context.mutedForeground,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
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
              // ✅ بدون ألوان مخصصة -> بياخذ نفس شكل الأيقونة اللي وريّتني
              AppActionIconButton(
                icon: editIcon,
                onTap: onEdit,
                size: 34,
                iconSize: 18,
                radius: 12,
              ),
            ],
          ],
        ),
      ),
    );
  }
}