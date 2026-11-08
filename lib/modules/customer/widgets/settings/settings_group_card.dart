import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// بطاقة تجميع عناصر الإعدادات في كتلة متناسقة وفاخرة
class SettingsGroupCard extends StatelessWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;

  const SettingsGroupCard({
    super.key,
    required this.title,
    this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان المجموعة
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 6, bottom: 8),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: isDark ? BrandColors.gold : BrandColors.burgundy,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: AppTextTheme.cairo(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),

        // حاوية العناصر النقية
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E0D1B) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? BrandColors.gold.withValues(alpha: 0.16)
                  : BrandColors.burgundy.withValues(alpha: 0.08),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.035),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: children.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 0.8,
              indent: 62, // يبدأ بعد أيقونة الحقل لمظهر أنيق
              endIndent: 16,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
            ),
            itemBuilder: (context, index) => children[index],
          ),
        ),
      ],
    );
  }
}
