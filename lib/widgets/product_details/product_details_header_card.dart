import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_network_image.dart';
import 'package:rwnaqk/widgets/product_details/product_share_button.dart';

class ProductDetailsHeaderCard extends StatelessWidget {
  final List<String> images;

  // price
  final String priceText;
  final String? oldPriceText; // لو فيه خصم
  final String? discountText; // -20% مثلاً
  final Widget? timerWidget; // ProductCountdownPill

  final String description;

  // variations thumbnails
  final List<String> variationImages;
  final int selectedVariationImageIndex;
  final ValueChanged<int> onSelectVariationImage;

  final VoidCallback onShare;

  const ProductDetailsHeaderCard({
    super.key,
    required this.images,
    required this.priceText,
    this.oldPriceText,
    this.discountText,
    this.timerWidget,
    required this.description,
    required this.variationImages,
    required this.selectedVariationImageIndex,
    required this.onSelectVariationImage,
    required this.onShare,
  });

  bool get hasDiscount =>
      (oldPriceText != null && oldPriceText!.trim().isNotEmpty) &&
      (discountText != null && discountText!.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;

        final isCompact = w < 360;
        final isWide = w > 520;

        final radius = isWide ? 18.0 : 16.0;
        final padH = isWide ? 16.0 : 14.0;
        final padV = isWide ? 14.0 : 12.0;

        final priceSize = isCompact ? 22.0 : (isWide ? 30.0 : 26.0);
        final oldPriceSize = isCompact ? 11.5 : 12.5;

        final chipsGap = isCompact ? 6.0 : 8.0;
        final rowGap = isCompact ? 8.0 : 10.0;

        return Container(
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: context.border.withOpacity(0.55)),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withOpacity(context.isDark ? 0.14 : 0.07),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderImagePager(images: images),

              Padding(
                padding: EdgeInsets.fromLTRB(padH, padV, padH, padH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Price + Discount + Timer + Share (قدّام بعض + متجاوب)
                    // ✅ Price (left column) + Timer (center) + Share (right)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LEFT: price column (مثل الصورة)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                priceText,
                                style: TextStyle(
                                  color: context.foreground,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 26,
                                  height: 1.0,
                                ),
                              ),

                              const SizedBox(height: 6),

                              if (hasDiscount)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      oldPriceText!,
                                      style: TextStyle(
                                        color: context.mutedForeground,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                        height: 1.0,
                                        decoration: TextDecoration.lineThrough,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _DiscountBadge(text: discountText!),
                                  ],
                                ),
                            ],
                          ),
                        ),

                        // CENTER: timer (مثل الصورة)
                        if (timerWidget != null) ...[
                          const SizedBox(width: 12),
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 220),
                              child: timerWidget!,
                            ),
                          ),
                        ],

                        // RIGHT: share button
                        const SizedBox(width: 12),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: AppShareButton(onTap: onShare, size: 32),
                        ),
                      ],
                    ),

                    SizedBox(height: rowGap),

                    Text(
                      description,
                      maxLines: isWide ? 4 : 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.mutedForeground,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        fontSize: isCompact ? 12.6 : 13,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Variations header (مثل الصورة) — تخليه كما هو، بس مرتب أكثر
                    Row(
                      children: [
                        Text(
                          'Variations',
                          style: TextStyle(
                            color: context.foreground,
                            fontWeight: FontWeight.w900,
                            fontSize: isCompact ? 15 : 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Wrap(
                          spacing: chipsGap,
                          runSpacing: 6,
                          children: const [
                            _SmallChip(text: 'Pink'),
                            _SmallChip(text: 'M'),
                          ],
                        ),
                        const Spacer(),
                        _ArrowButton(size: isCompact ? 32 : 34),
                      ],
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: isCompact ? 50 : 56,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: variationImages.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, index) {
                          final selected = index == selectedVariationImageIndex;
                          return InkWell(
                            onTap: () => onSelectVariationImage(index),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: isCompact ? 50 : 56,
                              padding: const EdgeInsets.all(2.2),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selected
                                      ? context.primary
                                      : context.border.withOpacity(0.25),
                                  width: selected ? 2 : 1,
                                ),
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: context.primary.withOpacity(
                                            0.16,
                                          ),
                                          blurRadius: 14,
                                          offset: const Offset(0, 8),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AppNetworkImage(
                                  url: variationImages[index],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderImagePager extends StatefulWidget {
  final List<String> images;
  const _HeaderImagePager({required this.images});

  @override
  State<_HeaderImagePager> createState() => _HeaderImagePagerState();
}

class _HeaderImagePagerState extends State<_HeaderImagePager> {
  final _c = PageController();
  int _i = 0;

  @override
  void dispose() {
    _c.dispose();
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
            controller: _c,
            itemCount: safeCount,
            onPageChanged: (v) => setState(() => _i = v),
            itemBuilder: (_, idx) =>
                AppNetworkImage(url: images.isEmpty ? '' : images[idx]),
          ),

          // gradient overlay (لطيف)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.00),
                    Colors.black.withOpacity(0.08),
                    Colors.black.withOpacity(0.20),
                  ],
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
                final active = d == (_i.clamp(0, math.min(4, safeCount - 1)));
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

class _ArrowButton extends StatelessWidget {
  final double size;
  const _ArrowButton({required this.size});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: context.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: context.primary.withOpacity(context.isDark ? 0.22 : 0.18),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          color: context.primaryForeground,
          size: 18,
        ),
      ),
    );
  }
}

class _DiscountBadge extends StatelessWidget {
  final String text;
  const _DiscountBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: context.destructive.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.destructive.withOpacity(0.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.destructive,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          height: 1.0,
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  final String text;
  const _SmallChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.background.withOpacity(context.isDark ? 0.18 : 0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.border.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.mutedForeground,
          fontSize: 12.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
