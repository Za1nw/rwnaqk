import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/widgets/app_network_image.dart';

class ProductDetailsHeaderGallery extends StatefulWidget {
  final List<String> images;
  final double radius;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final String? discountText;

  const ProductDetailsHeaderGallery({
    super.key,
    required this.images,
    required this.radius,
    required this.isFavorite,
    required this.onFavorite,
    this.discountText,
  });

  @override
  State<ProductDetailsHeaderGallery> createState() =>
      _ProductDetailsHeaderGalleryState();
}

class _ProductDetailsHeaderGalleryState
    extends State<ProductDetailsHeaderGallery> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreenViewer(int initialIndex) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.92),
        pageBuilder: (ctx, anim, _) => _FullScreenImageViewer(
          images: widget.images,
          initialIndex: initialIndex,
        ),
        transitionsBuilder: (ctx, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  void _goToIndex(int index) {
    if (index == _index) return;
    HapticFeedback.selectionClick();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final safeCount = math.max(1, images.length);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: AspectRatio(
            aspectRatio: 1.05,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: safeCount,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (_, idx) {
                    if (images.isEmpty) {
                      return Container(
                        color: context.input,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.image_outlined,
                          size: 44,
                          color: context.mutedForeground,
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () => _openFullScreenViewer(idx),
                      child: _ZoomableGalleryImage(
                        imageUrl: images[idx],
                      ),
                    );
                  },
                ),

                // Gradient Vignette
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.08),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.20),
                          ],
                          stops: const [0.0, 0.6, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Favorite Button
                if (widget.onFavorite != null)
                  PositionedDirectional(
                    top: 12,
                    end: 12,
                    child: _TopCircleAction(
                      onTap: widget.onFavorite!,
                      icon: widget.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: widget.isFavorite
                          ? context.destructive
                          : context.foreground,
                    ),
                  ),

                // Discount Pill or Image Counter
                PositionedDirectional(
                  top: 12,
                  start: 12,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.discountText != null &&
                          widget.discountText!.trim().isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: context.destructive,
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: context.destructive.withValues(alpha: 0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            widget.discountText!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '${(_index + 1).clamp(1, safeCount)}/$safeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Tap to zoom hint icon
                PositionedDirectional(
                  bottom: 12,
                  end: 12,
                  child: InkWell(
                    onTap: () => _openFullScreenViewer(_index),
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.40),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                // Page indicator dots
                if (safeCount > 1)
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(math.min(6, safeCount), (d) {
                        final maxDots = math.min(6, safeCount);
                        final currentDotIndex = _index.clamp(0, maxDots - 1);
                        final active = d == currentDotIndex;

                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: active ? 20 : 6,
                          height: 5.5,
                          decoration: BoxDecoration(
                            color: active
                                ? context.primary
                                : Colors.white.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Thumbnail strip
        if (images.length > 1) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: images.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, idx) {
                final isSelected = idx == _index;

                return InkWell(
                  onTap: () => _goToIndex(idx),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? context.primary
                            : context.border.withValues(alpha: 0.35),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: context.primary.withValues(alpha: 0.20),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: AppNetworkImage(
                        url: images[idx],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _ZoomableGalleryImage extends StatefulWidget {
  final String imageUrl;

  const _ZoomableGalleryImage({
    required this.imageUrl,
  });

  @override
  State<_ZoomableGalleryImage> createState() => _ZoomableGalleryImageState();
}

class _ZoomableGalleryImageState extends State<_ZoomableGalleryImage> {
  TransformationController? _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController?.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _transformationController?.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _resetZoom,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1,
        maxScale: 3.5,
        panEnabled: true,
        scaleEnabled: true,
        clipBehavior: Clip.none,
        child: SizedBox.expand(
          child: AppNetworkImage(
            url: widget.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class _TopCircleAction extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color iconColor;

  const _TopCircleAction({
    required this.onTap,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.background.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(color: context.border.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: iconColor),
      ),
    );
  }
}

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _FullScreenImageViewer({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.images.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: count,
              onPageChanged: (v) => setState(() => _currentIndex = v),
              itemBuilder: (_, i) => InteractiveViewer(
                minScale: 1,
                maxScale: 4.5,
                child: Center(
                  child: AppNetworkImage(
                    url: widget.images[i],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / $count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.20),
                      shape: const CircleBorder(),
                    ),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
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
