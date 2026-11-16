import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/app_network_image.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_attribute_group.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_header_gallery.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_header_info.dart';

class ProductDetailsHeaderCard extends StatelessWidget {
  final List<String> images;

  final String title;
  final String? shortDescription;
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

  // الخصائص والمتغيرات
  final bool hasVariations;
  final List<String> selectedChips;
  final VoidCallback? onOpenVariantsSheet;
  final VoidCallback? onArrowTap;
  final bool hasSizeGuide;
  final VoidCallback? onSizeGuideTap;

  // الكمية والمجموع الإجمالي المباشر
  final int quantity;
  final VoidCallback? onIncrementQuantity;
  final VoidCallback? onDecrementQuantity;
  final String? totalPriceText;

  // الخصائص التفاعلية
  final List<ProductAttributeGroup> attributeGroups;
  final Map<String, String> selectedAttributes;
  final void Function(String groupId, String optionId)? onSelectAttribute;
  final VoidCallback? onShare;

  const ProductDetailsHeaderCard({
    super.key,
    required this.images,
    required this.title,
    this.shortDescription,
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
    this.hasVariations = false,
    this.selectedChips = const [],
    this.onOpenVariantsSheet,
    this.onArrowTap,
    this.hasSizeGuide = false,
    this.onSizeGuideTap,
    this.quantity = 1,
    this.onIncrementQuantity,
    this.onDecrementQuantity,
    this.totalPriceText,
    this.attributeGroups = const [],
    this.selectedAttributes = const {},
    this.onSelectAttribute,
    this.onShare,
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
                color: context.shadow.withValues(
                  alpha: context.isDark ? 0.14 : 0.07,
                ),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Gallery
              ProductDetailsHeaderGallery(
                images: images,
                radius: radius,
                isFavorite: isFavorite,
                onFavorite: onFavorite,
                discountText: discountText,
              ),

              // 2. Info & Selection Card
              Padding(
                padding: EdgeInsets.fromLTRB(padH, padV, padH, padH),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProductDetailsHeaderInfo(
                      title: title,
                      shortDescription: shortDescription,
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

                    const SizedBox(height: 14),

                    // 3. Selection & Quantity Section (معروض مباشرة دون الحاجة لفتح نافذة الخيارات)
                    _ProductSelectionAndQuantitySection(
                      hasVariations: hasVariations,
                      selectedChips: selectedChips,
                      quantity: quantity,
                      priceText: priceText,
                      totalPriceText: totalPriceText,
                      hasSizeGuide: hasSizeGuide,
                      onOpenVariantsSheet: onOpenVariantsSheet ?? onArrowTap,
                      onSizeGuideTap: onSizeGuideTap,
                      onIncrement: onIncrementQuantity,
                      onDecrement: onDecrementQuantity,
                      attributeGroups: attributeGroups,
                      selectedAttributes: selectedAttributes,
                      onSelectAttribute: onSelectAttribute,
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

/// بطاقة عرض الخصائص المحددة والكمية والمبلغ الإجمالي مباشرة في الصفحة
class _ProductSelectionAndQuantitySection extends StatelessWidget {
  final bool hasVariations;
  final List<String> selectedChips;
  final int quantity;
  final String priceText;
  final String? totalPriceText;
  final bool hasSizeGuide;
  final VoidCallback? onOpenVariantsSheet;
  final VoidCallback? onSizeGuideTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  final List<ProductAttributeGroup> attributeGroups;
  final Map<String, String> selectedAttributes;
  final void Function(String groupId, String optionId)? onSelectAttribute;

  const _ProductSelectionAndQuantitySection({
    required this.hasVariations,
    required this.selectedChips,
    required this.quantity,
    required this.priceText,
    this.totalPriceText,
    required this.hasSizeGuide,
    this.onOpenVariantsSheet,
    this.onSizeGuideTap,
    this.onIncrement,
    this.onDecrement,
    this.attributeGroups = const [],
    this.selectedAttributes = const {},
    this.onSelectAttribute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border.withValues(alpha: 0.55)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // إذا كان للمنتج خيارات/خصائص (hasVariations)
          if (hasVariations) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: context.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: context.primary,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'الخصائص',
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  if (hasSizeGuide && onSizeGuideTap != null) ...[
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        onSizeGuideTap!();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4.5,
                        ),
                        decoration: BoxDecoration(
                          color: context.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: context.primary.withValues(alpha: 0.22),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.straighten_rounded,
                              size: 14,
                              color: context.primary,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              Tk.productDetailsSizeGuide.tr,
                              style: TextStyle(
                                color: context.primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (onOpenVariantsSheet != null)
                    InkWell(
                      onTap: onOpenVariantsSheet,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 3,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'المزيد',
                              style: TextStyle(
                                color: context.mutedForeground,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 9.5,
                              color: context.mutedForeground,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // خيارات الخصائص المباشرة التفاعلية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: _buildInteractiveOptions(context),
            ),

            Divider(
              height: 1,
              thickness: 0.6,
              color: context.border.withValues(alpha: 0.4),
            ),
          ],

          // صف اختيار الكمية وعرض المبلغ الإجمالي مباشرة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                // مغير الكمية (- 1 +)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'الكمية:',
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: context.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: context.border.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QuantityButton(
                            icon: Icons.remove_rounded,
                            enabled: quantity > 1,
                            onTap: onDecrement,
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 32),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '$quantity',
                              style: TextStyle(
                                color: context.foreground,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          _QuantityButton(
                            icon: Icons.add_rounded,
                            enabled: true,
                            onTap: onIncrement,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // المبلغ الإجمالي بناءً على الخصائص والكمية المحددة
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المجموع',
                      style: TextStyle(
                        color: context.mutedForeground,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalPriceText ?? priceText,
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveOptions(BuildContext context) {
    if (attributeGroups.isEmpty) {
      if (selectedChips.isNotEmpty) {
        return Wrap(
          spacing: 6,
          runSpacing: 4,
          children: selectedChips.map((chip) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: context.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Text(
                chip,
                style: TextStyle(
                  color: context.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 11.5,
                ),
              ),
            );
          }).toList(),
        );
      }
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: attributeGroups.map((group) {
        final currentOptId = selectedAttributes[group.id];

        ProductAttributeOption? currentOpt;
        for (final opt in group.options) {
          if (opt.id == currentOptId || opt.label == currentOptId) {
            currentOpt = opt;
            break;
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    group.name,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                  if (currentOpt != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      ': ${currentOpt.label.tr}',
                      style: TextStyle(
                        color: context.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              switch (group.type) {
                ProductAttributeType.color => _buildInlineColorOptions(
                  context,
                  group,
                  currentOptId,
                ),
                ProductAttributeType.image => _buildInlineImageOptions(
                  context,
                  group,
                  currentOptId,
                ),
                ProductAttributeType.text => _buildInlineTextOptions(
                  context,
                  group,
                  currentOptId,
                ),
              },
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInlineColorOptions(
    BuildContext context,
    ProductAttributeGroup group,
    String? currentOptId,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: group.options.map((opt) {
        final isSelected = opt.id == currentOptId || opt.label == currentOptId;
        final color = opt.colorValue;

        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelectAttribute?.call(group.id, opt.id);
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            constraints: const BoxConstraints(minHeight: 36),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.primary.withValues(alpha: 0.12)
                  : context.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? context.primary
                    : context.border.withValues(alpha: 0.5),
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.primary.withValues(alpha: 0.16),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (color != null)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == Colors.white
                            ? Colors.black26
                            : Colors.white.withValues(alpha: 0.8),
                        width: 1,
                      ),
                    ),
                  )
                else if (opt.imageUrl != null && opt.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: AppNetworkImage(url: opt.imageUrl!),
                    ),
                  ),
                const SizedBox(width: 6),
                Text(
                  opt.label.tr,
                  style: TextStyle(
                    color: isSelected ? context.primary : context.foreground,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: context.primary,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInlineImageOptions(
    BuildContext context,
    ProductAttributeGroup group,
    String? currentOptId,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: group.options.map((opt) {
        final isSelected = opt.id == currentOptId || opt.label == currentOptId;
        final imgUrl = opt.imageUrl ?? '';

        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelectAttribute?.call(group.id, opt.id);
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.primary.withValues(alpha: 0.12)
                  : context.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? context.primary
                    : context.border.withValues(alpha: 0.5),
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.primary.withValues(alpha: 0.16),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: imgUrl.isNotEmpty
                        ? AppNetworkImage(url: imgUrl, fit: BoxFit.cover)
                        : Container(
                            color: context.primary.withValues(alpha: 0.08),
                            child: Icon(
                              Icons.image_outlined,
                              size: 14,
                              color: context.primary,
                            ),
                          ),
                  ),
                ),
                if (opt.label.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Text(
                    opt.label.tr,
                    style: TextStyle(
                      color: isSelected ? context.primary : context.foreground,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w900
                          : FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInlineTextOptions(
    BuildContext context,
    ProductAttributeGroup group,
    String? currentOptId,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: group.options.map((opt) {
        final isSelected = opt.id == currentOptId || opt.label == currentOptId;

        return InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onSelectAttribute?.call(group.id, opt.id);
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minWidth: 44, minHeight: 36),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.primary.withValues(alpha: 0.12)
                  : context.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? context.primary
                    : context.border.withValues(alpha: 0.5),
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.primary.withValues(alpha: 0.16),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: context.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  opt.label.tr,
                  style: TextStyle(
                    color: isSelected ? context.primary : context.foreground,
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback? onTap;

  const _QuantityButton({
    required this.icon,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap?.call();
            }
          : null,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? context.foreground
              : context.mutedForeground.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
