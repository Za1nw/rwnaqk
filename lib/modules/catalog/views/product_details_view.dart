import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_header_card.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_reviews_section.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_size_guide_sheet.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_specifications_card.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_trust_badges.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_variants_sheet.dart';
import 'package:rwnaqk_frontend/modules/checkout/widgets/product_grid_section.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';

const double _sectionGap = 18;
const double _innerGap = 12;
const double _gridSpacing = 12;

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  bool _initialized = false;
  late String _productId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final args = ModalRoute.of(context)?.settings.arguments;
      HomeProductItem? item;
      if (args is HomeProductItem) {
        item = args;
        _productId = args.id;
      } else if (args is Map) {
        if (args['item'] is HomeProductItem) {
          item = args['item'] as HomeProductItem;
          _productId = item.id;
        } else {
          _productId = args['id']?.toString() ??
              args['productId']?.toString() ??
              '1';
        }
      } else if (args is String) {
        _productId = args;
      } else {
        _productId = '1';
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(productDetailsFamily(_productId).notifier).loadProduct(
              initialItem: item,
              args: args,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailsFamily(_productId));
    final notifier = ref.read(productDetailsFamily(_productId).notifier);
    final width = MediaQuery.of(context).size.width;

    final justCols = width >= 1100
        ? 4
        : width >= 780
            ? 3
            : 2;

    return Scaffold(
      backgroundColor: context.background,
      appBar: _ProductDetailsAppBar(
        title: state.brand.isNotEmpty ? state.brand : state.title,
        isFavorite: state.isFavorite,
        onFavorite: () => notifier.toggleFavorite(context),
        onShare: notifier.shareProduct,
      ),
      bottomNavigationBar: _BottomBar(
        isFavorite: state.isFavorite,
        onFavorite: () => notifier.toggleFavorite(context),
        onAdd: () => notifier.addToCart(context),
        onBuy: notifier.buyNow,
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
          children: [
            // 1. Header Card (Gallery, Info, and Variant Selector Tile)
            ProductDetailsHeaderCard(
              images: state.images,
              title: state.title,
              description: state.description,
              brand: state.brand,
              priceText: '\$${state.salePriceText.replaceAll('.00', '')}',
              oldPriceText:
                  state.hasDiscount ? '\$${state.oldPriceText}' : null,
              discountText:
                  state.hasDiscount ? '-${state.discount}%' : null,
              timerWidget: null,
              rating: state.hasReviews ? state.averageRating : null,
              reviewsCount: state.hasReviews ? state.reviewsCount : null,
              infoText: state.stockText,
              isFavorite: state.isFavorite,
              onFavorite: () => notifier.toggleFavorite(context),
              availableColors: state.availableColors,
              selectedColorId: state.selectedColorId,
              onSelectColor: notifier.setSelectedColor,
              availableSizes: state.availableSizes,
              selectedSize: state.selectedSize,
              onSelectSize: notifier.setSelectedSize,
              variationsTitle: Tk.productDetailsVariations.tr,
              selectedChips: state.selectedOptionChips,
              variationImages: state.variationImages,
              selectedVariationImageIndex: state.selectedThumb,
              onSelectVariationImage: notifier.selectThumb,
              onShare: notifier.shareProduct,
              showArrowButton: true,
              onArrowTap: () =>
                  ProductVariantsSheet.show(context, productId: _productId),
              onOpenVariantsSheet: () =>
                  ProductVariantsSheet.show(context, productId: _productId),
              onSizeGuideTap: () => ProductSizeGuideSheet.show(
                context,
                currentSelectedSize: state.selectedSize,
                onSizeSelected: notifier.setSelectedSize,
              ),
            ),

            const SizedBox(height: _sectionGap),

            // 2. E-Commerce Trust Badges (Authentic, Fast Delivery, 14-day returns, Secure Payment)
            const ProductTrustBadges(),

            const SizedBox(height: _sectionGap),

            // 3. Specifications Card (Material, Origin, SKU, Care Instructions, and Size Guide link)
            ProductSpecificationsCard(
              sku: state.sku,
              selectedSize: state.selectedSize,
              onSelectSize: notifier.setSelectedSize,
            ),

            const SizedBox(height: _sectionGap),

            // 4. Product Reviews (With in-app review submission)
            ProductReviewsSection(
              reviews: state.reviews,
              onAddReview: (rating, comment, name) {
                notifier.addReview(rating: rating, comment: comment, name: name);
              },
              onViewAll: () => AppNav.toNamed(
                AppRoutes.reviews,
                arguments: {'reviews': state.reviews},
              ),
            ),

            const SizedBox(height: _sectionGap),

            // 5. Recommended Products (Just for you)
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
            if (state.recommended.isNotEmpty)
              ProductGridSection(
                items: state.recommended,
                crossAxisCount: justCols,
                crossAxisSpacing: _gridSpacing,
                mainAxisSpacing: _gridSpacing,
                onTap: (p) => AppNav.toNamed(
                  AppRoutes.product,
                  arguments: {
                    'item': p,
                    'mostPopular': state.mostPopular,
                    'recommended': state.recommended,
                    'reviews': state.reviews,
                  },
                ),
                childAspectRatio: 1.0,
              ),
            const SizedBox(height: _sectionGap),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailsAppBar extends ConsumerWidget
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
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartProvider.select((s) => s.itemsCount));

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
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => AppNav.toNamed(AppRoutes.cart),
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
        ),
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
