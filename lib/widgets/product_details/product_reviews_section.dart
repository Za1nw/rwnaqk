import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/models/product_review.dart';

class ProductReviewsSection extends StatelessWidget {
  final String? title;
  final List<ProductReview> reviews;
  final VoidCallback? onViewAll;
  final String? viewAllText;
  final bool previewOnly;

  const ProductReviewsSection({
    super.key,
    this.title,
    required this.reviews,
    this.onViewAll,
    this.viewAllText,
    this.previewOnly = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? Tk.reviewsSectionTitle.tr;

    if (reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: resolvedTitle),
          const SizedBox(height: 10),
          const _EmptyReviews(),
        ],
      );
    }

    final items = previewOnly ? reviews.take(1).toList() : reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: resolvedTitle),
        const SizedBox(height: 10),
        ...items.map(
          (review) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ReviewCard(review: review),
          ),
        ),
        if (onViewAll != null) ...[
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: onViewAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: context.primaryForeground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(viewAllText ?? Tk.reviewsViewAll.tr),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: context.foreground,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  const _EmptyReviews();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border.withOpacity(0.55)),
      ),
      child: Text(
        Tk.reviewsEmpty.tr,
        style: TextStyle(color: context.mutedForeground),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ProductReview review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border.withOpacity(0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.muted,
            foregroundColor: context.foreground,
            child: Text(
              review.name.isNotEmpty
                  ? review.name.characters.first.toUpperCase()
                  : '?',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: context.foreground,
                        ),
                      ),
                    ),
                    _StarsRow(rating: review.rating),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  review.text.tr,
                  style: TextStyle(
                    color: context.mutedForeground,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final double rating;

  const _StarsRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor().clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < full;
        return Icon(
          Icons.star_rounded,
          size: 18,
          color: filled ? const Color(0xFFF59E0B) : context.border,
        );
      }),
    );
  }
}
