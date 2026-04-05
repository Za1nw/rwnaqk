import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_network_image.dart';

class ProductDetailsHeaderGallery extends StatefulWidget {
  final List<String> images;
  final double radius;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  const ProductDetailsHeaderGallery({
    super.key,
    required this.images,
    required this.radius,
    required this.isFavorite,
    required this.onFavorite,
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

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final safeCount = math.max(1, images.length);

    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: AspectRatio(
        aspectRatio: 1,
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

                return _ZoomableGalleryImage(
                  imageUrl: images[idx],
                );
              },
            ),

            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.00),
                        Colors.black.withOpacity(0.06),
                        Colors.black.withOpacity(0.18),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            if (widget.onFavorite != null)
              Positioned(
                top: 12,
                right: 12,
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

            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.32),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${(_index + 1).clamp(1, safeCount)}/$safeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),

            if (safeCount > 1)
              Positioned(
                bottom: 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(math.min(5, safeCount), (d) {
                    final maxDots = math.min(5, safeCount);
                    final currentDotIndex = _index.clamp(0, maxDots - 1);
                    final active = d == currentDotIndex;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 22 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? context.primary
                            : Colors.white.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
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
        maxScale: 4,
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: context.background.withOpacity(.90),
          shape: BoxShape.circle,
          border: Border.all(color: context.border.withOpacity(.22)),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}