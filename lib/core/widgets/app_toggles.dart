import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/customer_profile_providers.dart';

class AppToggles extends ConsumerWidget {
  final Alignment alignment;

  /// التحكم في الأزرار
  final bool showLanguage;
  final bool showTheme;

  const AppToggles({
    super.key,
    this.alignment = Alignment.topRight,
    this.showLanguage = true,
    this.showTheme = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = context.isDark;
    final locale = ref.watch(appLocaleProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system && isDark);

    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark.withValues(alpha: 0.6)
                : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// زر اللغة
            if (showLanguage)
              _ToggleButton(
                icon: Icons.language_rounded,
                onTap: () {
                  final next = locale.languageCode == 'ar'
                      ? const Locale('en', 'US')
                      : const Locale('ar', 'YE');
                  ref.read(appLocaleProvider.notifier).setLocale(next);
                },
              ),

            /// مسافة فقط إذا كان الإثنان ظاهرين
            if (showLanguage && showTheme) const SizedBox(width: 6),

            /// زر الثيم
            if (showTheme)
              _ToggleButton(
                icon: isDarkMode
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                onTap: () {
                  ref.read(appThemeModeProvider.notifier).setThemeMode(
                        isDarkMode ? ThemeMode.light : ThemeMode.dark,
                      );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToggleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF190C18) : const Color(0xFFFAF7F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.borderDark.withValues(alpha: 0.5)
                : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(icon, size: 19, color: context.primary),
      ),
    );
  }
}
