import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';

/// ورقة اختيار لغة التطبيق الفاخرة (Luxury Language Selection Bottom Sheet)
class LanguageSelectionSheet extends StatelessWidget {
  const LanguageSelectionSheet({super.key});

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
        child: const SafeArea(top: false, child: LanguageSelectionSheet()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final app = Get.find<AppSettingsController>();

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

          // العنوان
          Text(
            'لغة التطبيق • App Language',
            style: AppTextTheme.cairo(
              fontSize: 16.5,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'اختر لغتك المفضلة للتسوق ومتابعة الطلبات',
            style: AppTextTheme.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),

          // خيار اللغة العربية
          Obx(() {
            final isArabic = app.locale.value.languageCode == 'ar';
            return _LanguageOptionTile(
              label: 'العربية',
              sublabel: 'اللغة العربية (الافتراضية)',
              symbol: 'ع',
              isSelected: isArabic,
              isDark: isDark,
              onTap: () {
                app.setLanguage('ar');
                Navigator.pop(context);
              },
            );
          }),

          const SizedBox(height: 10),

          // خيار اللغة الإنجليزية
          Obx(() {
            final isEnglish = app.locale.value.languageCode == 'en';
            return _LanguageOptionTile(
              label: 'English',
              sublabel: 'English (International Edition)',
              symbol: 'EN',
              isSelected: isEnglish,
              isDark: isDark,
              onTap: () {
                app.setLanguage('en');
                Navigator.pop(context);
              },
            );
          }),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final String symbol;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.label,
    required this.sublabel,
    required this.symbol,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBorderColor = isDark ? BrandColors.gold : BrandColors.burgundy;
    final activeBg = isDark
        ? BrandColors.gold.withValues(alpha: 0.12)
        : BrandColors.burgundy.withValues(alpha: 0.06);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              // رمز اللغة
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeBorderColor.withValues(alpha: 0.18)
                      : (isDark ? Colors.white10 : const Color(0xFFF2ECEF)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    symbol,
                    style: AppTextTheme.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? activeBorderColor
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // اسم اللغة ووصفها
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextTheme.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? Colors.white
                            : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      sublabel,
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

              // شارة التحديد
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
    );
  }
}
