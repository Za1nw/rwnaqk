import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_header_card.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_reviews_section.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_size_guide_sheet.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_specifications_card.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_trust_badges.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_variants_sheet.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_grid_section.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

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
        appBar: _ProductDetailsAppBar(
          title: controller.brand.isNotEmpty
              ? controller.brand
              : controller.title,
          isFavorite: controller.isFavorite.value,
          onFavorite: controller.toggleFavorite,
          onShare: controller.shareProduct,
        ),
        bottomNavigationBar: _BottomBar(
          isFavorite: controller.isFavorite.value,
          onFavorite: controller.toggleFavorite,
          onAdd: controller.addToCart,
          onBuy: controller.buyNow,
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
            children: [
              // 1. Header Card (Gallery, Info, and Variant Selector Tile)
              ProductDetailsHeaderCard(
                images: controller.images,
                title: controller.title,
                description: controller.description,
                brand: controller.brand,
                priceText:
                    '\$${controller.salePriceText.replaceAll('.00', '')}',
                oldPriceText: controller.hasDiscount
                    ? '\$${controller.oldPriceText}'
                    : null,
                discountText: controller.hasDiscount
                    ? '-${controller.discount}%'
                    : null,
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
                showArrowButton: true,
                onArrowTap: () => ProductVariantsSheet.show(context),
                onOpenVariantsSheet: () => ProductVariantsSheet.show(context),
                onSizeGuideTap: () => ProductSizeGuideSheet.show(
                  context,
                  currentSelectedSize: controller.selectedSize.value,
                  onSizeSelected: controller.setSelectedSize,
                ),
              ),

              const SizedBox(height: _sectionGap),

              // 2. E-Commerce Trust Badges (Authentic, Fast Delivery, 14-day returns, Secure Payment)
              const ProductTrustBadges(),

              const SizedBox(height: _sectionGap),

              // 3. Specifications Card (Material, Origin, SKU, Care Instructions, and Size Guide link)
              ProductSpecificationsCard(
                sku: controller.sku,
                selectedSize: controller.selectedSize.value,
                onSelectSize: controller.setSelectedSize,
              ),

              const SizedBox(height: _sectionGap),

              // 4. Product Reviews (With in-app review submission)
              ProductReviewsSection(
                reviews: controller.reviews.toList(),
                onViewAll: () => Get.toNamed(
                  AppRoutes.reviews,
                  arguments: {'reviews': controller.reviews.toList()},
                ),
              ),

              const SizedBox(height: _sectionGap),

              // 6. Recommended Products (Just for you)
              Row(
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
                    Tk.homeJustForYou.tr,
                    style: TextStyle(
                      color: context.foreground,
                      fontWeight: FontWeight.w900,
                      fontSize: 16.5,
                    ),
                  ),
                ],
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

class _ProductDetailsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onShare;

  const _ProductDetailsAppBar({
    required this.title,
    required this.isFavorite,
    required this.onFavorite,
    required this.onShare,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: context.background,
      elevation: 0,
      scrolledUnderElevation: 1.5,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.border.withValues(alpha: 0.45)),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: context.foreground,
          ),
        ),
        onPressed: () => Navigator.maybePop(context),
      ),
      centerTitle: true,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: context.foreground,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            onShare();
          },
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.border.withValues(alpha: 0.45)),
            ),
            child: Icon(
              Icons.share_rounded,
              size: 18,
              color: context.foreground,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            HapticFeedback.selectionClick();
            onFavorite();
          },
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.border.withValues(alpha: 0.45)),
            ),
            child: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 18,
              color: isFavorite
                  ? context.destructive
                  : context.mutedForeground,
            ),
          ),
        ),
        Obx(() {
          int count = 0;
          if (Get.isRegistered<CartController>()) {
            count = Get.find<CartController>().itemsCount;
          }

          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => Get.toNamed(AppRoutes.cart),
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.card,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: context.border.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 18,
                    color: context.foreground,
                  ),
                ),
              ),
              if (count > 0)
                PositionedDirectional(
                  top: 5,
                  end: 5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    child: Center(
                      child: Text(
                        '$count',
                        style: TextStyle(
                          color: context.primaryForeground,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
        const SizedBox(width: 4),
      ],
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
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: context.background,
          border: Border(
            top: BorderSide(color: context.border.withValues(alpha: 0.40)),
          ),
          boxShadow: [
            BoxShadow(
              color: context.shadow
                  .withValues(alpha: context.isDark ? 0.25 : 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Wishlist Favorite Button
            InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                onFavorite();
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isFavorite
                      ? context.destructive.withValues(alpha: 0.08)
                      : context.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFavorite
                        ? context.destructive.withValues(alpha: 0.3)
                        : context.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color:
                      isFavorite ? context.destructive : context.foreground,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Add to Cart Button (Flexible, secondary outlined style)
            Expanded(
              flex: 5,
              child: OutlinedButton.icon(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  onAdd();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  side: BorderSide(
                    color: context.primary,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  backgroundColor: context.primary.withValues(alpha: 0.06),
                ),
                icon: Icon(
                  Icons.add_shopping_cart_rounded,
                  size: 19,
                  color: context.primary,
                ),
                label: Text(
                  Tk.productDetailsAddToCart.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Buy Now Button (Flexible, primary solid style)
            Expanded(
              flex: 5,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticFeedback.heavyImpact();
                  onBuy();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  backgroundColor: context.primary,
                  foregroundColor: context.primaryForeground,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.flash_on_rounded, size: 19),
                label: Text(
                  Tk.productDetailsBuyNow.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
