import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/product_details/product_details_controller.dart';
import 'package:rwnaqk/core/constants/app_colors.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_checkout_utils.dart';
import 'package:rwnaqk/widgets/app_button.dart';
import 'package:rwnaqk/widgets/card/product_grid_section.dart';
import 'package:rwnaqk/widgets/cart/shipping_method_selector.dart';
import 'package:rwnaqk/widgets/product_details/product_details_header_card.dart';
import 'package:rwnaqk/widgets/product_details/product_reviews_section.dart';

const double _sectionGap = 18;
const double _innerGap = 12;
const double _gridSpacing = 12;

class ProductDetailsScreen extends GetView<ProductDetailsController> {
  const ProductDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final justCols = width >= 1100
        ? 4
        : width >= 780
            ? 3
            : 2;

    return Obx(() {
      return Scaffold(
        backgroundColor: context.background,
        bottomNavigationBar: _BottomBar(
          isFavorite: controller.isFavorite.value,
          onFavorite: controller.toggleFavorite,
          onAdd: controller.addToCart,
          onBuy: controller.buyNow,
        ),
        body: SafeArea(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            children: [
              ProductDetailsHeaderCard(
                images: controller.images,
                title: controller.title,
                description: controller.description,
                priceText:
                    '\$${controller.salePriceText.replaceAll('.00', '')}',
                oldPriceText: controller.hasDiscount
                    ? '\$${controller.oldPriceText}'
                    : null,
                discountText:
                    controller.hasDiscount ? '-${controller.discount}%' : null,
                timerWidget: null,
                rating: controller.hasReviews ? controller.averageRating : null,
                reviewsCount:
                    controller.hasReviews ? controller.reviewsCount : null,
                infoText: controller.stockText,
                isFavorite: controller.isFavorite.value,
                onFavorite: controller.toggleFavorite,
                availableColors: controller.availableColors,
                selectedColorId: controller.selectedColorId.value,
                onSelectColor: controller.setSelectedColor,
                availableSizes: controller.availableSizes,
                selectedSize: controller.selectedSize.value,
                onSelectSize: controller.setSelectedSize,
                variationsTitle: Tk.productDetailsVariations.tr,
                selectedChips: controller.selectedOptionChips,
                variationImages: controller.variationImages,
                selectedVariationImageIndex: controller.selectedThumb.value,
                onSelectVariationImage: controller.selectThumb,
                onShare: controller.shareProduct,
                showArrowButton: false,
                onArrowTap: null,
              ),
              const SizedBox(height: _sectionGap),
              _SectionTitle(title: Tk.productDetailsSpecifications.tr),
              const SizedBox(height: 10),
              _SpecRow(
                title: Tk.productDetailsMaterial.tr,
                chips: const ['Cotton 95%', 'Nylon 5%'],
              ),
              const SizedBox(height: 10),
              _SpecRow(
                title: Tk.productDetailsOrigin.tr,
                chips: const ['EU'],
              ),
              const SizedBox(height: 10),
              _LinkRow(
                text: Tk.productDetailsSizeGuide.tr,
                onTap: () => Get.snackbar(
                  Tk.productDetailsSizeGuide.tr,
                  Tk.productDetailsSizeGuideOpened.tr,
                ),
              ),
              const SizedBox(height: _sectionGap),
              ShippingMethodSelector(
                headerTitle: Tk.productDetailsDelivery.tr,
                options: AppCheckoutUtils.productDeliveryOptions(),
                selectedId: controller.deliverySelected.value,
                onChanged: controller.setDelivery,
              ),
              const SizedBox(height: _sectionGap),
              ProductReviewsSection(
                reviews: controller.reviews.toList(),
                onViewAll: () => Get.toNamed(
                  AppRoutes.reviews,
                  arguments: {
                    'reviews': controller.reviews.toList(),
                  },
                ),
              ),
              const SizedBox(height: _innerGap),
              Text(
                Tk.homeJustForYou.tr,
                style: TextStyle(
                  color: context.foreground,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: _innerGap),
              Obx(() {
                final items = controller.recommended.toList();
                if (items.isEmpty) {
                  return const SizedBox.shrink();
                }

                return ProductGridSection(
                  items: items,
                  crossAxisCount: justCols,
                  crossAxisSpacing: _gridSpacing,
                  mainAxisSpacing: _gridSpacing,
                  onTap: (p) => Get.toNamed(
                    AppRoutes.product,
                    arguments: {
                      'item': p,
                      'mostPopular': controller.mostPopular.toList(),
                      'recommended': controller.recommended.toList(),
                      'reviews': controller.reviews.toList(),
                    },
                  ),
                  childAspectRatio: 1.0,
                );
              }),
              const SizedBox(height: _sectionGap),
            ],
          ),
        ),
      );
    });
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionTitle({
    required this.title,
    this.trailing,
  });

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

class _SpecRow extends StatelessWidget {
  final String title;
  final List<String> chips;

  const _SpecRow({
    required this.title,
    required this.chips,
  });

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: context.background.withOpacity(
                      context.isDark ? 0.18 : 0.75,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.border.withOpacity(0.35),
                    ),
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

  const _LinkRow({
    required this.text,
    required this.onTap,
  });

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
            child: Icon(
              Icons.arrow_forward_rounded,
              color: context.primaryForeground,
              size: 18,
            ),
          ),
        ],
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
          border: Border(
            top: BorderSide(
              color: context.border.withOpacity(0.35),
            ),
          ),
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
                  border: Border.all(
                    color: context.border.withOpacity(0.55),
                  ),
                ),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite
                      ? context.destructive
                      : context.mutedForeground,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                text: Tk.productDetailsAddToCart.tr,
                onPressed: onAdd,
                height: 44,
                backgroundColor: const Color(0xFF22252B),
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: AppButton(
                text: Tk.productDetailsBuyNow.tr,
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
