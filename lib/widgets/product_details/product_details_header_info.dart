import 'package:flutter/material.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/product_details/product_share_button.dart';

class ProductDetailsHeaderInfo extends StatelessWidget {
  final String title;
  final String description;

  final String priceText;
  final String? oldPriceText;
  final String? discountText;
  final Widget? timerWidget;

  final double? rating;
  final int? reviewsCount;
  final String? infoText;

  final double titleSize;
  final double priceSize;
  final double descSize;
  final double rowGap;
  final bool isWide;

  final VoidCallback onShare;

  const ProductDetailsHeaderInfo({
    super.key,
    required this.title,
    required this.description,
    required this.priceText,
    this.oldPriceText,
    this.discountText,
    this.timerWidget,
    this.rating,
    this.reviewsCount,
    this.infoText,
    required this.titleSize,
    required this.priceSize,
    required this.descSize,
    required this.rowGap,
    required this.isWide,
    required this.onShare,
  });

  bool get hasDiscount =>
      (oldPriceText != null && oldPriceText!.trim().isNotEmpty) &&
      (discountText != null && discountText!.trim().isNotEmpty);

  bool get hasMeta =>
      rating != null ||
      reviewsCount != null ||
      ((infoText ?? '').trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: titleSize,
            height: 1.15,
          ),
        ),
        if (hasMeta) ...[
          const SizedBox(height: 8),
          _MetaRow(
            rating: rating,
            reviewsCount: reviewsCount,
            infoText: infoText,
          ),
        ],
        SizedBox(height: rowGap + 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    priceText,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: priceSize,
                      height: 1.0,
                    ),
                  ),
                  if (hasDiscount) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
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
                        _DiscountBadge(text: discountText!),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (timerWidget != null) ...[
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: timerWidget!,
              ),
            ],
            const SizedBox(width: 10),
            AppShareButton(onTap: onShare, size: 32),
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
            fontSize: descSize,
          ),
        ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  final double? rating;
  final int? reviewsCount;
  final String? infoText;

  const _MetaRow({
    this.rating,
    this.reviewsCount,
    this.infoText,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 6,
      children: [
        if (rating != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                rating!.toStringAsFixed(1),
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        if (reviewsCount != null)
          Text(
            '$reviewsCount reviews',
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w700,
              fontSize: 12.2,
            ),
          ),
        if ((infoText ?? '').trim().isNotEmpty)
          Text(
            infoText!,
            style: TextStyle(
              color: context.primary,
              fontWeight: FontWeight.w800,
              fontSize: 12.2,
            ),
          ),
      ],
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