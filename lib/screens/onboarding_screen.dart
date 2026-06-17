import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';

import '../controllers/onboarding/onboarding_controller.dart';
import '../controllers/onboarding/onboarding_service.dart';

const double _kCompactHeightBreakpoint = 760;
const double _kCompactWidthBreakpoint = 370;
const double _kHorizontalPaddingCompact = 16;
const double _kHorizontalPaddingRegular = 22;
const double _kHeroMaxWidth = 352;
const double _kTextMaxWidth = 288;
const Duration _kMotionDuration = Duration(milliseconds: 220);

double _clampValue(double value, double min, double max) {
  return value.clamp(min, max).toDouble();
}

double _resolveCurrentPage(OnboardingController controller) {
  if (!controller.pageCtrl.hasClients) {
    return controller.pageIndex.value.toDouble();
  }

  return controller.pageCtrl.page ?? controller.pageIndex.value.toDouble();
}

class _HeroPalette {
  final Color shellTop;
  final Color shellBottom;
  final Color shellBorder;
  final Color shellGlow;
  final Color shellGlowSoft;
  final Color sceneBackdropTop;
  final Color sceneBackdropBottom;
  final Color floatSurface;
  final Color floatAccentSurface;
  final Color floatBorder;
  final Color floatAccentBorder;
  final Color panelSurface;
  final Color panelBorder;
  final Color chipSurface;
  final Color chipAccentSurface;
  final Color chipBorder;
  final Color chipAccentBorder;
  final Color showcaseSurface;
  final Color showcaseBorder;
  final Color actionSurface;
  final Color actionBorder;
  final Color sparkSurface;
  final Color sparkSoftSurface;
  final Color sparkBorder;
  final Color softTrack;

  const _HeroPalette({
    required this.shellTop,
    required this.shellBottom,
    required this.shellBorder,
    required this.shellGlow,
    required this.shellGlowSoft,
    required this.sceneBackdropTop,
    required this.sceneBackdropBottom,
    required this.floatSurface,
    required this.floatAccentSurface,
    required this.floatBorder,
    required this.floatAccentBorder,
    required this.panelSurface,
    required this.panelBorder,
    required this.chipSurface,
    required this.chipAccentSurface,
    required this.chipBorder,
    required this.chipAccentBorder,
    required this.showcaseSurface,
    required this.showcaseBorder,
    required this.actionSurface,
    required this.actionBorder,
    required this.sparkSurface,
    required this.sparkSoftSurface,
    required this.sparkBorder,
    required this.softTrack,
  });

  factory _HeroPalette.of(BuildContext context) {
    return _HeroPalette(
      shellTop: Color.lerp(
        context.card,
        context.background,
        context.isDark ? 0.16 : 0.08,
      )!,
      shellBottom: Color.lerp(
        context.card,
        context.primary,
        context.isDark ? 0.06 : 0.02,
      )!,
      shellBorder: context.border.withValues(
        alpha: context.isDark ? 0.72 : 0.64,
      ),
      shellGlow: Color.lerp(context.primary, context.background, 0.96)!,
      shellGlowSoft: Color.lerp(context.primary, context.background, 0.98)!,
      sceneBackdropTop: Color.lerp(
        context.background,
        context.primary,
        context.isDark ? 0.12 : 0.04,
      )!,
      sceneBackdropBottom: Color.lerp(
        context.card,
        context.background,
        context.isDark ? 0.18 : 0.08,
      )!,
      floatSurface: context.background.withValues(
        alpha: context.isDark ? 0.38 : 0.86,
      ),
      floatAccentSurface: Color.lerp(context.accent, context.background, 0.1)!,
      floatBorder: context.border.withValues(
        alpha: context.isDark ? 0.46 : 0.28,
      ),
      floatAccentBorder: context.primary.withValues(
        alpha: context.isDark ? 0.22 : 0.1,
      ),
      panelSurface: context.background.withValues(
        alpha: context.isDark ? 0.48 : 0.9,
      ),
      panelBorder: context.border.withValues(
        alpha: context.isDark ? 0.42 : 0.24,
      ),
      chipSurface: context.background.withValues(
        alpha: context.isDark ? 0.46 : 0.94,
      ),
      chipAccentSurface: Color.lerp(context.accent, context.background, 0.16)!,
      chipBorder: context.border.withValues(
        alpha: context.isDark ? 0.38 : 0.24,
      ),
      chipAccentBorder: context.primary.withValues(
        alpha: context.isDark ? 0.22 : 0.14,
      ),
      showcaseSurface: Color.lerp(
        context.card,
        context.background,
        context.isDark ? 0.2 : 0.52,
      )!,
      showcaseBorder: context.border.withValues(
        alpha: context.isDark ? 0.34 : 0.22,
      ),
      actionSurface: context.background.withValues(
        alpha: context.isDark ? 0.42 : 0.9,
      ),
      actionBorder: context.border.withValues(
        alpha: context.isDark ? 0.42 : 0.24,
      ),
      sparkSurface: context.background.withValues(
        alpha: context.isDark ? 0.54 : 0.94,
      ),
      sparkSoftSurface: Color.lerp(
        context.secondary,
        context.background,
        context.isDark ? 0.24 : 0.12,
      )!,
      sparkBorder: context.border.withValues(
        alpha: context.isDark ? 0.42 : 0.34,
      ),
      softTrack: context.border.withValues(alpha: 0.62),
    );
  }
}

