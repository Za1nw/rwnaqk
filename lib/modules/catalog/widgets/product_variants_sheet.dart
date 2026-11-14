import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/widgets/app_network_image.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_attribute_group.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_size_guide_sheet.dart';

class ProductVariantsSheet extends ConsumerWidget {
  final String productId;

  const ProductVariantsSheet({
    super.key,
    required this.productId,
  });

  static Future<void> show(
    BuildContext context, {
    required String productId,
  }) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ProductVariantsSheet(productId: productId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailsFamily(productId));
    final notifier = ref.read(productDetailsFamily(productId).notifier);
    final maxH = MediaQuery.of(context).size.height * 0.88;

    final groups = state.attributeGroups;
    final selectedMap = state.selectedAttributes;

      // Resolve preview thumbnail: priority to selected style or color image
      String previewUrl = '';
      final selectedStyleId = selectedMap['style'];
      if (selectedStyleId != null) {
        for (final g in groups) {
          if (g.id == 'style') {
            for (final opt in g.options) {
              if (opt.id == selectedStyleId &&
                  (opt.imageUrl ?? '').isNotEmpty) {
                previewUrl = opt.imageUrl!;
                break;
              }
            }
          }
        }
      }
      if (previewUrl.isEmpty) {
        final selectedColorId = selectedMap['color'];
        if (selectedColorId != null) {
          for (final g in groups) {
            if (g.id == 'color') {
              for (final opt in g.options) {
                if (opt.id == selectedColorId &&
                    (opt.imageUrl ?? '').isNotEmpty) {
                  previewUrl = opt.imageUrl!;
                  break;
                }
              }
            }
          }
        }
      }
      if (previewUrl.isEmpty) {
        previewUrl = state.imageUrl.isNotEmpty
            ? state.imageUrl
            : (state.images.isNotEmpty ? state.images.first : '');
      }

