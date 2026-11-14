import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_header_gallery.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_header_info.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_size_guide_sheet.dart';

class ProductDetailsHeaderCard extends StatelessWidget {
  final List<String> images;

  final String title;
  final String description;
  final String? brand;

  final String priceText;
  final String? oldPriceText;
  final String? discountText;
  final Widget? timerWidget;

  final double? rating;
  final int? reviewsCount;
  final String? infoText;

  final bool isFavorite;
  final VoidCallback? onFavorite;

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

  final VoidCallback? onShare;
  final bool showArrowButton;
  final VoidCallback? onArrowTap;
  final VoidCallback? onOpenVariantsSheet;
  final VoidCallback? onSizeGuideTap;

  const ProductDetailsHeaderCard({
    super.key,
    required this.images,
    required this.title,
    required this.description,
    this.brand,
    required this.priceText,
    this.oldPriceText,
    this.discountText,
    this.timerWidget,
    this.rating,
    this.reviewsCount,
    this.infoText,
    this.isFavorite = false,
    this.onFavorite,
    this.availableColors = const [],
    this.selectedColorId = '',
    this.onSelectColor,
    this.availableSizes = const [],
    this.selectedSize = '',
    this.onSelectSize,
    this.variationsTitle = 'Variations',
    this.selectedChips = const [],
    required this.variationImages,
    required this.selectedVariationImageIndex,
    required this.onSelectVariationImage,
    this.onShare,
    this.showArrowButton = false,
    this.onArrowTap,
    this.onOpenVariantsSheet,
    this.onSizeGuideTap,
  });

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

        final titleSize = isCompact ? 16.0 : (isWide ? 20.0 : 18.0);
        final priceSize = isCompact ? 22.0 : (isWide ? 30.0 : 26.0);
        final descSize = isCompact ? 12.6 : 13.0;
        final rowGap = isCompact ? 8.0 : 10.0;

        return Container(
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: context.border.withValues(alpha: 0.55)),
            boxShadow: [
              BoxShadow(
                color: context.shadow.withValues(alpha: context.isDark ? 0.14 : 0.07),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProductDetailsHeaderGallery(
                images: images,
                radius: radius,
                isFavorite: isFavorite,
                onFavorite: onFavorite,
                discountText: discountText,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(padH, padV, padH, padH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductDetailsHeaderInfo(
                      title: title,
                      description: description,
                      brand: brand,
                      priceText: priceText,
                      oldPriceText: oldPriceText,
                      discountText: discountText,
                      timerWidget: timerWidget,
                      rating: rating,
                      reviewsCount: reviewsCount,
                      infoText: infoText,
                      titleSize: titleSize,
                      priceSize: priceSize,
                      descSize: descSize,
                      rowGap: rowGap,
                      isWide: isWide,
                      onShare: onShare,
                    ),
                    if (availableColors.isNotEmpty ||
                        availableSizes.isNotEmpty ||
                        variationImages.isNotEmpty ||
                        selectedChips.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _ProductVariantSelectorBar(
                        selectedChips: selectedChips,
                        onTap: () {
                          if (onOpenVariantsSheet != null) {
                            onOpenVariantsSheet!();
                          } else {
                            onArrowTap?.call();
                          }
                        },
                        onSizeGuideTap: availableSizes.isNotEmpty
                            ? () {
                                if (onSizeGuideTap != null) {
                                  onSizeGuideTap!();
                                } else {
                                  ProductSizeGuideSheet.show(
                                    context,
                                    currentSelectedSize: selectedSize,
                                    onSizeSelected: onSelectSize,
                                  );
                                }
                              }
                            : null,
                      ),
                    ],
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

class _ProductVariantSelectorBar extends StatelessWidget {
  final List<String> selectedChips;
  final VoidCallback onTap;
  final VoidCallback? onSizeGuideTap;

  const _ProductVariantSelectorBar({
    required this.selectedChips,
    required this.onTap,
    this.onSizeGuideTap,
  });

  @override
  Widget build(BuildContext context) {
    final summaryText = selectedChips.isNotEmpty
        ? selectedChips.join(' • ')
        : Tk.productDetailsSelectOptions.tr;

    return Container(
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: context.border.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: context.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                Tk.productDetailsVariations.tr,
                                style: TextStyle(
                                  color: context.foreground,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.5,
                                ),
                              ),
                              if (selectedChips.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        context.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'محدد',
                                    style: TextStyle(
                                      color: context.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            summaryText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'تحديد',
                          style: TextStyle(
                            color: context.primary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: context.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (onSizeGuideTap != null) ...[
            Divider(
              height: 1,
              thickness: 0.6,
              color: context.border.withValues(alpha: 0.4),
            ),
            InkWell(
              onTap: onSizeGuideTap,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  children: [
                    Icon(
                      Icons.straighten_rounded,
                      size: 15,
                      color: context.mutedForeground,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      Tk.productDetailsSizeGuide.tr,
                      style: TextStyle(
                        color: context.mutedForeground,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: context.mutedForeground,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}