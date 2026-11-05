import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_banner_item.dart';

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
      _pageController = PageController(initialPage: widget.index);
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
        duration: const Duration(milliseconds: 260),
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
        final h = (w * 0.40).clamp(155.0, 200.0);

        return Column(
          children: [
            SizedBox(
              height: h,
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.items.length,
                onPageChanged: widget.onChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, i) => _BannerCard(item: widget.items[i]),
              ),
            ),
            const SizedBox(height: 10),
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

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3B0319), BrandColors.burgundy, Color(0xFF86043C)],
        ),
        boxShadow: [
          BoxShadow(
            color: BrandColors.burgundy.withValues(
              alpha: context.isDark ? 0.35 : 0.20,
            ),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Decorative background patterns
            Positioned(
              left: -30,
              bottom: -30,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: BrandColors.gold.withValues(alpha: 0.08),
                ),
              ),
            ),

            // Network Image with graceful fallback
            Image.network(
              item.imageUrl,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const SizedBox.shrink();
              },
              errorBuilder: (_, _, _) {
                // Graceful fallback: show elegant luxury banner texture instead of broken icon
                return const SizedBox.shrink();
              },
            ),

            // Directional Dark Overlay for Maximum Legibility
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [
                    Colors.black.withValues(alpha: 0.78),
                    Colors.black.withValues(alpha: 0.40),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.60, 1.0],
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Badge(text: item.badgeKey.tr),
                  const SizedBox(height: 8),
                  Text(
                    item.titleKey.tr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      fontFamily: 'Cairo',
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(
                      item.subtitleKey.tr,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        fontFamily: 'Cairo',
                        height: 1.25,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            duration: const Duration(milliseconds: 240),
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
