import 'package:flutter/material.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';

class ProductRatingBadge extends StatelessWidget {
  final double fontSize;
  final double rating;
  final String? reviewsCountText;
  final bool showReviewsCount;

  const ProductRatingBadge({
    super.key,
    required this.fontSize,
    this.rating = 4.8,
    this.reviewsCountText = '4.2k',
    this.showReviewsCount = true,
  });

  @override
  Widget build(BuildContext context) {
    const starColor = BrandColors.gold;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: starColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 13, color: starColor),
          const SizedBox(width: 2),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              color: context.foreground,
              height: 1,
            ),
          ),
          if (showReviewsCount &&
              reviewsCountText != null &&
              reviewsCountText!.isNotEmpty) ...[
            const SizedBox(width: 3),
            Text(
              '($reviewsCountText)',
              style: TextStyle(
                fontSize: fontSize - 0.8,
                fontWeight: FontWeight.w600,
                color: context.mutedForeground,
                height: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
