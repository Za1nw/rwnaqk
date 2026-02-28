import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_network_image.dart';

// لو عندك ProductReview موديل خارجي، احذف هذا الكلاس واعمل import
class ProductReview {
  final String name;
  final double rating;
  final String text;
  final String? avatarUrl;
  final String? dateText;

  const ProductReview({
    required this.name,
    required this.rating,
    required this.text,
    this.avatarUrl,
    this.dateText,
  });

  factory ProductReview.fromMap(Map<String, dynamic> map) {
    return ProductReview(
      name: (map['name'] ?? '').toString(),
      rating: double.tryParse((map['rating'] ?? 0).toString()) ?? 0,
      text: (map['text'] ?? '').toString(),
      avatarUrl: map['avatarUrl']?.toString(),
      dateText: map['dateText']?.toString(),
    );
  }
}

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  // ✅ بيانات Static داخل الصفحة نفسها
  List<ProductReview> _staticReviews() => const [
        ProductReview(
          name: 'Anna',
          rating: 4.5,
          text: 'Nice product, great quality and fast shipping.',
          dateText: '2 days ago',
        ),
        ProductReview(
          name: 'John',
          rating: 5,
          text: 'Perfect! Exactly as described.',
          dateText: '1 week ago',
        ),
        ProductReview(
          name: 'Sara',
          rating: 4,
          text: 'Good overall, but the packaging can be better.',
          dateText: '3 weeks ago',
        ),
        ProductReview(
          name: 'Khaled',
          rating: 3.5,
          text: 'It is okay, could be improved.',
          dateText: '1 month ago',
        ),
      ];

  // ✅ يستقبل أي نوع arguments بدون كسر
  List<ProductReview> _resolveReviews(dynamic arg) {
    if (arg == null) return _staticReviews();

    // List<ProductReview>
    if (arg is List<ProductReview> && arg.isNotEmpty) return arg;

    // {reviews: [...]}
    if (arg is Map && arg['reviews'] != null) {
      return _resolveReviews(arg['reviews']);
    }

    // List<Map>
    if (arg is List && arg.isNotEmpty) {
      return arg.map((e) {
        if (e is ProductReview) return e;
        if (e is Map<String, dynamic>) return ProductReview.fromMap(e);
        if (e is Map) return ProductReview.fromMap(Map<String, dynamic>.from(e));
        return const ProductReview(name: 'Unknown', rating: 0, text: '');
      }).toList();
    }

    return _staticReviews();
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _resolveReviews(Get.arguments);

    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back_ios_new_rounded, color: context.foreground),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Reviews',
                    style: TextStyle(
                      color: context.foreground,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: reviews.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => _ReviewTile(review: reviews[i]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final ProductReview review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: context.shadow.withOpacity(context.isDark ? 0.14 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(name: review.name, avatarUrl: review.avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // name + date
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.name,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (review.dateText != null && review.dateText!.trim().isNotEmpty)
                      Text(
                        review.dateText!,
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 6),
                _StarsRow(rating: review.rating),
                const SizedBox(height: 10),

                Text(
                  review.text,
                  style: TextStyle(
                    color: context.mutedForeground,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.8,
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

class _Avatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  const _Avatar({required this.name, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final letter = name.trim().isNotEmpty ? name.trim().characters.first.toUpperCase() : '?';

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 44,
        height: 44,
        color: context.muted,
        alignment: Alignment.center,
        child: (avatarUrl != null && avatarUrl!.trim().isNotEmpty)
            ? AppNetworkImage(url: avatarUrl!) // أو Image.network
            : Text(
                letter,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                ),
              ),
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  final double rating;
  const _StarsRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    final r = rating.clamp(0, 5);
    final full = r.floor().clamp(0, 5);
    final hasHalf = (r - r.floor()) >= 0.5 && full < 5;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < full) {
          return const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B));
        }
        if (i == full && hasHalf) {
          return const Icon(Icons.star_half_rounded, size: 18, color: Color(0xFFF59E0B));
        }
        return Icon(Icons.star_rounded, size: 18, color: context.border.withOpacity(0.8));
      }),
    );
  }
}