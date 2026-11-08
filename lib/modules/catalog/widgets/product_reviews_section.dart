import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/add_review_sheet.dart';

class ProductReviewsSection extends StatelessWidget {
  final String? title;
  final List<ProductReview> reviews;
  final VoidCallback? onViewAll;
  final String? viewAllText;
  final bool previewOnly;
  final Function(double rating, String comment, String name)? onAddReview;

  const ProductReviewsSection({
    super.key,
    this.title,
    required this.reviews,
    this.onViewAll,
    this.viewAllText,
    this.previewOnly = true,
    this.onAddReview,
  });

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  void _openAddReview(BuildContext context) {
    AddReviewSheet.show(
      context,
      onSubmit: (rating, comment, name) {
        if (onAddReview != null) {
          onAddReview!(rating, comment, name);
        } else if (Get.isRegistered<ProductDetailsController>()) {
          Get.find<ProductDetailsController>().addReview(
            rating: rating,
            comment: comment,
            name: name,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? Tk.reviewsSectionTitle.tr;

    if (reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: resolvedTitle,
            count: 0,
            rating: null,
            onAddTap: () => _openAddReview(context),
          ),
          const SizedBox(height: 10),
          _EmptyReviews(onAddTap: () => _openAddReview(context)),
        ],
      );
    }

    final items = previewOnly ? reviews.take(2).toList() : reviews;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title: resolvedTitle,
          count: reviews.length,
          rating: averageRating,
          onAddTap: () => _openAddReview(context),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (review) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _ReviewCard(review: review),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () => _openAddReview(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: context.primary.withValues(alpha: 0.35),
                    ),
                    backgroundColor: context.primary.withValues(alpha: 0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    Icons.rate_review_outlined,
                    size: 16,
                    color: context.primary,
                  ),
                  label: Text(
                    'أضف تقييمك',
                    style: TextStyle(
                      color: context.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            if (onViewAll != null) ...[
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onViewAll,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: context.border.withValues(alpha: 0.45),
                      ),
                      backgroundColor: context.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      viewAllText ??
                          '${Tk.reviewsViewAll.tr} (${reviews.length})',
                      style: TextStyle(
                        color: context.foreground,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
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

class _SectionTitle extends StatelessWidget {
  final String title;
  final int count;
  final double? rating;
  final VoidCallback? onAddTap;

  const _SectionTitle({
    required this.title,
    this.count = 0,
    this.rating,
    this.onAddTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: context.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: context.foreground,
          ),
        ),
        if (count > 0 && rating != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                const SizedBox(width: 3),
                Text(
                  rating!.toStringAsFixed(1),
                  style: TextStyle(
                    color: context.foreground,
                    fontWeight: FontWeight.w900,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
        const Spacer(),
        if (onAddTap != null)
          InkWell(
            onTap: onAddTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_note_rounded,
                    size: 18,
                    color: context.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'كتابة مراجعة',
                    style: TextStyle(
                      color: context.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.underline,
                      decorationColor: context.primary.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyReviews extends StatelessWidget {
  final VoidCallback onAddTap;

  const _EmptyReviews({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 32,
            color: context.mutedForeground,
          ),
          const SizedBox(height: 8),
          Text(
            Tk.reviewsEmpty.tr,
            style: TextStyle(
              color: context.mutedForeground,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: onAddTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: context.primary,
              foregroundColor: context.primaryForeground,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'كن أول من يقيّم هذا المنتج',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
          ),
        ],
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
        border: Border.all(color: context.border.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withValues(alpha: context.isDark ? 0.08 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: context.primary.withValues(alpha: 0.12),
                foregroundColor: context.primary,
                child: Text(
                  review.name.isNotEmpty
                      ? review.name.characters.first.toUpperCase()
                      : '?',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: context.foreground,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: context.success,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'مشتري معتمد',
                          style: TextStyle(
                            color: context.success,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _StarsRow(rating: review.rating),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.text.tr,
            style: TextStyle(
              color: context.mutedForeground,
              height: 1.4,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
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
          size: 16,
          color: filled ? Colors.amber : context.border.withValues(alpha: 0.5),
        );
      }),
    );
  }
}