      return Container(
        constraints: BoxConstraints(maxHeight: maxH),
        decoration: BoxDecoration(
          color: context.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: context.mutedForeground.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),

            // Product Mini Summary Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Product / Variant Image Thumbnail with fallback icon
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: context.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.border.withValues(alpha: 0.55),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: previewUrl.isNotEmpty
                        ? AppNetworkImage(
                            url: previewUrl,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: context.primary.withValues(alpha: 0.08),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.checkroom_rounded,
                                size: 28,
                                color: context.primary.withValues(alpha: 0.7),
                              ),
                            ),
                          )
                        : Container(
                            color: context.primary.withValues(alpha: 0.08),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.checkroom_rounded,
                              size: 28,
                              color: context.primary.withValues(alpha: 0.7),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),

                  // Price and Current Selection Summary
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (state.brand.isNotEmpty)
                          Text(
                            state.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.mutedForeground,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${state.salePriceText.replaceAll('.00', '')}',
                              style: TextStyle(
                                color: context.foreground,
                                fontWeight: FontWeight.w900,
                                fontSize: 21,
                                height: 1.1,
                              ),
                            ),
                            if (state.hasDiscount) ...[
                              const SizedBox(width: 8),
                              Text(
                                '\$${state.oldPriceText}',
                                style: TextStyle(
                                  color: context.mutedForeground,
                                  decoration: TextDecoration.lineThrough,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: context.destructive
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '-${state.discount}%',
                                  style: TextStyle(
                                    color: context.destructive,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          state.selectedOptionsSummary,
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

                  // Circular Close Button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: context.card,
                      shape: const CircleBorder(),
                    ),
                    icon: Icon(
                      Icons.close_rounded,
                      color: context.foreground,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 0.8),

            // Scrollable Dynamic Attributes
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                children: [
                  if (groups.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'لا توجد خصائص إضافية متاحة لهذا المنتج',
                          style: TextStyle(
                            color: context.mutedForeground,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  else
                    ...groups.map((group) {
                      final selectedOptionId = selectedMap[group.id];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: _AttributeGroupSection(
                          group: group,
                          selectedOptionId: selectedOptionId,
                          onSelectOption: (optId) {
                            HapticFeedback.selectionClick();
                            notifier.selectAttribute(group.id, optId);
                          },
                        ),
                      );
                    }),

                  const SizedBox(height: 4),

                  // Quantity Stepper Section
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.card.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: context.border.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Tk.productDetailsQty.tr,
                              style: TextStyle(
                                color: context.foreground,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              state.stockText,
                              style: TextStyle(
                                color: context.mutedForeground,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: context.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.border.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _MiniQtyButton(
                                icon: Icons.remove_rounded,
                                isEnabled: state.quantity > 1,
                                onTap: notifier.decrementQuantity,
                              ),
                              Container(
                                constraints: const BoxConstraints(minWidth: 40),
                                alignment: Alignment.center,
                                child: Text(
                                  '${state.quantity}',
                                  style: TextStyle(
                                    color: context.foreground,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              _MiniQtyButton(
                                icon: Icons.add_rounded,
                                isEnabled: state.quantity < 10,
                                onTap: notifier.incrementQuantity,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Bottom Actions: Single Line Dual Action Guaranteed NO WRAP
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: context.background,
                  border: Border(
                    top: BorderSide(
                      color: context.border.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Confirm Selection Button
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          side: BorderSide(color: context.primary, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          backgroundColor:
                              context.primary.withValues(alpha: 0.05),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'تأكيد الاختيار',
                            style: TextStyle(
                              color: context.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Add to Cart Button with Live Price
                    Expanded(
                      flex: 6,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          Navigator.of(context).pop();
                          notifier.addToCart(context);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          backgroundColor: context.primary,
                          foregroundColor: context.primaryForeground,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(
                          Icons.add_shopping_cart_rounded,
                          size: 18,
                        ),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'أضف (\$${state.totalPriceText.replaceAll('.00', '')})',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}

class _AttributeGroupSection extends StatelessWidget {
  final ProductAttributeGroup group;
  final String? selectedOptionId;
  final ValueChanged<String> onSelectOption;

  const _AttributeGroupSection({
    required this.group,
    required this.selectedOptionId,
    required this.onSelectOption,
  });

  ProductAttributeOption? get selectedOption {
    for (final opt in group.options) {
      if (opt.id == selectedOptionId) return opt;
    }
    return null;
  }

  bool get isSizeGroup =>
      group.id.toLowerCase().contains('size') ||
      group.name.contains('مقاس') ||
      group.name.toLowerCase().contains('size');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row
        Row(
          children: [
            Text(
              group.name,
              style: TextStyle(
                color: context.foreground,
                fontWeight: FontWeight.w900,
                fontSize: 14.5,
              ),
            ),
            if (selectedOption != null) ...[
              const SizedBox(width: 6),
              Text(
                '(${selectedOption!.label.tr})',
                style: TextStyle(
                  color: context.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
            const Spacer(),
            // If this is a size attribute group, offer direct Size Guide button
            if (isSizeGroup)
              InkWell(
                onTap: () => ProductSizeGuideSheet.show(
                  context,
                  currentSelectedSize: selectedOption?.label ?? '',
                  onSizeSelected: (size) {
                    onSelectOption(size);
                  },
                ),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.straighten_rounded,
                        size: 15,
                        color: context.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Tk.productDetailsSizeGuide.tr,
                        style: TextStyle(
                          color: context.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
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

        // Render according to ProductAttributeType
        if (group.type == ProductAttributeType.color)
          _buildColorOptions(context)
        else if (group.type == ProductAttributeType.image)
          _buildImageOptions(context)
        else
          _buildTextOptions(context),
      ],
    );
  }

  Widget _buildColorOptions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: group.options.map((option) {
        final isSelected = option.id == selectedOptionId;
        final color = option.colorValue;

        return InkWell(
          onTap: () => onSelectOption(option.id),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.primary.withValues(alpha: 0.10)
                  : context.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? context.primary
                    : context.border.withValues(alpha: 0.45),
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.primary.withValues(alpha: 0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (color != null)
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: color == Colors.white
                            ? Colors.black26
                            : Colors.white.withValues(alpha: 0.8),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  )
                else if (option.imageUrl != null &&
                    option.imageUrl!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: AppNetworkImage(url: option.imageUrl!),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  option.label.tr,
                  style: TextStyle(
                    color: isSelected ? context.primary : context.foreground,
                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.check_rounded,
                    size: 16,
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

  Widget _buildImageOptions(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: group.options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, index) {
          final option = group.options[index];
          final isSelected = option.id == selectedOptionId;
          final imgUrl = option.imageUrl ?? '';

          return InkWell(
            onTap: () => onSelectOption(option.id),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: context.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? context.primary
                      : context.border.withValues(alpha: 0.45),
                  width: isSelected ? 2.2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: context.primary.withValues(alpha: 0.22),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: imgUrl.isNotEmpty
                          ? AppNetworkImage(
                              url: imgUrl,
                              fit: BoxFit.cover,
                              errorWidget: Container(
                                color: context.primary.withValues(alpha: 0.08),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.style_rounded,
                                  size: 26,
                                  color: context.primary.withValues(alpha: 0.6),
                                ),
                              ),
                            )
                          : Container(
                              color: context.primary.withValues(alpha: 0.08),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.style_rounded,
                                size: 26,
                                color: context.primary.withValues(alpha: 0.6),
                              ),
                            ),
                    ),
                    if (isSelected)
                      PositionedDirectional(
                        top: 4,
                        end: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            color: context.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_rounded,
                            size: 11,
                            color: context.primaryForeground,
                          ),
                        ),
                      ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        color: Colors.black.withValues(alpha: 0.6),
                        child: Text(
                          option.label.length <= 2
                              ? 'نمط ${option.label}'
                              : option.label.tr,
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
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextOptions(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: group.options.map((option) {
        final isSelected = option.id == selectedOptionId;

        return InkWell(
          onTap: () => onSelectOption(option.id),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: const BoxConstraints(minWidth: 54, minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? context.primary : context.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? context.primary
                    : context.border.withValues(alpha: 0.45),
                width: isSelected ? 1.8 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: context.primary.withValues(alpha: 0.20),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.label.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected
                        ? context.primaryForeground
                        : context.foreground,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
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

class _MiniQtyButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onTap;

  const _MiniQtyButton({
    required this.icon,
    this.isEnabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEnabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isEnabled ? 1.0 : 0.35,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: context.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.border.withValues(alpha: 0.35)),
          ),
          child: Icon(icon, size: 16, color: context.foreground),
        ),
      ),
    );
  }
}
