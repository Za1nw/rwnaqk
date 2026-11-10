import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/providers/auth_session_providers.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/app_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_link_button.dart';
import 'package:rwnaqk_frontend/core/widgets/app_toggles.dart';
import 'package:rwnaqk_frontend/modules/auth/widgets/auth_blob_background.dart';
import 'package:rwnaqk_frontend/modules/onboarding/controllers/onboarding_service.dart';
import 'package:rwnaqk_frontend/modules/onboarding/providers/onboarding_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

/// شاشة التهيئة الترحيبية للعميل [OnboardingScreen].
///
/// تمت هجرتها بنجاح إلى Riverpod 3 مع الحفاظ التام على دورة حياة المتحكمات والتصميم.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageCtrl;
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (!mounted) return;
    setState(() {
      _pageIndex = index;
    });
  }

  void _onSkip(int totalSlides) {
    if (totalSlides <= 0) return;
    _pageCtrl.animateToPage(
      totalSlides - 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOut,
    );
  }

  void _onNext(bool isLast) {
    if (isLast) {
      _onGetStarted();
      return;
    }

    _pageCtrl.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  void _onGetStarted() {
    unawaited(ref.read(onboardingCompletionProvider.notifier).completeOnboarding());

    final isAuthenticated = ref.read(isAuthenticatedProvider);
    final destination = isAuthenticated ? AppRoutes.main : AppRoutes.login;

    AppNav.offAllNamed(destination);
  }

  void _onHaveAccount() {
    unawaited(ref.read(onboardingCompletionProvider.notifier).completeOnboarding());
    AppNav.toNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(onboardingServiceProvider);
    final slides = service.slides;
    final isLast = service.isLastPage(
      currentIndex: _pageIndex,
      totalSlides: slides.length,
    );

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: AuthBlobBackground(
          child: SizedBox.expand(
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: context.card.withValues(alpha: context.isDark ? .62 : .48),
                  border: Border.all(color: context.border.withValues(alpha: .18)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: context.isDark ? .25 : .10),
                      offset: const Offset(0, 18),
                      blurRadius: 32,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                  child: Column(
                    children: [
                      _TopBar(
                        isLast: isLast,
                        onSkip: () => _onSkip(slides.length),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _Content(
                          pageCtrl: _pageCtrl,
                          slides: slides,
                          onPageChanged: _onPageChanged,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _BottomBar(
                        pageIndex: _pageIndex,
                        totalSlides: slides.length,
                        isLast: isLast,
                        onNext: () => _onNext(isLast),
                        onHaveAccount: _onHaveAccount,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// الشريط العلوي: أزرار التبديل + زر التخطي
class _TopBar extends StatelessWidget {
  final bool isLast;
  final VoidCallback onSkip;

  const _TopBar({
    required this.isLast,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppToggles(alignment: Alignment.centerLeft),
        const Spacer(),
        if (isLast)
          const SizedBox(width: 86, height: 40)
        else
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              splashFactory: NoSplash.splashFactory,
              foregroundColor: context.mutedForeground,
            ),
            child: Text(
              Tk.onboardingSkip.tr,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
      ],
    );
  }
}

/// المحتوى الرئيسي: PageView للشرائح
class _Content extends StatelessWidget {
  final PageController pageCtrl;
  final List<OnboardingSlide> slides;
  final ValueChanged<int> onPageChanged;

  const _Content({
    required this.pageCtrl,
    required this.slides,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;

        final compact = h < 520;
        final iconSize = compact ? 108.0 : 140.0;
        final innerSize = compact ? 94.0 : 124.0;
        final titleSize = compact ? 26.0 : 30.0;
        final subSize = compact ? 13.8 : 15.0;

        return PageView.builder(
          controller: pageCtrl,
          onPageChanged: onPageChanged,
          itemCount: slides.length,
          itemBuilder: (_, i) {
            final s = slides[i];

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
        border: Border.all(color: context.border.withValues(alpha: .18)),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: context.isDark ? .08 : .55),
            offset: const Offset(-8, -8),
            blurRadius: 18,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? .35 : .12),
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
            color: context.background.withValues(alpha: .12),
            border: Border.all(
              color: context.primary.withValues(alpha: .18),
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

/// الشريط السفلي: نقاط المؤشر + زر الإجراء الرئيسي + رابط تسجيل الدخول
class _BottomBar extends StatelessWidget {
  final int pageIndex;
  final int totalSlides;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onHaveAccount;

  const _BottomBar({
    required this.pageIndex,
    required this.totalSlides,
    required this.isLast,
    required this.onNext,
    required this.onHaveAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Dots(
          count: totalSlides,
          index: pageIndex,
        ),
        const SizedBox(height: 14),
        AppButton(
          text: (isLast ? Tk.onboardingGetStarted : Tk.onboardingNext).tr,
          onPressed: onNext,
        ),
        const SizedBox(height: 10),
        AppLinkButton(
          text: Tk.onboardingHaveAccount.tr,
          onPressed: onHaveAccount,
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
            color: active ? context.primary : context.border.withValues(alpha: .55),
            borderRadius: BorderRadius.circular(99),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: context.primary.withValues(alpha: .18),
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
