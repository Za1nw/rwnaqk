import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/theme/app_text_theme.dart';

/// ورقة اختيار لغة التطبيق الفاخرة (Luxury Language Selection Bottom Sheet)
class LanguageSelectionSheet extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = ref.watch(appLocaleProvider);
    final localeNotifier = ref.read(appLocaleProvider.notifier);

    final isArabic = currentLocale.languageCode == 'ar';
    final isEnglish = currentLocale.languageCode == 'en';

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
          _LanguageOptionTile(
            label: 'العربية',
            sublabel: 'اللغة العربية (الافتراضية)',
            symbol: 'ع',
            isSelected: isArabic,
            isDark: isDark,
            onTap: () {
              localeNotifier.setLocale(const Locale('ar', 'YE'));
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 10),

          // خيار اللغة الإنجليزية
          _LanguageOptionTile(
            label: 'English',
            sublabel: 'English (International Edition)',
            symbol: 'EN',
            isSelected: isEnglish,
            isDark: isDark,
            onTap: () {
              localeNotifier.setLocale(const Locale('en', 'US'));
              Navigator.pop(context);
            },
          ),
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
                child: Center(
                  child: Text(
                    symbol,
                    style: AppTextTheme.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextTheme.cairo(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      sublabel,
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
