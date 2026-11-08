import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';

/// ورقة اختيار مظهر التطبيق الفاخرة (Theme Mode Selection Bottom Sheet)
/// تتيح الاختيار بين: نهاري (فاتح)، ليلي (داكن)، أو تلقائي (حسب إعدادات الجهاز)
class ThemeModeSelectionSheet extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final app = Get.find<AppSettingsController>();

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
        'title': 'تلقائي (حسب إعدادات الجهاز)',
        'subtitle': 'يتطابق المظهر تلقائياً مع نظام هاتفك',
        'icon': Icons.brightness_auto_rounded,
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مقبض السحب
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // العنوان
          Text(
            'المظهر ووضع العرض • Theme',
            style: AppTextTheme.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اختر النمط المفضل لعينيك لتجربة تسوق راقية',
            style: AppTextTheme.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),

          // الخيارات الثلاثة
          ...themeOptions.map((opt) {
            final mode = opt['mode'] as ThemeMode;
            final title = opt['title'] as String;
            final subtitle = opt['subtitle'] as String;
            final icon = opt['icon'] as IconData;

            return Obx(() {
              final isSelected = app.themeMode.value == mode;
              final activeBorderColor = isDark
                  ? BrandColors.gold
                  : BrandColors.burgundy;
              final activeBg = isDark
                  ? BrandColors.gold.withValues(alpha: 0.12)
                  : BrandColors.burgundy.withValues(alpha: 0.06);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      app.setThemeMode(mode);
                      Navigator.pop(context);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? activeBg : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? activeBorderColor
                              : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06)),
                          width: isSelected ? 1.6 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeBorderColor.withValues(alpha: 0.18)
                                  : (isDark
                                        ? Colors.white10
                                        : const Color(0xFFF2ECEF)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              icon,
                              size: 20,
                              color: isSelected
                                  ? activeBorderColor
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppTextTheme.cairo(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimaryLight,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  style: AppTextTheme.cairo(
                                    fontSize: 11,
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
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: activeBorderColor,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            });
          }),
        ],
      ),
    );
  }
}