class _SlideMetrics {
  final double heroHeight;
  final double heroArtworkExtent;
  final double sceneExtent;
  final double titleSize;
  final double subtitleSize;
  final double heroBottomGap;
  final double dotsBottomGap;
  final double textGap;
  final bool compact;

  const _SlideMetrics({
    required this.heroHeight,
    required this.heroArtworkExtent,
    required this.sceneExtent,
    required this.titleSize,
    required this.subtitleSize,
    required this.heroBottomGap,
    required this.dotsBottomGap,
    required this.textGap,
    required this.compact,
  });

  factory _SlideMetrics.fromConstraints(
    BoxConstraints constraints,
    bool compact,
  ) {
    final contentScale = _clampValue(
      constraints.maxHeight / (compact ? 340 : 408),
      0.72,
      1,
    );

    return _SlideMetrics(
      heroHeight: _clampValue(
        constraints.maxHeight * (compact ? 0.54 : 0.58),
        compact ? 130 : 146,
        compact ? 232 : 278,
      ),
      heroArtworkExtent: compact ? 304 : 330,
      sceneExtent: compact ? 260 : 282,
      titleSize: lerpDouble(16.6, compact ? 19.8 : 21.8, contentScale)!,
      subtitleSize: lerpDouble(10.6, compact ? 11.5 : 12.6, contentScale)!,
      heroBottomGap: lerpDouble(8, compact ? 11 : 14, contentScale)!,
      dotsBottomGap: lerpDouble(6, compact ? 8 : 10, contentScale)!,
      textGap: lerpDouble(6, compact ? 7 : 9, contentScale)!,
      compact: compact,
    );
  }

