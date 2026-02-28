import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/product_details/product_countdown_pill.dart';
import 'package:rwnaqk/widgets/product_details/product_details_header_card.dart';
import 'package:rwnaqk/widgets/product_details/product_reviews_section.dart';
import 'package:rwnaqk/widgets/home/product_card.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int selectedThumb = 0;
  bool isFavorite = false;

  // delivery mock
  String deliverySelected = 'standard';


  List<ProductReview> _resolveReviews(dynamic args) {
    // supports:
    // - args['reviews'] as List<ProductReview>
    // - args['reviews'] as List<Map> (name/rating/text)
    final raw = (args is Map ? args['reviews'] : null);
    if (raw is List<ProductReview>) return raw;

    if (raw is List) {
      final out = <ProductReview>[];
      for (final e in raw) {
        if (e is ProductReview) {
          out.add(e);
        } else if (e is Map) {
          out.add(ProductReview(
            name: (e['name'] ?? 'User').toString(),
            rating: double.tryParse((e['rating'] ?? 0).toString()) ?? 0,
            text: (e['text'] ?? '').toString(),
          ));
        }
      }
      if (out.isNotEmpty) return out;
    }

    // fallback demo preview
    return const [
      ProductReview(
        name: 'Veronika',
        rating: 4.0,
        text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam...',
      ),
    ];
  }

  List<HomeProductItem> _resolveItems(dynamic args, String key) {
    final raw = (args is Map ? args[key] : null);
    if (raw is List<HomeProductItem>) return raw;
    if (raw is List) {
      return raw.whereType<HomeProductItem>().toList();
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final item = (args is Map ? args['item'] : null) as HomeProductItem?;

    // fallback
    final price = item?.price ?? 17;
    final discount = item?.discountPercent ?? 0;
    final hasDiscount = discount > 0;

    final salePrice = hasDiscount
        ? (price * (1 - discount / 100)).toStringAsFixed(2)
        : price.toStringAsFixed(2);

    final images = <String>[
      if ((item?.imageUrl ?? '').isNotEmpty) item!.imageUrl,
      'https://picsum.photos/500/650?pd_a',
      'https://picsum.photos/500/650?pd_b',
      'https://picsum.photos/500/650?pd_c',
    ];

    final variationImages = images.take(3).toList();

    return Scaffold(
      backgroundColor: context.background,
      bottomNavigationBar: _BottomBar(
        isFavorite: isFavorite,
        onFavorite: () => setState(() => isFavorite = !isFavorite),
        onAdd: () => Get.snackbar('Cart', 'Added to cart'),
        onBuy: () => Get.snackbar('Buy', 'Proceed to checkout'),
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          children: [
            // HEADER (مع/بدون خصم + share + timer)
            ProductDetailsHeaderCard(
              images: images,
              priceText: '\$${salePrice.replaceAll(".00", "")}',
              oldPriceText: hasDiscount ? '\$${price.toStringAsFixed(2)}' : null,
              discountText: hasDiscount ? '-$discount%' : null,
              timerWidget: hasDiscount
                  ? ProductCountdownPill(
                      endsAt: DateTime.now().add(const Duration(hours: 1, minutes: 36)),
                    )
                  : null,
              description:
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvinar sapien.',
              variationImages: variationImages,
              selectedVariationImageIndex: selectedThumb.clamp(0, variationImages.length - 1),
              onSelectVariationImage: (i) => setState(() => selectedThumb = i),
              onShare: () => Get.snackbar('Share', 'Share product'),
            ),

            const SizedBox(height: 18),

            // ======================
            // Specifications (بسيطة - تقدر تستبدلها بمكوّنك)
            // ======================
            _SectionTitle(title: 'Specifications'),
            const SizedBox(height: 10),
            _SpecRow(
              title: 'Material',
              chips: const ['Cotton 95%', 'Nylon 5%'],
            ),
            const SizedBox(height: 10),
            _SpecRow(
              title: 'Origin',
              chips: const ['EU'],
            ),
            const SizedBox(height: 10),
            _LinkRow(
              text: 'Size guide',
              onTap: () => Get.snackbar('Size guide', 'Open size guide'),
            ),

            const SizedBox(height: 18),

            // ======================
            // Delivery
            // ======================
            _SectionTitle(title: 'Delivery'),
            const SizedBox(height: 10),
            _DeliveryOption(
              title: 'Standart',
              subtitle: '5-7 days',
              price: '\$3.00',
              selected: deliverySelected == 'standard',
              onTap: () => setState(() => deliverySelected = 'standard'),
            ),
            const SizedBox(height: 10),
            _DeliveryOption(
              title: 'Express',
              subtitle: '1-2 days',
              price: '\$12.00',
              selected: deliverySelected == 'express',
              onTap: () => setState(() => deliverySelected = 'express'),
            ),

            const SizedBox(height: 18),
            // ======================
            // Rating & Reviews (component)
            // ======================
            ProductReviewsSection(
              reviews: _resolveReviews(args),
              onViewAll: () => Get.toNamed(AppRoutes.reviews),
            ),

            const SizedBox(height: 18),

            // ======================
            // Most Popular (Horizontal)
            // ======================
            _SectionTitle(
              title: 'Most Popular',
              trailing: _SectionAction(
                text: 'See All',
                onTap: () => Get.snackbar('Most Popular', 'See all'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: 6,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final list = _resolveItems(args, 'mostPopular');
                  if (list.isNotEmpty) {
                    final p = list[i % list.length];
                    return SizedBox(
                      width: 170,
                      child: ProductCard(
                        item: p,
                        onTap: (_) => Get.toNamed(AppRoutes.product, arguments: {'item': p}),
                      ),
                    );
                  }
                  return _MiniProductCard(
                    imageUrl: 'https://picsum.photos/200/200?mp=$i',
                    priceText: '\$17.80',
                    badgeText: i == 1 ? 'New' : (i == 3 ? 'Sale' : (i == 4 ? 'Hot' : null)),
                    onTap: () {},
                  );
                },
              ),
            ),

            const SizedBox(height: 18),

            // ======================
            // You Might Like (Grid)
            // ======================
            _SectionTitle(title: 'You Might Like'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (_, i) {
                final list = _resolveItems(args, 'recommended');
                if (list.isNotEmpty) {
                  final p = list[i % list.length];
                  return ProductCard(
                    item: p,
                    showAddToCart: true,
                    onTap: (_) => Get.toNamed(AppRoutes.product, arguments: {'item': p}),
                  );
                }
                return _GridProductCard(
                  imageUrl: 'https://picsum.photos/300/360?ym=$i',
                  title: 'Lorem ipsum dolor',
                  priceText: '\$17.00',
                  onTap: () {},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// =====================
// Small reusable parts
// =====================

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
            color: context.foreground,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _SectionAction extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _SectionAction({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: context.mutedForeground,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_forward_rounded,
                color: context.primaryForeground, size: 16),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String title;
  final List<String> chips;

  const _SpecRow({required this.title, required this.chips});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: context.foreground,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: chips
              .map(
                (t) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.background.withOpacity(context.isDark ? 0.18 : 0.75),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.border.withOpacity(0.35)),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      color: context.mutedForeground,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _LinkRow({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              color: context.foreground,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: context.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.arrow_forward_rounded,
                color: context.primaryForeground, size: 18),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  const _DeliveryOption({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? context.primary : context.border.withOpacity(0.55),
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? context.primary : context.border.withOpacity(0.8),
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: context.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(fontWeight: FontWeight.w900, color: context.foreground)),
            const SizedBox(width: 10),
            Text(subtitle, style: TextStyle(color: context.primary, fontWeight: FontWeight.w800, fontSize: 12)),
            const Spacer(),
            Text(price, style: TextStyle(fontWeight: FontWeight.w900, color: context.foreground)),
          ],
        ),
      ),
    );
  }
}

class _RatingPreview extends StatelessWidget {
  final String name;
  final double rating;
  final String text;

  const _RatingPreview({required this.name, required this.rating, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border.withOpacity(0.55)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: context.accent,
            child: Icon(Icons.person, color: context.accentForeground),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: TextStyle(fontWeight: FontWeight.w900, color: context.foreground)),
                    const Spacer(),
                    _Stars(rating: rating),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: context.background.withOpacity(context.isDark ? 0.18 : 0.75),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: context.border.withOpacity(0.35)),
                      ),
                      child: Text(
                        '${rating.toStringAsFixed(0)}/5',
                        style: TextStyle(fontWeight: FontWeight.w900, color: context.foreground, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(color: context.mutedForeground, height: 1.35, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final double rating;
  const _Stars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    return Row(
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

class _MiniProductCard extends StatelessWidget {
  final String imageUrl;
  final String priceText;
  final String? badgeText;
  final VoidCallback onTap;

  const _MiniProductCard({
    required this.imageUrl,
    required this.priceText,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.border.withOpacity(0.55)),
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(priceText, style: TextStyle(fontWeight: FontWeight.w900, color: context.foreground)),
                const Spacer(),
                if (badgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: context.background.withOpacity(context.isDark ? 0.18 : 0.75),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: context.border.withOpacity(0.35)),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: context.mutedForeground),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GridProductCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String priceText;
  final VoidCallback onTap;

  const _GridProductCard({
    required this.imageUrl,
    required this.title,
    required this.priceText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: context.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.border.withOpacity(0.55)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800, color: context.mutedForeground, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  Text(priceText, style: TextStyle(fontWeight: FontWeight.w900, color: context.foreground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onAdd;
  final VoidCallback onBuy;

  const _BottomBar({
    required this.isFavorite,
    required this.onFavorite,
    required this.onAdd,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: BoxDecoration(
          color: context.background,
          border: Border(top: BorderSide(color: context.border.withOpacity(0.35))),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: onFavorite,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.border.withOpacity(0.55)),
                ),
                child: Icon(
                  isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: isFavorite ? context.destructive : context.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                text: 'Add to cart',
                onPressed: onAdd,
                height: 44,
                backgroundColor: const Color(0xFF22252B),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                text: 'Buy now',
                onPressed: onBuy,
                height: 44,
              ),
            ),
          ],
        ),
      ),
    );
  }
}