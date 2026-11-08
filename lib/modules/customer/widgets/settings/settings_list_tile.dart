import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// عنصر قائمة الإعدادات الملكي الموحد لتطبيق رَوْنَقُك
class SettingsListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final double trailingMaxWidth;
  final bool tapWholeTile;
  final bool showChevron;
  final bool enabled;
  final bool isDestructive;
  final Color? customAccentColor;

  const SettingsListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
    this.trailingMaxWidth = 160,
    this.tapWholeTile = true,
    this.showChevron = true,
    this.enabled = true,
    this.isDestructive = false,
    this.customAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final accent = customAccentColor ??
        (isDestructive
            ? (isDark ? const Color(0xFFFFB4AB) : const Color(0xFFB42318))
            : (isDark ? AppColors.gold : AppColors.burgundy));

    final effectiveChevron = showChevron && trailing == null;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          // أيقونة الحقل الملكية
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: accent.withValues(alpha: isDark ? 0.20 : 0.08),
              border: Border.all(
                color: accent.withValues(alpha: isDark ? 0.40 : 0.20),
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: accent,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // النصوص (العنوان + الوصف)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextTheme.cairo(
                    fontSize: 13.8,
                    fontWeight: FontWeight.w700,
                    color: isDestructive
                        ? accent
                        : (isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimaryLight),
                  ),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextTheme.cairo(
                      fontSize: 11.8,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),

          // العنصر التفاعلي على الطرف (Switch أو شارة)
          if (trailing != null)
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: trailingMaxWidth),
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: trailing!,
                ),
              ),
            ),

          // سهم الانتقال الموجه لليسار باللغة العربية
          if (effectiveChevron) ...[
            if (trailing != null) const SizedBox(width: 6),
            Icon(
              Icons.chevron_left_rounded, // في RTL يشير لليسار باتجاه التقدم
              size: 20,
              color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                  .withValues(alpha: 0.6),
            ),
          ],
        ],
      ),
    );

    if (!tapWholeTile || onTap == null || !enabled) {
      return Opacity(
        opacity: enabled ? 1.0 : 0.5,
        child: content,
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: accent.withValues(alpha: 0.08),
        highlightColor: accent.withValues(alpha: 0.04),
        child: content,
      ),
    );
  }
}
