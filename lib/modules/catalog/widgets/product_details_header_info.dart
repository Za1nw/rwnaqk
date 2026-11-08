import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class ProductDetailsHeaderInfo extends StatefulWidget {
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

  final double titleSize;
  final double priceSize;
  final double descSize;
  final double rowGap;
  final bool isWide;

  final VoidCallback? onShare;

  const ProductDetailsHeaderInfo({
    super.key,
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
    required this.titleSize,
    required this.priceSize,
    required this.descSize,
    required this.rowGap,
    required this.isWide,
    this.onShare,
  });

  @override
  State<ProductDetailsHeaderInfo> createState() =>
      _ProductDetailsHeaderInfoState();
}

class _ProductDetailsHeaderInfoState extends State<ProductDetailsHeaderInfo> {
  bool _isDescriptionExpanded = false;

  bool get hasDiscount =>
      (widget.oldPriceText != null &&
          widget.oldPriceText!.trim().isNotEmpty) &&
      (widget.discountText != null &&
          widget.discountText!.trim().isNotEmpty);

  bool get hasMeta =>
      widget.rating != null ||
      widget.reviewsCount != null ||
      ((widget.infoText ?? '').trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand Eyebrow if available
        if ((widget.brand ?? '').trim().isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: context.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              widget.brand!.toUpperCase(),
              style: TextStyle(
                color: context.primary,
                fontWeight: FontWeight.w900,
                fontSize: 11,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Title
        Text(
          widget.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: widget.titleSize,
            height: 1.25,
          ),
        ),

        // Meta row: Rating + Reviews + In-Stock Badge
        if (hasMeta) ...[
          const SizedBox(height: 10),
          _MetaRow(
            rating: widget.rating,
            reviewsCount: widget.reviewsCount,
            infoText: widget.infoText,
          ),
        ],

        SizedBox(height: widget.rowGap + 4),

        // Price Row + Actions
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.priceText,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: widget.priceSize,
                          height: 1.0,
                        ),
                      ),
                      if (hasDiscount) ...[
                        const SizedBox(width: 10),
                        Text(
                          widget.oldPriceText!,
                          style: TextStyle(
                            color: context.mutedForeground,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            decoration: TextDecoration.lineThrough,
                            decorationThickness: 1.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _DiscountBadge(text: widget.discountText!),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  // VAT included note
                  Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 13,
                        color: context.mutedForeground,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Tk.productDetailsVatIncluded.tr,
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (widget.timerWidget != null) ...[
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: widget.timerWidget!,
              ),
            ],
          ],
        ),

        SizedBox(height: widget.rowGap + 2),

        // Description with Read More / Read Less
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.description,
              maxLines: _isDescriptionExpanded
                  ? null
                  : (widget.isWide ? 4 : 3),
              overflow: _isDescriptionExpanded
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: TextStyle(
                color: context.mutedForeground,
                height: 1.45,
                fontWeight: FontWeight.w600,
                fontSize: widget.descSize,
              ),
            ),
            if (widget.description.length > 90) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(
                  () => _isDescriptionExpanded = !_isDescriptionExpanded,
                ),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    _isDescriptionExpanded
                        ? Tk.productDetailsReadLess.tr
                        : Tk.productDetailsReadMore.tr,
                    style: TextStyle(
                      color: context.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
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
          ),
        if (reviewsCount != null)
          Text(
            '(${Tk.reviewsCount.trParams({'count': '$reviewsCount'})})',
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        if ((infoText ?? '').trim().isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: context.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: context.success.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: context.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  infoText!,
                  style: TextStyle(
                    color: context.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.destructive.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: context.destructive.withValues(alpha: 0.30)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: context.destructive,
          fontWeight: FontWeight.w900,
          fontSize: 11.5,
          height: 1.0,
        ),
      ),
    );
  }
}
