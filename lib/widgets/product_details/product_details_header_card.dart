import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/models/product_color_option.dart';
import 'package:rwnaqk/widgets/product_details/product_details_header_gallery.dart';
import 'package:rwnaqk/widgets/product_details/product_details_header_info.dart';
import 'package:rwnaqk/widgets/product_details/product_details_header_variants.dart';

class ProductDetailsHeaderCard extends StatelessWidget {
  final List<String> images;

  final String title;
  final String description;

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

  final VoidCallback onShare;
  final bool showArrowButton;
  final VoidCallback? onArrowTap;

  const ProductDetailsHeaderCard({
    super.key,
    required this.images,
    required this.title,
    required this.description,
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
    required this.onShare,
    this.showArrowButton = false,
    this.onArrowTap,
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
              ProductDetailsHeaderGallery(
                images: images,
                radius: radius,
                isFavorite: isFavorite,
                onFavorite: onFavorite,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(padH, padV, padH, padH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductDetailsHeaderInfo(
                      title: title,
                      description: description,
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
                        variationImages.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      ProductDetailsHeaderVariants(
                        availableColors: availableColors,
                        selectedColorId: selectedColorId,
                        onSelectColor: onSelectColor,
                        availableSizes: availableSizes,
                        selectedSize: selectedSize,
                        onSelectSize: onSelectSize,
                        variationsTitle: variationsTitle,
                        selectedChips: selectedChips,
                        variationImages: variationImages,
                        selectedVariationImageIndex:
                            selectedVariationImageIndex,
                        onSelectVariationImage: onSelectVariationImage,
                        showArrowButton: showArrowButton,
                        onArrowTap: onArrowTap,
                        isCompact: isCompact,
                        chipsGap: chipsGap,
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