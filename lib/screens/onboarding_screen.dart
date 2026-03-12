import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';

import '../controllers/onboarding/onboarding_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/app_link_button.dart';
import '../widgets/app_toggles.dart';
import '../widgets/auth_blob_background.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // ✅ panel width responsive (no fixed 375x812)
    final panelMaxW = size.width < 420 ? size.width : 420.0;

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: AuthBlobBackground(
        child: _OnboardingShell(controller: controller),
        ),
      ),
    );
  }
}

/// =========================
/// SHELL (Top / Content / Bottom) - no overlaps
/// =========================
class _OnboardingShell extends StatelessWidget {
  final OnboardingController controller;

  const _OnboardingShell({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand( // ✅ يملأ الشاشة
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: context.card.withOpacity(context.isDark ? .62 : .48),
            // borderRadius: BorderRadius.circular(28),
            border: Border.all(color: context.border.withOpacity(.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(context.isDark ? .25 : .10),
                offset: const Offset(0, 18),
                blurRadius: 32,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              children: [
                _TopBar(controller: controller),
                const SizedBox(height: 10),
                Expanded(child: _Content(controller: controller)),
                const SizedBox(height: 14),
                _BottomBar(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
/// =========================
/// TOP BAR: Toggles + Skip (aligned, no stacking)
/// =========================
class _TopBar extends StatelessWidget {
  final OnboardingController controller;

  const _TopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppToggles(alignment: Alignment.centerLeft),
        const Spacer(),
        Obx(() {
          if (controller.isLast) {
            // ✅ keeps layout stable
            return const SizedBox(width: 86, height: 40);
          }
          return TextButton(
            onPressed: controller.onSkip,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              splashFactory: NoSplash.splashFactory,
              foregroundColor: context.mutedForeground,
            ),
            child: Text(
              'onboarding.skip'.tr,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          );
        }),
      ],
    );
  }
}

/// =========================
/// CONTENT: PageView only (centered, clean)
/// =========================
class _Content extends StatelessWidget {
  final OnboardingController controller;

  const _Content({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;

        // ✅ adaptive sizing based on available height
        final compact = h < 520;
        final iconSize = compact ? 108.0 : 140.0;
        final innerSize = compact ? 94.0 : 124.0;
        final titleSize = compact ? 26.0 : 30.0;
        final subSize = compact ? 13.8 : 15.0;

        return PageView.builder(
          controller: controller.pageCtrl,
          onPageChanged: controller.onPageChanged,
          itemCount: controller.slides.length,
          itemBuilder: (_, i) {
            final s = controller.slides[i];

            return _OnboardingPage(
              icon: s.icon,
              title: s.titleKey.tr,
              subtitle: s.subtitleKey.tr,
              iconWrap: iconSize,
              iconInner: innerSize,
              titleSize: titleSize,
              subtitleSize: subSize,
            );
          },
        );
      },
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  final double iconWrap;
  final double iconInner;
  final double titleSize;
  final double subtitleSize;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconWrap,
    required this.iconInner,
    required this.titleSize,
    required this.subtitleSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconBadge(
              icon: icon,
              size: iconWrap,
              inner: iconInner,
            ),
            const SizedBox(height: 20),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: context.foreground,
                height: 1.10,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: subtitleSize,
                  height: 1.55,
                  color: context.mutedForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge icon (clean + consistent)
class _IconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final double inner;

  const _IconBadge({
    required this.icon,
    required this.size,
    required this.inner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.card,
        border: Border.all(color: context.border.withOpacity(.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(context.isDark ? .08 : .55),
            offset: const Offset(-8, -8),
            blurRadius: 18,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(context.isDark ? .35 : .12),
            offset: const Offset(12, 12),
            blurRadius: 22,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: inner,
          height: inner,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.background.withOpacity(.12),
            border: Border.all(
              color: context.primary.withOpacity(.18),
              width: 1.2,
            ),
          ),
          child: Icon(
            icon,
            color: context.primary,
            size: inner * 0.52,
          ),
        ),
      ),
    );
  }
}

/// =========================
/// BOTTOM: Dots + Main button + Link
/// =========================
class _BottomBar extends StatelessWidget {
  final OnboardingController controller;

  const _BottomBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => _Dots(
            count: controller.slides.length,
            index: controller.pageIndex.value,
          ),
        ),
        const SizedBox(height: 14),
        Obx(
          () => AppButton(
            text: (controller.isLast
                    ? 'onboarding.get_started'
                    : 'onboarding.next')
                .tr,
            onPressed: controller.onNext,
          ),
        ),
        const SizedBox(height: 10),
        AppLinkButton(
          text: 'onboarding.have_account'.tr,
          onPressed: controller.onHaveAccount,
        ),
      ],
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsetsDirectional.only(end: 7),
          width: active ? 22 : 7,
          height: 7,
          decoration: BoxDecoration(
            color: active ? context.primary : context.border.withOpacity(.55),
            borderRadius: BorderRadius.circular(99),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: context.primary.withOpacity(.18),
                      offset: const Offset(0, 6),
                      blurRadius: 14,
                    ),
                  ]
                : [],
          ),
        );
      }),
    );
  }
}