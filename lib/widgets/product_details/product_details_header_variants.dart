import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/models/product_color_option.dart';
import 'package:rwnaqk/widgets/app_network_image.dart';

class ProductDetailsHeaderVariants extends StatelessWidget {
  final List<ProductColorOption> availableColors;
  final String selectedColorId;
  final ValueChanged<String>? onSelectColor;

  final List<String> availableSizes;
  final String selectedSize;
  final ValueChanged<String>? onSelectSize;

  final String variationsTitle;
  final List<String> selectedChips;
  final List<String> variationImages;
  final int selectedVariationImageIndex;
  final ValueChanged<int> onSelectVariationImage;

  final bool showArrowButton;
  final VoidCallback? onArrowTap;
  final bool isCompact;
  final double chipsGap;

  const ProductDetailsHeaderVariants({
    super.key,
    required this.availableColors,
    required this.selectedColorId,
    this.onSelectColor,
    required this.availableSizes,
    required this.selectedSize,
    this.onSelectSize,
    required this.variationsTitle,
    required this.selectedChips,
    required this.variationImages,
    required this.selectedVariationImageIndex,
    required this.onSelectVariationImage,
    required this.showArrowButton,
    this.onArrowTap,
    required this.isCompact,
    required this.chipsGap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (availableColors.isNotEmpty) ...[
          _SectionTitle(title: 'Available colors'),
          const SizedBox(height: 10),
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: availableColors.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final option = availableColors[index];
                final selected = option.id == selectedColorId;

                return InkWell(
                  onTap: onSelectColor == null
                      ? null
                      : () => onSelectColor!(option.id),
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 72,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? context.primary
                            : context.border.withOpacity(.35),
                        width: selected ? 1.8 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: context.primary.withOpacity(.16),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: AppNetworkImage(url: option.imageUrl),
                          ),
                        ),
                        Positioned(
                          left: 6,
                          right: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              option.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (availableSizes.isNotEmpty) ...[
          _SectionTitle(title: 'Available sizes'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableSizes.map((option) {
              final selected = option == selectedSize;

              return InkWell(
                onTap: onSelectSize == null ? null : () => onSelectSize!(option),
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? context.primary.withOpacity(.12)
                        : context.background.withOpacity(
                            context.isDark ? .18 : .75,
                          ),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? context.primary
                          : context.border.withOpacity(.35),
                      width: selected ? 1.4 : 1,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      color: selected ? context.primary : context.mutedForeground,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (variationImages.isNotEmpty) const SizedBox(height: 14),
        ],
        if (variationImages.isNotEmpty) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                variationsTitle,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: isCompact ? 15 : 16,
                ),
              ),
              if (selectedChips.isNotEmpty) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: chipsGap,
                    runSpacing: 6,
                    children: selectedChips
                        .map((e) => _SmallChip(text: e))
                        .toList(),
                  ),
                ),
              ] else
                const Spacer(),
              if (showArrowButton)
                _ArrowButton(
                  size: isCompact ? 32 : 34,
                  onTap: onArrowTap,
                ),
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
                                color: context.primary.withOpacity(0.16),
                                blurRadius: 14,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AppNetworkImage(url: variationImages[index]),
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.foreground,
        fontWeight: FontWeight.w900,
        fontSize: 14.5,
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;

  const _ArrowButton({
    required this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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