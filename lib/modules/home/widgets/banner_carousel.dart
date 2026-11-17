import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_banner_item.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

class BannerCarousel extends StatefulWidget {
  final List<HomeBannerItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  final PageController? controller;

  const BannerCarousel({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.controller,
  });

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late final PageController _pageController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _pageController = widget.controller!;
    } else {
      _ownsController = true;
      _pageController = PageController(
        initialPage: widget.index,
        viewportFraction: 1.0,
      );
    }
  }

  @override
  void didUpdateWidget(covariant BannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    final maxIndex = widget.items.isEmpty ? 0 : widget.items.length - 1;
    final safeIndex = widget.index.clamp(0, maxIndex);

    if (safeIndex != oldWidget.index &&
        _pageController.hasClients &&
        (_pageController.page?.round() ?? _pageController.initialPage) !=
            safeIndex) {
      _pageController.animateToPage(
        safeIndex,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = (w * 0.50).clamp(180.0, 225.0);

        return Column(
          children: [
            SizedBox(
              height: h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: widget.onChanged,
                clipBehavior: Clip.none,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, i) {
                  return AnimatedBuilder(
                    animation: _pageController,
                    builder: (context, child) {
                      double diff = 0.0;
                      if (_pageController.position.haveDimensions) {
                        diff =
                            (_pageController.page ??
                                _pageController.initialPage.toDouble()) -
                            i;
                      } else {
                        diff = (widget.index - i).toDouble();
                      }

                      final clamped = diff.clamp(-1.0, 1.0);
                      final isRtl =
                          Directionality.of(context) == TextDirection.rtl;
                      final rtlMultiplier = isRtl ? -1.0 : 1.0;

                      final scale = (1.0 - (clamped.abs() * 0.10)).clamp(
                        0.88,
                        1.0,
                      );
                      final rotationY =
                          clamped * -0.22 * rtlMultiplier; // 3D Y-Rotation
                      final translationX = clamped * -8.0 * rtlMultiplier;

                      final matrix = Matrix4.identity()
                        ..setEntry(3, 2, 0.0012) // 3D Perspective
                        ..multiply(
                          Matrix4.translationValues(translationX, 0.0, 0.0),
                        )
                        ..multiply(Matrix4.rotationY(rotationY))
                        ..multiply(Matrix4.diagonal3Values(scale, scale, 1.0));

                      final opacity = (1.0 - (clamped.abs() * 0.22)).clamp(
                        0.75,
                        1.0,
                      );

                      return Transform(
                        transform: matrix,
                        alignment: Alignment.center,
                        child: Opacity(opacity: opacity, child: child),
                      );
                    },
                    child: _BannerCard(item: widget.items[i]),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            _Dots(
              count: widget.items.length,
              activeIndex: widget.index.clamp(0, widget.items.length - 1),
            ),
          ],
        );
      },
    );
  }
}

class _BannerCard extends StatelessWidget {
  final HomeBannerItem item;
  const _BannerCard({required this.item});

  void _onTap(BuildContext context) {
    if (item.linkType == 'product' &&
        item.linkValue != null &&
        item.linkValue!.isNotEmpty) {
      AppNav.toNamed(
        AppRoutes.product,
        arguments: {'productId': item.linkValue},
      );
    } else if (item.linkType == 'category' &&
        item.linkValue != null &&
        item.linkValue!.isNotEmpty) {
      AppNav.toNamed(
        AppRoutes.listing,
        arguments: {'categoryId': item.linkValue},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final radius = BorderRadius.circular(8);

    final title = item.titleKey.tr;
    final subtitle = item.subtitleKey.tr;
    final badge = item.badgeKey.tr;
    final hasText = title.isNotEmpty || subtitle.isNotEmpty || badge.isNotEmpty;

    return InkWell(
      onTap: () => _onTap(context),
      borderRadius: radius,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: isDark
                ? BrandColors.gold.withValues(alpha: 0.30)
                : BrandColors.burgundy.withValues(alpha: 0.15),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.50)
                  : BrandColors.burgundy.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. صورة الخلفية أو تدرج ألوان بديل
              if (item.imageUrl.isNotEmpty)
                Image.network(
                  item.imageUrl,
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                  filterQuality: FilterQuality.high,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: isDark
                          ? const Color(0xFF2A0014)
                          : const Color(0xFFFFF0F5),
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? BrandColors.gold : BrandColors.burgundy,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackBackground(isDark);
                  },
                )
              else
                _buildFallbackBackground(isDark),

              // 2. تدرج لوني ذكي لضمان قراءة النصوص بوضوح فائق فوق أي صورة
              if (hasText)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: isRtl
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        end: isRtl
                            ? Alignment.centerLeft
                            : Alignment.centerRight,
                        colors: [
                          (isDark ? Colors.black : const Color(0xFF220010))
                              .withValues(alpha: 0.82),
                          (isDark ? Colors.black : const Color(0xFF220010))
                              .withValues(alpha: 0.50),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),

              // 3. النصوص والشارة الترويجية وزر الإجراء
              if (hasText)
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (badge.isNotEmpty) ...[
                          _Badge(text: badge),
                          const SizedBox(height: 8),
                        ],
                        if (title.isNotEmpty)
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 240),
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 18,
                                fontFamily: 'Cairo',
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 6,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 220),
                            child: Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.92),
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                fontFamily: 'Cairo',
                                height: 1.25,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        _CtaButton(isDark: isDark),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF4C0224),
                  BrandColors.burgundy,
                  Color(0xFF220010),
                ]
              : const [Color(0xFFFFF1F6), Color(0xFFFDE4ED), Color(0xFFF9D1E0)],
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final bool isDark;
  const _CtaButton({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: BrandColors.gold,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'تسوق الآن',
            style: TextStyle(
              color: Color(0xFF26141E),
              fontWeight: FontWeight.w800,
              fontSize: 10.5,
              fontFamily: 'Cairo',
              height: 1.1,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.arrow_forward_rounded, size: 11, color: Color(0xFF26141E)),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: BrandColors.gold,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: BrandColors.gold.withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF26141E),
          fontWeight: FontWeight.w900,
          fontSize: 10,
          fontFamily: 'Cairo',
          height: 1,
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int activeIndex;
  const _Dots({required this.count, required this.activeIndex});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'carousel_dots',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(count, (i) {
          final active = i == activeIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: active ? 22 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active
                  ? context.primary
                  : context.border.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(999),
            ),
          );
        }),
      ),
    );
  }
}
