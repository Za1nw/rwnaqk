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
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images;
    final safeCount = math.max(1, images.length);

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: safeCount,
            onPageChanged: (v) => setState(() => _index = v),
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
              return AppNetworkImage(url: images[idx]);
            },
          ),
          Positioned.fill(
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
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(math.min(5, safeCount), (d) {
                final active =
                    d == (_index.clamp(0, math.min(4, safeCount - 1)));
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
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