  double resolveTextScale(double maxHeight) {
    return _clampValue(maxHeight / (compact ? 108 : 122), 0.84, 1);
  }
}

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.slides.isEmpty) {
      return Scaffold(
        backgroundColor: context.background,
        body: Center(
          child: Text(
            Tk.appName.tr,
            style: TextStyle(
              color: context.foreground,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: context.background,
      body: Stack(
        children: [
          PositionedDirectional(
            top: -120,
            start: -60,
            child: _BackgroundGlow(
              size: 240,
              color: Color.lerp(context.primary, context.background, 0.92)!,
            ),
          ),
          PositionedDirectional(
            bottom: -160,
            end: -80,
            child: _BackgroundGlow(
              size: 280,
              color: Color.lerp(context.primary, context.background, 0.96)!,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact =
                    constraints.maxHeight < _kCompactHeightBreakpoint ||
                        constraints.maxWidth < _kCompactWidthBreakpoint;
                final horizontalPadding = compact
                    ? _kHorizontalPaddingCompact
                    : _kHorizontalPaddingRegular;

                return Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    compact ? 8 : 12,
                    horizontalPadding,
                    compact ? 16 : 20,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: compact ? 10 : 14),
                      _BrandLockup(compact: compact),
                      SizedBox(height: compact ? 10 : 14),
                      Expanded(
                        child: _OnboardingPager(
                          controller: controller,
                          compact: compact,
                        ),
                      ),
                      SizedBox(height: compact ? 14 : 18),
                      _BottomBar(controller: controller, compact: compact),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandLockup extends StatelessWidget {
  final bool compact;

  const _BrandLockup({required this.compact});

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 34.0 : 40.0;
    final iconBackground = Color.lerp(context.card, context.primary, 0.04)!;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: iconSize,
          height: iconSize,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.border.withValues(alpha: 0.72),
            ),
          ),
          child: Icon(
            Icons.shopping_bag_rounded,
            color: context.primary,
            size: compact ? 18 : 20,
          ),
        ),
        const SizedBox(width: 9),
        Text(
          Tk.appName.tr,
          style: TextStyle(
            color: context.foreground,
            fontSize: compact ? 18 : 21,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.25,
          ),
        ),
      ],
    );
  }
}

class _OnboardingPager extends StatelessWidget {
  final OnboardingController controller;
  final bool compact;

  const _OnboardingPager({required this.controller, required this.compact});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      allowImplicitScrolling: true,
      controller: controller.pageCtrl,
      onPageChanged: controller.onPageChanged,
      itemCount: controller.slides.length,
      itemBuilder: (_, index) {
        return _OnboardingSlidePage(
          controller: controller,
          slide: controller.slides[index],
          slideIndex: index,
          compact: compact,
        );
      },
    );
  }
}

class _OnboardingSlidePage extends StatelessWidget {
  final OnboardingController controller;
  final OnboardingSlide slide;
  final int slideIndex;
  final bool compact;

