import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/widgets/app_network_image.dart';
import 'package:rwnaqk/widgets/common/app_action_icon_button.dart';
import 'package:rwnaqk/widgets/common/add_to_cart_animated_button.dart';

import '../../models/home_product_item.dart';

class WishlistItemTile extends StatelessWidget {
  final HomeProductItem item;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final VoidCallback onAddToCart;
  final String? variantText;
  final bool showRemoveButton;
  final double imageSize;
  final double tileRadius;
  final double imageRadius;
  final EdgeInsetsDirectional contentPadding;

  const WishlistItemTile({
    super.key,
    required this.item,
    required this.onAddToCart,
    this.onRemove,
    this.onTap,
    this.variantText,
    this.showRemoveButton = true,
    this.imageSize = 118,
    this.tileRadius = 20,
    this.imageRadius = 16,
    this.contentPadding = const EdgeInsetsDirectional.fromSTEB(14, 14, 14, 12),
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(tileRadius);
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 360;
    final hasDiscount = item.hasDiscount;
    final salePrice = item.salePrice;
    final originalPrice = item.price;
    final variations = _parseVariations(variantText);
    final material = (item.material ?? '').trim();

    return Material(
      color: context.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: context.border.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: context.primary.withValues(alpha: 0.05),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ImageWithDelete(
                    imageUrl: item.imageUrl,
                    size: imageSize,
                    radius: imageRadius,
                    onRemove: onRemove,
                    showRemoveButton: showRemoveButton,
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
                              for (final variation in variations)
                                _VariationChip(text: variation),
                            ],
                          ),
                        ],
                        if (material.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          _MetaText(
                            value:
                                '${Tk.productDetailsMaterial.tr}: ${material.tr}',
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
                color: context.border.withValues(alpha: 0.65),
              ),
              const SizedBox(height: 12),
              AddToCartAnimatedButton(
                label: Tk.homeAddToCart.tr,
                onPressed: onAddToCart,
                height: isSmall ? 48 : 50,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static List<String> _parseVariations(String? text) {
    if (text == null) return const [];
    final trimmed = text.trim();
    if (trimmed.isEmpty) return const [];

    final parts = trimmed
        .split(RegExp(r'(?:\s-\s)|[,/|]'))
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);

    return parts.isEmpty ? [trimmed] : parts;
  }
}

class _ImageWithDelete extends StatelessWidget {
  final String imageUrl;
  final double size;
  final double radius;
  final VoidCallback? onRemove;
  final bool showRemoveButton;

  const _ImageWithDelete({
    required this.imageUrl,
    required this.size,
    required this.radius,
    required this.onRemove,
    required this.showRemoveButton,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Stack(
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
          if (showRemoveButton && onRemove != null)
            PositionedDirectional(
              top: -8,
              end: -8,
              child: AppActionIconButton(
                icon: Icons.delete_outline_rounded,
                iconColor: context.destructive,
                onTap: onRemove,
                size: 30,
                iconSize: 22,
                radius: 99,
                borderColor: context.background,
                backgroundColor: context.background.withValues(alpha: 0.94),
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
        color:
            context.background.withValues(alpha: context.isDark ? 0.18 : 0.75),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border.withValues(alpha: 0.35)),
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

  const _PricePill({
    required this.priceText,
    required this.isSmall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 12 : 14,
        vertical: isSmall ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color:
            context.background.withValues(alpha: context.isDark ? 0.10 : 0.85),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border.withValues(alpha: 0.45)),
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
