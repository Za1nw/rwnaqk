import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/widgets/app_network_image.dart';
import 'package:rwnaqk/controllers/reviews_controller.dart';

class ReviewsScreen extends GetView<ReviewsController> {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                child: Obx(() {
                  final reviews = controller.reviews;
                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (_, i) => _ReviewTile(
                      name: reviews[i].name,
                      rating: reviews[i].rating,
                      text: reviews[i].text,
                      avatarUrl: reviews[i].avatarUrl,
                      dateText: reviews[i].dateText,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final String name;
  final double rating;
  final String text;
  final String? avatarUrl;
  final String? dateText;

  const _ReviewTile({
    required this.name,
    required this.rating,
    required this.text,
    this.avatarUrl,
    this.dateText,
  });

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
          _Avatar(name: name, avatarUrl: avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          color: context.foreground,
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
                          height: 1.1,
                        ),
                      ),
                    ),
                    if (dateText != null && dateText!.trim().isNotEmpty)
                      Text(
                        dateText!,
                        style: TextStyle(
                          color: context.mutedForeground,
                          fontWeight: FontWeight.w700,
                          fontSize: 11.5,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                _StarsRow(rating: rating),
                const SizedBox(height: 10),
                Text(
                  text,
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
            ? AppNetworkImage(url: avatarUrl!)
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