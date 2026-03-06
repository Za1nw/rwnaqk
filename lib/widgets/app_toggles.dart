import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/app_settings_controller.dart';
import '../core/constants/app_colors.dart';

class AppToggles extends GetView<AppSettingsController> {
  final Alignment alignment;

  /// التحكم في الازرار
  final bool showLanguage;
  final bool showTheme;

  const AppToggles({
    super.key,
    this.alignment = Alignment.topRight,
    this.showLanguage = true,
    this.showTheme = true,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: context.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.primary.withOpacity(0.15),
              offset: const Offset(0, 4),
              blurRadius: 12,
            ),
            BoxShadow(
              color: context.primary.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// زر اللغة
            if (showLanguage)
              _ToggleButton(
                icon: Icons.language,
                onTap: controller.toggleLanguage,
              ),

            /// مسافة فقط إذا كان الاثنين ظاهرين
            if (showLanguage && showTheme) const SizedBox(width: 4),

            /// زر الثيم
            if (showTheme)
              Obx(() {
                final isDark =
                    controller.themeMode.value == ThemeMode.dark;

                return _ToggleButton(
                  icon: isDark ? Icons.dark_mode : Icons.light_mode,
                  onTap: controller.toggleTheme,
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.background,
              context.background.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: context.primary.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: context.primary.withOpacity(0.15),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              offset: const Offset(-2, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: context.primary,
        ),
      ),
    );
  }
}