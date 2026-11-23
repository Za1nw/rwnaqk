import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/constants/app_colors.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_money_utils.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/providers/catalog_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_header_card.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_details_skeleton.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_reviews_section.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_size_guide_sheet.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/product_specifications_card.dart';
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
  HomeProductItem? _initialItem;

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
        } else if (args['item'] is Map) {
          try {
            item = HomeProductItem.fromJson(
              Map<String, dynamic>.from(args['item'] as Map),
            );
            _productId = item.id;
          } catch (_) {
            _productId = args['id']?.toString() ?? '1';
          }
        } else if (args.containsKey('title') || args.containsKey('name')) {
          try {
            item = HomeProductItem.fromJson(Map<String, dynamic>.from(args));
            _productId = item.id;
          } catch (_) {
            _productId = args['id']?.toString() ?? '1';
          }
        } else {
          _productId =
              args['id']?.toString() ?? args['productId']?.toString() ?? '1';
        }
      } else if (args is String) {
        _productId = args;
      } else {
        _productId = '1';
      }
      _initialItem = item;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(productDetailsFamily(_productId).notifier)
            .loadProduct(initialItem: item, args: args);
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

    final hasVars = state.product != null
        ? state.hasVariations
        : (_initialItem?.hasVariation ?? false);

    final hasGuide = state.product != null
        ? state.hasSizeGuide
        : (_initialItem?.hasSizeGuide ?? false);

    return Scaffold(
      backgroundColor: context.background,
      appBar: _ProductDetailsAppBar(
        title: state.brand.isNotEmpty ? state.brand : state.title,
        isFavorite: state.isFavorite,
        onFavorite: () => notifier.toggleFavorite(context),
        onShare: notifier.shareProduct,
      ),
      bottomNavigationBar: state.isLoading || state.product == null
          ? (state.isLoading
              ? const ProductDetailsBottomBarSkeleton()
              : const SizedBox.shrink())
          : _BottomBar(
              isFavorite: state.isFavorite,
              onFavorite: () => notifier.toggleFavorite(context),
              onAdd: () => notifier.addToCart(context),
              onBuy: () => notifier.buyNow(context),
            ),
      body: SafeArea(
        top: false,
        child: state.isLoading
            ? ProductDetailsSkeleton(
                crossAxisCount: justCols,
                hasVariations: hasVars,
                hasSizeGuide: hasGuide,
              )
            : state.product == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: context.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            state.errorMessage ?? 'المنتج غير متاح حالياً أو تعذر الاتصال بالخادم',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              notifier.loadProduct(initialItem: _initialItem);
                            },
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 18),
                children: [
            // 1. Header Card (معرض الصور، البيانات الأساسية، والخصائص والكمية المباشرة)
            ProductDetailsHeaderCard(
              images: state.images,
              title: state.title,
              shortDescription: state.shortDescription,
              description: state.description,
              brand: state.brand,
              priceText: AppMoneyUtils.riyal(state.unitPrice),
              oldPriceText: state.hasDiscount
                  ? AppMoneyUtils.riyal(state.price)
                  : null,
              discountText: state.hasDiscount ? '-${state.discount}%' : null,
              timerWidget: null,
              rating: state.hasReviews ? state.averageRating : null,
              reviewsCount: state.hasReviews ? state.reviewsCount : null,
              infoText: state.stockText,
              isFavorite: state.isFavorite,
              onFavorite: () => notifier.toggleFavorite(context),
              hasVariations: state.hasVariations,
              selectedChips: state.selectedOptionChips,
              attributeGroups: state.attributeGroups,
              selectedAttributes: state.selectedAttributes,
              onSelectAttribute: notifier.selectAttribute,
              hasSizeGuide: state.hasSizeGuide,
              onSizeGuideTap: state.hasSizeGuide
                  ? () => ProductSizeGuideSheet.show(
                      context,
                      sizeGuide: state.sizeGuide,
                      currentSelectedSize: state.selectedSize,
                    )
                  : null,
              quantity: state.quantity,
              onIncrementQuantity: notifier.incrementQuantity,
              onDecrementQuantity: notifier.decrementQuantity,
              totalPriceText: AppMoneyUtils.riyal(state.totalPrice),
              onOpenVariantsSheet: () =>
                  ProductVariantsSheet.show(context, productId: _productId),
              onShare: notifier.shareProduct,
            ),

            const SizedBox(height: _sectionGap),

            // 2. Specifications Card (المواصفات - محتوى الوصف والخصائص التفصيلية)
            ProductSpecificationsCard(
              description: state.description,
            ),
            const SizedBox(height: _sectionGap),

            // 4. Product Reviews (With in-app review submission)
            ProductReviewsSection(
              reviews: state.reviews,
              onAddReview: (rating, comment, name) {
                notifier.addReview(
                  rating: rating,
                  comment: comment,
                  name: name,
                );
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
              color: isFavorite ? context.destructive : context.mutedForeground,
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
              color: context.shadow.withValues(
                alpha: context.isDark ? 0.25 : 0.06,
              ),
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
                  color: isFavorite ? context.destructive : context.foreground,
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
                  side: BorderSide(color: context.primary, width: 1.5),
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
