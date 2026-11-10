import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';
import 'package:rwnaqk_frontend/core/widgets/app_network_image.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_size_guide_sheet.dart';

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
  final VoidCallback? onOpenVariantsSheet;
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
    this.onOpenVariantsSheet,
    required this.isCompact,
    required this.chipsGap,
  });

  String? get selectedColorName {
    for (final c in availableColors) {
      if (c.id == selectedColorId) return c.name;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Available Colors
        if (availableColors.isNotEmpty) ...[
          InkWell(
            onTap: onOpenVariantsSheet,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(
                    Tk.productDetailsAvailableColors.tr,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 14.5,
                    ),
                  ),
                  if (selectedColorName != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      '(${selectedColorName!.tr})',
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (onOpenVariantsSheet != null) ...[
                    Text(
                      'تحديد',
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: context.primary,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 76,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: availableColors.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final option = availableColors[index];
                final selected = option.id == selectedColorId;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectColor?.call(option.id);
                    onOpenVariantsSheet?.call();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 76,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: context.background,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? context.primary
                            : context.border.withValues(alpha: .35),
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: context.primary.withValues(alpha: .22),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AppNetworkImage(
                              url: option.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        if (selected)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: context.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 12,
                                color: context.primaryForeground,
                              ),
                            ),
                          ),
                        Positioned(
                          left: 4,
                          right: 4,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              option.name.tr,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
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
          const SizedBox(height: 16),
        ],

        // Available Sizes
        if (availableSizes.isNotEmpty) ...[
          Row(
            children: [
              InkWell(
                onTap: onOpenVariantsSheet,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        Tk.productDetailsAvailableSizes.tr,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                        ),
                      ),
                      if (selectedSize.trim().isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          '($selectedSize)',
                          style: TextStyle(
                            color: context.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                      if (onOpenVariantsSheet != null) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: context.primary,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const Spacer(),
              // Size Guide interactive button
              InkWell(
                onTap: () => ProductSizeGuideSheet.show(
                  context,
                  currentSelectedSize: selectedSize,
                  onSizeSelected: onSelectSize,
                ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.straighten_rounded,
                        size: 16,
                        color: context.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Tk.productDetailsSizeGuide.tr,
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                          decoration: TextDecoration.underline,
                          decorationColor:
                              context.primary.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: availableSizes.map((option) {
              final selected = option == selectedSize;

              return InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelectSize?.call(option);
                  onOpenVariantsSheet?.call();
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(minWidth: 48, minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? context.primary
                        : context.background.withValues(
                            alpha: context.isDark ? .20 : .85,
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? context.primary
                          : context.border.withValues(alpha: .40),
                      width: selected ? 1.6 : 1,
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: context.primary.withValues(alpha: .24),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: selected
                            ? context.primaryForeground
                            : context.foreground,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (variationImages.isNotEmpty) const SizedBox(height: 16),
        ],

        // Variations
        if (variationImages.isNotEmpty) ...[
          InkWell(
            onTap: onOpenVariantsSheet ?? onArrowTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    variationsTitle,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: isCompact ? 14.5 : 15.5,
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
                  if (showArrowButton || onOpenVariantsSheet != null)
                    _ArrowButton(
                      size: isCompact ? 32 : 34,
                      onTap: onOpenVariantsSheet ?? onArrowTap,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: isCompact ? 52 : 58,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: variationImages.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final selected = index == selectedVariationImageIndex;

                return InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onSelectVariationImage(index);
                    onOpenVariantsSheet?.call();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: isCompact ? 52 : 58,
                    padding: const EdgeInsets.all(2.2),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? context.primary
                            : context.border.withValues(alpha: 0.25),
                        width: selected ? 2 : 1,
                      ),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: context.primary.withValues(alpha: 0.16),
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
              color: context.primary
                  .withValues(alpha: context.isDark ? 0.22 : 0.18),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.background
            .withValues(alpha: context.isDark ? 0.18 : 0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.border.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.mutedForeground,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