  const _OnboardingSlidePage({
    required this.controller,
    required this.slide,
    required this.slideIndex,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _SlideMetrics.fromConstraints(constraints, compact);

        return AnimatedBuilder(
          animation: controller.pageCtrl,
          builder: (context, _) {
            final currentPage = _resolveCurrentPage(controller);
            final delta = currentPage - slideIndex;
            final distance = delta.abs().clamp(0.0, 1.0).toDouble();
            final reveal = 1 - distance;

            return Column(
              children: [
                SizedBox(
                  height: metrics.heroHeight,
                  child: Center(
                    child: Opacity(
                      opacity: lerpDouble(0.78, 1, reveal)!,
                      child: Transform.translate(
                        offset: Offset(delta * 10, lerpDouble(18, 0, reveal)!),
                        child: Transform.scale(
                          scale: lerpDouble(0.94, 1, reveal)!,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: _kHeroMaxWidth),
                            child: SizedBox(
                              width: metrics.heroArtworkExtent,
                              height: metrics.heroArtworkExtent,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: metrics.heroArtworkExtent,
                                  height: metrics.heroArtworkExtent,
                                  child: _OnboardingHeroPlaceholder(
                                    icon: slide.icon,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: metrics.heroBottomGap),
                Obx(
                  () => _Dots(
                    count: controller.slides.length,
                    index: controller.pageIndex.value,
                  ),
                ),
                SizedBox(height: metrics.dotsBottomGap),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, textConstraints) {
                      final textScale = metrics.resolveTextScale(
                        textConstraints.maxHeight,
                      );

                      return Center(
                        child: Transform.translate(
                          offset: Offset(0, lerpDouble(10, 0, reveal)!),
                          child: Opacity(
                            opacity: lerpDouble(0.7, 1, reveal)!,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: _kTextMaxWidth,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    slide.titleKey.tr,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.foreground,
                                      fontSize: metrics.titleSize * textScale,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                      height: 1.12,
                                    ),
                                  ),
                                  SizedBox(height: metrics.textGap),
                                  Text(
                                    slide.subtitleKey.tr,
                                    textAlign: TextAlign.center,
                                    maxLines: compact ? 3 : 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.mutedForeground,
                                      fontSize:
                                          metrics.subtitleSize * textScale,
                                      fontWeight: FontWeight.w600,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _OnboardingHeroPlaceholder extends StatelessWidget {
  final IconData icon;

  const _OnboardingHeroPlaceholder({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.card.withValues(alpha: context.isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: context.border.withValues(alpha: 0.22),
          width: 1.2,
        ),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 52,
          color: context.primary.withOpacity(0.8),
        ),
      ),
    );
  }
}

class _DiscoveryScene extends StatelessWidget {
  final IconData icon;
  final double reveal;
  final double delta;
  final bool compact;
  final double sceneExtent;

  const _DiscoveryScene({
    required this.icon,
    required this.reveal,
    required this.delta,
    required this.compact,
    required this.sceneExtent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          top: lerpDouble(18, 6, reveal)!,
          start: 8,
          child: _FloatIconCard(
            icon: Icons.search_rounded,
            emphasis: false,
            compact: compact,
          ),
        ),
        PositionedDirectional(
          top: lerpDouble(30, 14, reveal)!,
          end: 14,
          child: _FloatIconCard(
            icon: Icons.favorite_border_rounded,
            emphasis: true,
            compact: compact,
          ),
        ),
        PositionedDirectional(
          bottom: 18,
          end: 8,
          child: _FloatIconCard(
            icon: Icons.local_offer_outlined,
            emphasis: false,
            compact: compact,
          ),
        ),
        Align(
          child: Transform.translate(
            offset: Offset(delta * -8, lerpDouble(12, 0, reveal)!),
            child: Transform.scale(
              scale: lerpDouble(0.94, 1, reveal)!,
              child: SizedBox(
                width: sceneExtent,
                height: sceneExtent,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  child: Column(
                    children: [
                      _ScenePill(
                        icon: icon,
                        primaryBar: 0.48,
                        secondaryBar: 0.26,
                        trailing: Icon(
                          Icons.tune_rounded,
                          size: 17,
                          color: context.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: const [
                            PositionedDirectional(
                              top: 2,
                              start: 16,
                              end: 16,
                              child: _DiscoverySearchHeader(),
                            ),
                            PositionedDirectional(
                              top: 18,
                              start: 6,
                              child: _DiscoveryMiniChip(
                                icon: Icons.tune_rounded,
                              ),
                            ),
                            PositionedDirectional(
                              top: 18,
                              end: 8,
                              child: _DiscoveryMiniChip(
                                icon: Icons.favorite_border_rounded,
                                accent: true,
                              ),
                            ),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: _DiscoveryShowcaseCard(),
                              ),
                            ),
                            PositionedDirectional(
                              start: 18,
                              end: 18,
                              bottom: 4,
                              child: _DiscoveryFooterBar(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const _ActionStrip(
                        icon: Icons.shopping_bag_rounded,
                        widthFactor: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CheckoutScene extends StatelessWidget {
  final IconData icon;
  final double reveal;
  final double delta;
  final bool compact;
  final double sceneExtent;

  const _CheckoutScene({
    required this.icon,
    required this.reveal,
    required this.delta,
    required this.compact,
    required this.sceneExtent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          top: lerpDouble(16, 4, reveal)!,
          start: 10,
          child: _FloatIconCard(
            icon: Icons.verified_user_rounded,
            emphasis: true,
            compact: compact,
          ),
        ),
        PositionedDirectional(
          top: lerpDouble(30, 12, reveal)!,
          end: 12,
          child: _FloatIconCard(
            icon: Icons.flash_on_rounded,
            emphasis: false,
            compact: compact,
          ),
        ),
        Align(
          child: Transform.translate(
            offset: Offset(delta * -6, lerpDouble(12, 0, reveal)!),
            child: SizedBox(
              width: sceneExtent,
              height: sceneExtent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  children: [
                    _ScenePill(
                      icon: icon,
                      primaryBar: 0.44,
                      secondaryBar: 0.24,
                      trailing: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: context.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.lerp(
                                  context.primary,
                                  context.background,
                                  0.84,
                                ),
                              ),
                            ),
                            Container(
                              width: 76,
                              height: 76,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: context.primary,
                              ),
                              child: Icon(
                                icon,
                                size: 30,
                                color: context.primaryForeground,
                              ),
                            ),
                            PositionedDirectional(
                              top: 18,
                              end: 18,
                              child: _AccentSpark(primary: true),
                            ),
                            PositionedDirectional(
                              bottom: 16,
                              start: 18,
                              child: _AccentSpark(primary: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const _SecureSteps(),
                    const SizedBox(height: 8),
                    const _ActionStrip(
                      icon: Icons.lock_rounded,
                      widthFactor: 0.44,
                      filled: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TrackingScene extends StatelessWidget {
  final IconData icon;
  final double reveal;
  final double delta;
  final bool compact;
  final double sceneExtent;

  const _TrackingScene({
    required this.icon,
    required this.reveal,
    required this.delta,
    required this.compact,
    required this.sceneExtent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          top: lerpDouble(16, 4, reveal)!,
          start: 10,
          child: _FloatIconCard(
            icon: Icons.inventory_2_outlined,
            emphasis: false,
            compact: compact,
          ),
        ),
        PositionedDirectional(
          top: lerpDouble(28, 12, reveal)!,
          end: 12,
          child: _FloatIconCard(
            icon: Icons.notifications_active_outlined,
            emphasis: true,
            compact: compact,
          ),
        ),
        Align(
          child: Transform.translate(
            offset: Offset(delta * -6, lerpDouble(12, 0, reveal)!),
            child: SizedBox(
              width: sceneExtent,
              height: sceneExtent,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                child: Column(
                  children: [
                    _ScenePill(
                      icon: icon,
                      primaryBar: 0.46,
                      secondaryBar: 0.24,
                      trailing: Icon(
                        Icons.done_all_rounded,
                        size: 17,
                        color: context.success,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            top: 24,
                            left: 28,
                            right: 28,
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                color: context.border.withValues(alpha: 0.62),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: _FloatIconCard(
                                icon: Icons.local_shipping_rounded,
                                emphasis: true,
                                compact: true,
                              ),
                            ),
                          ),
                          const Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _TrackStop(
                                    icon: Icons.inventory_2_outlined,
                                    active: true,
                                    primaryBar: 0.78,
                                    secondaryBar: 0.48,
                                  ),
                                  _TrackStop(
                                    icon: Icons.route_rounded,
                                    active: true,
                                    primaryBar: 0.64,
                                    secondaryBar: 0.42,
                                  ),
                                  _TrackStop(
                                    icon: Icons.home_outlined,
                                    primaryBar: 0.74,
                                    secondaryBar: 0.46,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _ActionStrip(
                      icon: Icons.location_on_outlined,
                      widthFactor: 0.74,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FloatIconCard extends StatelessWidget {
  final IconData icon;
  final bool emphasis;
  final bool compact;

  const _FloatIconCard({
    required this.icon,
    required this.emphasis,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final size = compact ? 38.0 : 42.0;
    final palette = _HeroPalette.of(context);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: emphasis ? palette.floatAccentSurface : palette.floatSurface,
        borderRadius: BorderRadius.circular(size * 0.32),
        border: Border.all(
          color: emphasis ? palette.floatAccentBorder : palette.floatBorder,
        ),
      ),
      child: Icon(
        icon,
        size: compact ? 18 : 19,
        color: emphasis ? context.primary : context.foreground,
      ),
    );
  }
}

class _ScenePill extends StatelessWidget {
  final IconData icon;
  final double primaryBar;
  final double secondaryBar;
  final Widget? trailing;

  const _ScenePill({
    required this.icon,
    required this.primaryBar,
    required this.secondaryBar,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _HeroPalette.of(context);
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: palette.panelSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.panelBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Color.lerp(context.accent, context.primary, 0.18)!,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 14, color: context.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _MockBar(
                  widthFactor: primaryBar,
                  height: 7,
                  color: context.mutedForeground.withValues(
                    alpha: context.isDark ? 0.36 : 0.2,
                  ),
                ),
                const SizedBox(height: 5),
                _MockBar(
                  widthFactor: secondaryBar,
                  height: 5,
                  color: context.muted.withValues(
                    alpha: context.isDark ? 0.5 : 0.7,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _DiscoverySearchHeader extends StatelessWidget {
  const _DiscoverySearchHeader();

  @override
  Widget build(BuildContext context) {
    final palette = _HeroPalette.of(context);
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: palette.chipSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.panelBorder),
      ),
      child: Row(
        children: [
          Icon(Icons.search_rounded, size: 14, color: context.foreground),
          const SizedBox(width: 8),
          const Expanded(
            child: _MockBar(widthFactor: 0.56, height: 6),
          ),
          const SizedBox(width: 8),
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: Color.lerp(context.accent, context.primary, 0.16)!,
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.mic_none_rounded, size: 10, color: context.primary),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryMiniChip extends StatelessWidget {
  final IconData icon;
  final bool accent;

  const _DiscoveryMiniChip({required this.icon, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final palette = _HeroPalette.of(context);
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: accent ? palette.chipAccentSurface : palette.chipSurface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: accent ? palette.chipAccentBorder : palette.chipBorder,
        ),
      ),
      child: Icon(
        icon,
        size: 13,
        color: accent ? context.primary : context.foreground,
      ),
    );
  }
}

class _DiscoveryShowcaseCard extends StatelessWidget {
  const _DiscoveryShowcaseCard();

  @override
  Widget build(BuildContext context) {
    final palette = _HeroPalette.of(context);
    return Container(
      width: 62,
      height: 102,
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      decoration: BoxDecoration(
        color: palette.showcaseSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.showcaseBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: context.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              size: 12,
              color: context.primaryForeground,
            ),
          ),
          const Spacer(),
          _MockBar(
            widthFactor: 0.76,
            color:
                context.muted.withValues(alpha: context.isDark ? 0.44 : 0.64),
          ),
          const SizedBox(height: 6),
          _MockBar(
            widthFactor: 0.48,
            height: 5,
            color: context.muted.withValues(alpha: context.isDark ? 0.3 : 0.48),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryFooterBar extends StatelessWidget {
  const _DiscoveryFooterBar();

  @override
  Widget build(BuildContext context) {
    final palette = _HeroPalette.of(context);
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: palette.chipSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.panelBorder),
      ),
      child: Row(
        children: [
          Icon(
            Icons.arrow_right_alt_rounded,
            size: 14,
            color: context.foreground,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: 34,
                child: _MockBar(widthFactor: 1, height: 5),
              ),
            ),
          ),
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              size: 9,
              color: context.primaryForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionStrip extends StatelessWidget {
  final IconData icon;
  final double widthFactor;
  final bool filled;

  const _ActionStrip({
    required this.icon,
    required this.widthFactor,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = filled ? context.primaryForeground : context.primary;
    final palette = _HeroPalette.of(context);
    final barColor = filled
        ? context.primaryForeground.withValues(alpha: 0.24)
        : context.muted.withValues(alpha: context.isDark ? 0.42 : 0.72);

    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: filled ? context.primary : palette.actionSurface,
        borderRadius: BorderRadius.circular(18),
        border: filled ? null : Border.all(color: palette.actionBorder),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccentSpark extends StatelessWidget {
  final bool primary;

  const _AccentSpark({required this.primary});

  @override
  Widget build(BuildContext context) {
    final palette = _HeroPalette.of(context);
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: primary ? palette.sparkSurface : palette.sparkSoftSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: primary
              ? context.primary.withValues(alpha: context.isDark ? 0.28 : 0.24)
              : palette.sparkBorder,
        ),
      ),
      child: Icon(
        primary ? Icons.check_rounded : Icons.bolt_rounded,
        size: 10,
        color: primary ? context.primary : context.foreground,
      ),
    );
  }
}

class _SecureSteps extends StatelessWidget {
  const _SecureSteps();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Row(
        children: [
          const _StepNode(icon: Icons.shopping_cart_outlined),
          const SizedBox(width: 10),
          Expanded(child: _StepConnector(active: false)),
          const SizedBox(width: 10),
          const _StepNode(icon: Icons.verified_user_rounded, active: true),
          const SizedBox(width: 10),
          Expanded(child: _StepConnector(active: true)),
          const SizedBox(width: 10),
          const _StepNode(icon: Icons.check_rounded, active: true),
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  final IconData icon;
  final bool active;

  const _StepNode({required this.icon, this.active = false});

  @override
  Widget build(BuildContext context) {
    final palette = _HeroPalette.of(context);
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active
            ? Color.lerp(context.primary, context.background, 0.84)
            : palette.chipSurface,
        border: Border.all(
          color: active
              ? context.primary.withValues(alpha: context.isDark ? 0.28 : 0.18)
              : palette.chipBorder,
        ),
      ),
      child: Icon(
        icon,
        size: 14,
        color: active ? context.primary : context.mutedForeground,
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool active;

  const _StepConnector({required this.active});

  @override
  Widget build(BuildContext context) {
    final palette = _HeroPalette.of(context);
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: active
            ? context.primary.withValues(alpha: 0.22)
            : palette.softTrack,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _TrackStop extends StatelessWidget {
  final IconData icon;
  final bool active;
  final double primaryBar;
  final double secondaryBar;

  const _TrackStop({
    required this.icon,
    required this.primaryBar,
    required this.secondaryBar,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _HeroPalette.of(context);
    return SizedBox(
      width: 50,
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? Color.lerp(context.primary, context.background, 0.84)
                  : palette.sparkSoftSurface,
            ),
            child: Icon(
              icon,
              size: 16,
              color: active ? context.primary : context.mutedForeground,
            ),
          ),
          const SizedBox(height: 10),
          _MockBar(
            widthFactor: primaryBar,
            height: 7,
            color: context.muted.withValues(alpha: active ? 0.7 : 0.54),
          ),
          const SizedBox(height: 6),
          _MockBar(
            widthFactor: secondaryBar,
            height: 5,
            color: context.muted.withValues(alpha: active ? 0.54 : 0.38),
          ),
        ],
      ),
    );
  }
}

class _MockBar extends StatelessWidget {
  final double widthFactor;
  final double height;
  final Color? color;

  const _MockBar({required this.widthFactor, this.height = 8, this.color});

  @override
  Widget build(BuildContext context) {
    final resolvedWidthFactor = _clampValue(widthFactor, 0, 1);
    final resolvedColor =
        color ?? context.muted.withValues(alpha: context.isDark ? 0.48 : 0.8);

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: FractionallySizedBox(
        widthFactor: resolvedWidthFactor,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: resolvedColor,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final OnboardingController controller;
  final bool compact;

  const _BottomBar({required this.controller, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => _PrimaryActionButton(
            label: (controller.isLast
                    ? Tk.onboardingGetStarted
                    : Tk.onboardingNext)
                .tr,
            onPressed: controller.onNext,
          ),
        ),
        SizedBox(height: compact ? 10 : 12),
        _SecondaryActionButton(
          label: Tk.onboardingHaveAccount.tr,
          onPressed: controller.onHaveAccount,
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primary,
          foregroundColor: context.primaryForeground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: AnimatedSwitcher(
          duration: _kMotionDuration,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.08),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Text(
            label,
            key: ValueKey(label),
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SecondaryActionButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: context.foreground,
          backgroundColor: context.card.withValues(
            alpha: context.isDark ? 0.42 : 0.84,
          ),
          side: BorderSide(color: context.border.withValues(alpha: 0.82)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
      ),
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
          duration: _kMotionDuration,
          curve: Curves.easeOutCubic,
          margin: const EdgeInsetsDirectional.only(end: 6),
          width: active ? 18 : 5,
          height: 5,
          decoration: BoxDecoration(
            color: active
                ? context.primary
                : Color.lerp(context.border, context.muted, 0.45)!,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.5,
              spreadRadius: size * 0.08,
            ),
          ],
        ),
      ),
    );
  }
}
