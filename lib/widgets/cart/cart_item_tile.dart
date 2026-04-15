import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/app_network_image.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';

import '../../models/home_product_item.dart';
import '../common/quantity_stepper.dart';

/// ✅ Cart item card (styled like the provided mock)
/// - Image + delete
/// - QuantityStepper below the image
/// - Product info on the right (title + variations + price/discount)
/// - Bottom row shows total for this item
///
/// Notes:
/// - Theme-aware (supports light/dark)
/// - Locale-aware (all labels use translations)
class CartItemTile extends StatelessWidget {
  final HomeProductItem item;

  final int quantity;
  final String? variantText;
  final double? rating;
  final int? reviewsCount;

  final VoidCallback onRemove;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  final VoidCallback? onTap;

  // Layout
  final double imageSize;
  final double tileRadius;
  final double imageRadius;
  final EdgeInsetsDirectional contentPadding;

  const CartItemTile({
    super.key,
    required this.item,
    required this.quantity,
    required this.onRemove,
    required this.onIncrement,
    required this.onDecrement,
    this.variantText,
    this.rating,
    this.reviewsCount,
    this.onTap,
    this.imageSize = 122,
    this.tileRadius = 20,
    this.imageRadius = 16,
    this.contentPadding = const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 10),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(tileRadius);
    final w = MediaQuery.of(context).size.width;
    final isSmall = w < 360;

    final hasDiscount = item.hasDiscount;
    final salePrice = item.salePrice;
    final originalPrice = item.price;
    final total = salePrice * quantity;
    final variations = _parseVariations(variantText);
    final material = (item.material ?? '').trim();
    final ratingValue = (rating != null && rating! > 0) ? rating : null;
    final reviews = (reviewsCount != null && reviewsCount! > 0)
        ? reviewsCount
        : null;

    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.border.withOpacity(.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: context.primary.withOpacity(0.05),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImageWithDeleteAndStepper(
                    imageUrl: item.imageUrl,
                    size: imageSize,
                    radius: imageRadius,
                    onRemove: onRemove,
                    quantity: quantity,
                    onIncrement: onIncrement,
                    onDecrement: onDecrement,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title.tr,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.foreground,
                            fontWeight: FontWeight.w900,
                            fontSize: isSmall ? 13.8 : 15,
                            height: 1.15,
                            letterSpacing: 0.1,
                          ),
                        ),
                        if (variations.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final v in variations) _VariationChip(text: v),
                            ],
                          ),
                        ],
                        if (material.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 6,
                            children: [
                              if (material.isNotEmpty)
                                _MetaText(
                                  value:
                                      '${Tk.productDetailsMaterial.tr}: ${material.tr}',
                                ),
                            ],
                          ),
                        ],
                        if (ratingValue != null) ...[
                          const SizedBox(height: 8),
                          _RatingRow(
                            rating: ratingValue,
                            reviewsCount: reviews,
                            isSmall: isSmall,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _PricePill(
                              priceText: '\$${salePrice.toStringAsFixed(2)}',
                              isSmall: isSmall,
                            ),
                            if (hasDiscount) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      Tk.productDiscountOff.trParams({
                                        'value': '${item.discountPercent ?? 0}',
                                      }),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: context.destructive,
                                        fontWeight: FontWeight.w700,
                                        fontSize: isSmall ? 11 : 12,
                                        height: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '\$${originalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: context.mutedForeground,
                                        fontWeight: FontWeight.w800,
                                        fontSize: isSmall ? 11.5 : 12.5,
                                        decoration: TextDecoration.lineThrough,
                                        height: 1.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(
                height: 1,
                thickness: 1,
                color: context.border.withOpacity(.65),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    '${Tk.cartTotal.tr} ($quantity) :',
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w700,
                      fontSize: isSmall ? 12.5 : 13.5,
                      height: 1.0,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: isSmall ? 13.5 : 14.5,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<String> _parseVariations(String? text) {
    if (text == null) return const [];
    final t = text.trim();
    if (t.isEmpty) return const [];
    final parts = t
        .split(RegExp(r'(?:\s-\s)|[,/|]'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return parts.isEmpty ? [t] : parts;
  }
}

class _ImageWithDeleteAndStepper extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double radius;
  final VoidCallback onRemove;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _ImageWithDeleteAndStepper({
    required this.imageUrl,
    required this.size,
    required this.radius,
    required this.onRemove,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: AppNetworkImage(url: imageUrl, fit: BoxFit.cover),
                ),
              ),
              PositionedDirectional(
                top: -10,
                end: 100,
                child: AppActionIconButton(
                  icon: Icons.delete_outline_rounded,
                  iconColor: context.destructive,
                  onTap: onRemove,
                  size: 30,
                  iconSize: 25,
                  radius: 99,
                  borderColor: context.background,
                  backgroundColor: context.background.withOpacity(.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: QuantityStepper(
              value: quantity,
              onIncrement: onIncrement,
              onDecrement: onDecrement,
              min: 1,
              height: 32,
              buttonSize: 32,
              radius: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _VariationChip extends StatelessWidget {
  final String text;

  const _VariationChip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.background.withOpacity(context.isDark ? 0.18 : 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border.withOpacity(0.35)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: context.mutedForeground,
          fontWeight: FontWeight.w800,
          fontSize: 13,
          height: 1.0,
        ),
      ),
    );
  }
}

class _PricePill extends StatelessWidget {
  final String priceText;
  final bool isSmall;

  const _PricePill({required this.priceText, required this.isSmall});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 14,
        vertical: isSmall ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color: context.background.withOpacity(context.isDark ? 0.10 : 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border.withOpacity(0.45)),
      ),
      child: Text(
        priceText,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: context.foreground,
          fontWeight: FontWeight.w900,
          fontSize: isSmall ? 15.5 : 17,
          height: 1.0,
        ),
      ),
    );
  }
}

class _MetaText extends StatelessWidget {
  final String value;

  const _MetaText({
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: context.mutedForeground,
        fontWeight: FontWeight.w800,
        fontSize: 12,
        height: 1.0,
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  final int? reviewsCount;
  final bool isSmall;

  const _RatingRow({
    required this.rating,
    required this.reviewsCount,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    final r = rating.clamp(0, 5).toDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          r.toStringAsFixed(1),
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w800,
            fontSize: isSmall ? 12 : 13,
            height: 1.0,
          ),
        ),
        const SizedBox(width: 8),
        _Stars(value: r, size: isSmall ? 16 : 18),
        if (reviewsCount != null) ...[
          const SizedBox(width: 8),
          Text(
            '(${reviewsCount.toString()})',
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w700,
              fontSize: isSmall ? 11 : 12,
              height: 1.0,
            ),
          ),
        ],
      ],
    );
  }
}

class _Stars extends StatelessWidget {
  final double value;
  final double size;

  const _Stars({required this.value, required this.size});

  @override
  Widget build(BuildContext context) {
    IconData iconFor(int index) {
      final v = value - index;
      if (v >= 1) return Icons.star_rounded;
      if (v >= 0.5) return Icons.star_half_rounded;
      return Icons.star_outline_rounded;
    }

    final starColor =
        context.isDark ? const Color(0xFFFFC107) : const Color(0xFFFFB300);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          iconFor(i),
          color: starColor,
          size: size,
        ),
      ),
    );
  }
}
