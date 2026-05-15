import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/app_settings/app_settings_controller.dart';
import '../core/constants/app_colors.dart';

class AppToggles extends GetView<AppSettingsController> {
  final Alignment alignment;
  final bool showLanguage;
  final bool showTheme;
  final Key? languageToggleKey;
  final Key? themeToggleKey;

  const AppToggles({
    super.key,
    this.alignment = Alignment.topRight,
    this.showLanguage = true,
    this.showTheme = true,
    this.languageToggleKey,
    this.themeToggleKey,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: context.card.withValues(
            alpha: context.isDark ? 0.82 : 0.92,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: context.border.withValues(
              alpha: context.isDark ? 0.65 : 0.9,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: context.isDark ? 0.24 : 0.08,
              ),
              offset: const Offset(0, 10),
              blurRadius: 22,
            ),
            BoxShadow(
              color: Colors.white.withValues(
                alpha: context.isDark ? 0.03 : 0.6,
              ),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLanguage)
              KeyedSubtree(
                key: languageToggleKey,
                child: Obx(
                  () => _LanguagePillToggle(
                    isArabic: controller.lang == 'ar',
                    onTap: controller.toggleLanguage,
                  ),
                ),
              ),
            if (showLanguage && showTheme) const SizedBox(width: 6),
            if (showTheme)
              KeyedSubtree(
                key: themeToggleKey,
                child: Obx(
                  () => _ThemePillToggle(
                    isDark: controller.themeMode.value == ThemeMode.dark,
                    onTap: controller.toggleTheme,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ToggleShell extends StatelessWidget {
  final double width;
  final double height;
  final bool toggled;
  final String semanticLabel;
  final VoidCallback onTap;
  final Widget child;

  const _ToggleShell({
    required this.width,
    required this.height,
    required this.toggled,
    required this.semanticLabel,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(height / 2);

    return Semantics(
      button: true,
      toggled: toggled,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: SizedBox(
            width: width,
            height: height,
            child: child,
          ),
        ),
      ),
    );
  }
}

class _ThemePillToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;

  const _ThemePillToggle({
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isDark ? 1 : 0),
      duration: const Duration(milliseconds: 760),
      curve: Curves.easeInOutCubic,
      builder: (context, progress, _) {
        final start = Color.lerp(
          const Color(0xFF7E97FF),
          const Color(0xFF082131),
          progress,
        )!;
        final end = Color.lerp(
          const Color(0xFFC1CBFF),
          const Color(0xFF144D57),
          progress,
        )!;
        final borderColor = Color.lerp(
          Colors.white.withValues(alpha: 0.8),
          const Color(0xFF133A44).withValues(alpha: 0.8),
          progress,
        )!;
        final shadowColor = Color.lerp(
          const Color(0x33284CC8),
          const Color(0x55010914),
          progress,
        )!;

        return _ToggleShell(
          width: 88,
          height: 44,
          toggled: isDark,
          semanticLabel: isDark ? 'Dark mode enabled' : 'Light mode enabled',
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [start, end],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderColor, width: 1.1),
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  offset: const Offset(0, 8),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 12,
                  top: 9,
                  child: Opacity(
                    opacity: 0.25 + (0.45 * progress),
                    child: const Icon(
                      Icons.nightlight_round,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 9,
                  child: Opacity(
                    opacity: 0.2 + (0.55 * (1 - progress)),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  left: 11,
                  top: 10,
                  child: Opacity(
                    opacity: progress,
                    child: const _SparkleCluster(),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 8,
                  child: Opacity(
                    opacity: 1 - progress,
                    child: const _CloudShape(width: 20, height: 9),
                  ),
                ),
                Positioned(
                  left: 26,
                  bottom: 7,
                  child: Opacity(
                    opacity: (1 - progress) * 0.82,
                    child: const _CloudShape(width: 14, height: 7),
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 760),
                  curve: Curves.easeInOutCubic,
                  alignment:
                      isDark ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: _ThemeKnob(progress: progress),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ThemeKnob extends StatelessWidget {
  final double progress;

  const _ThemeKnob({required this.progress});

  @override
  Widget build(BuildContext context) {
    final knobShadow = Color.lerp(
      const Color(0x44D18B2E),
      const Color(0x66000F1A),
      progress,
    )!;
    final knobTop = Color.lerp(
      const Color(0xFFFFE17B),
      const Color(0xFFF3F6FF),
      progress,
    )!;
    final knobBottom = Color.lerp(
      const Color(0xFFFFB84B),
      const Color(0xFFD4DCF8),
      progress,
    )!;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [knobTop, knobBottom],
        ),
        boxShadow: [
          BoxShadow(
            color: knobShadow,
            offset: const Offset(0, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 1 - progress,
              child: const Icon(
                Icons.wb_sunny_rounded,
                size: 18,
                color: Color(0xFFF59E0B),
              ),
            ),
            Opacity(
              opacity: progress,
              child: const Icon(
                Icons.nightlight_round,
                size: 18,
                color: Color(0xFF4C5D93),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Opacity(
                opacity: progress * 0.8,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguagePillToggle extends StatelessWidget {
  final bool isArabic;
  final VoidCallback onTap;

  const _LanguagePillToggle({
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isArabic ? 1 : 0),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
      builder: (context, progress, _) {
        final start = Color.lerp(
          const Color(0xFF4A67F5),
          const Color(0xFF113844),
          progress,
        )!;
        final end = Color.lerp(
          const Color(0xFF8CA3FF),
          const Color(0xFF1E5C66),
          progress,
        )!;
        final knobTop = Color.lerp(
          const Color(0xFFF7FAFF),
          const Color(0xFFDDF6F4),
          progress,
        )!;
        final knobBottom = Color.lerp(
          const Color(0xFFD9E3FF),
          const Color(0xFFB6E3DD),
          progress,
        )!;

        return _ToggleShell(
          width: 70,
          height: 44,
          toggled: isArabic,
          semanticLabel:
              isArabic ? 'Arabic language enabled' : 'English language enabled',
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [start, end],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.1,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 10,
                  top: 14,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isArabic ? 0.35 : 0.9,
                    child: const Text(
                      'AR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 14,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isArabic ? 0.9 : 0.35,
                    child: const Text(
                      'EN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 28,
                  child: Opacity(
                    opacity: 0.16 + (0.12 * progress),
                    child: const Icon(
                      Icons.translate_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeInOutCubic,
                  alignment:
                      isArabic ? Alignment.centerLeft : Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [knobTop, knobBottom],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          isArabic ? 'ع' : 'A',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color.lerp(
                              const Color(0xFF3855D6),
                              const Color(0xFF0C5E58),
                              progress,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CloudShape extends StatelessWidget {
  final double width;
  final double height;

  const _CloudShape({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: width * 0.18,
            right: 0,
            bottom: 0,
            child: Container(
              height: height * 0.62,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(height),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: height * 0.95,
              height: height * 0.95,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: width * 0.3,
            top: 0,
            child: Container(
              width: height * 1.05,
              height: height * 1.05,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.96),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleCluster extends StatelessWidget {
  const _SparkleCluster();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 5,
            child: _SparkleDot(size: 2.6),
          ),
          const Positioned(
            right: 2,
            top: 1,
            child: _SparkleDot(size: 3.2),
          ),
          Positioned(
            right: 0,
            bottom: 1,
            child: Container(
              width: 4.2,
              height: 4.2,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.86),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkleDot extends StatelessWidget {
  final double size;

  const _SparkleDot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        shape: BoxShape.circle,
      ),
    );
  }
}
