import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/customer_profile_providers.dart';

/// ورقة اختيار مظهر التطبيق الفاخرة (Theme Mode Selection Bottom Sheet)
/// تتيح الاختيار بين: نهاري (فاتح)، ليلي (داكن)، أو تلقائي (حسب إعدادات الجهاز)
class ThemeModeSelectionSheet extends ConsumerWidget {
  const ThemeModeSelectionSheet({super.key});

  static Future<void> show(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E0D1B) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? BrandColors.gold.withValues(alpha: 0.25)
                : BrandColors.burgundy.withValues(alpha: 0.12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: const SafeArea(top: false, child: ThemeModeSelectionSheet()),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMode = ref.watch(appThemeModeProvider);
    final themeNotifier = ref.read(appThemeModeProvider.notifier);

    final themeOptions = [
      {
        'mode': ThemeMode.light,
        'title': 'الوضع النهاري (فاتح)',
        'subtitle': 'ألوان ناصعة ومشرقة لتصفح واضح بالنهار',
        'icon': Icons.light_mode_rounded,
      },
      {
        'mode': ThemeMode.dark,
        'title': 'الوضع الليلي (داكن)',
        'subtitle': 'ألوان عنابية ومخملية ملكية مريحة للعينين',
        'icon': Icons.dark_mode_rounded,
      },
      {
        'mode': ThemeMode.system,
        'title': 'تلقائي (حسب الجهاز)',
        'subtitle': 'يتزامن تلقائياً مع نظام تشغيل هاتفك',
        'icon': Icons.brightness_auto_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب العلوي
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // العنوان الرئيسي
          Text(
            'مظهر التطبيق • Theme Mode',
            style: AppTextTheme.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اختر النمط البصري المفضل لتجربة تسوق مريحة',
            style: AppTextTheme.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),

          // قائمة الخيارات الثلاثة
          ...themeOptions.map((opt) {
            final mode = opt['mode'] as ThemeMode;
            final isSelected = currentMode == mode;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ThemeOptionTile(
                title: opt['title'] as String,
                subtitle: opt['subtitle'] as String,
                icon: opt['icon'] as IconData,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  themeNotifier.setThemeMode(mode);
                  Navigator.pop(context);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? BrandColors.gold.withValues(alpha: 0.15)
                    : BrandColors.burgundy.withValues(alpha: 0.08))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                  : (isDark ? Colors.white12 : Colors.black12),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? BrandColors.gold : BrandColors.burgundy)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextTheme.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: AppTextTheme.cairo(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  color: isDark ? BrandColors.gold : BrandColors.burgundy,
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
