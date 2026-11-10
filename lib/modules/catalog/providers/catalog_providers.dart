import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_filter_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_product_utils.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/cart_added_dialog.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/favorite_added_dialog.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/flash_sale_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_attribute_group.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/catalog/models/product_details_state.dart';
import 'package:rwnaqk_frontend/modules/catalog/models/products_listing_state.dart';
import 'package:rwnaqk_frontend/modules/catalog/widgets/app_filter_sheet.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_category_item.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:share_plus/share_plus.dart';

/// مزود خدمة منطق المنتجات النقي [ProductsListingService]
final productsListingServiceProvider = Provider<ProductsListingService>((ref) {
  return ProductsListingService();
});

/// مزود خدمة تفاصيل المنتج [ProductDetailsService]
final productDetailsServiceProvider = Provider<ProductDetailsService>((ref) {
  return ProductDetailsService();
});

/// موفر قائمة الفئات [categoriesProvider]
final categoriesProvider = FutureProvider<List<HomeCategoryItem>>((ref) async {
  final repo = ref.watch(productsRepositoryProvider);
  return repo.getCategories();
});

/// موفر حالة قائمة المنتجات والكتالوج [productsListingProvider]
final productsListingProvider =
    NotifierProvider<ProductsListingNotifier, ProductsListingState>(
  ProductsListingNotifier.new,
);

/// متحكم حالة قائمة المنتجات المعتمد على Riverpod 3
class ProductsListingNotifier extends Notifier<ProductsListingState> {
  IProductsRepository get _repo => ref.read(productsRepositoryProvider);
  ProductsListingService get _service => ref.read(productsListingServiceProvider);

  @override
  ProductsListingState build() {
    return ProductsListingState.initial();
  }

  /// تهيئة القائمة من المعاملات القادمة من المسار أو الشاشات السابقة
  void initFromArgs(dynamic args) {
    final map = args is Map ? args : const {};
    final t = map['title'];
    final s = map['source'];
    final raw = map['items'];

    final initialList = _service.resolveItems(raw);
    state = state.copyWith(
      title: t is String ? t : state.title,
      source: s is String ? s : state.source,
      initialItems: initialList,
      items: initialList,
      page: 1,
      hasMore: true,
      errorMessage: () => null,
    );

    if (initialList.isEmpty) {
      refreshList();
    } else {
      _applySortAndFilter();
    }
  }

  /// تحديث القائمة من البداية (Pull to refresh / Filter change)
  Future<void> refreshList() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: () => null,
      page: 1,
      hasMore: true,
    );

    try {
      final double? minPrice = state.filterResult?.priceRange.start;
      final double? maxPrice = state.filterResult?.priceRange.end;

      final base = state.initialItems.isNotEmpty
          ? state.initialItems.toList()
          : await _repo.getProducts(
              seed: 1,
              limit: 10,
              sort: state.sort,
              minPrice: minPrice,
              maxPrice: maxPrice,
            );

      final sorted = _service.applySort(list: base, sort: state.sort);
      final filtered = _service.applyFilters(
        list: sorted,
        filterResult: state.filterResult,
      );

      state = state.copyWith(
        initialItems: state.initialItems,
        items: filtered,
        isLoading: false,
        hasMore: base.length >= 10,
        page: 1,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Something went wrong',
      );
    }
  }

  /// تحميل المزيد من العناصر عند التمرير لنهاية القائمة مع منع التكرار
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.page + 1;
      final double? minPrice = state.filterResult?.priceRange.start;
      final double? maxPrice = state.filterResult?.priceRange.end;

      final more = await _repo.getProducts(
        seed: state.items.length + 1,
        limit: 10,
        sort: state.sort,
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      if (more.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMore: false,
        );
      } else {
        final merged = [...state.items, ...more];
        final sorted = _service.applySort(list: merged, sort: state.sort);
        final filtered = _service.applyFilters(
          list: sorted,
          filterResult: state.filterResult,
        );

        state = state.copyWith(
          items: filtered,
          isLoadingMore: false,
          page: nextPage,
          hasMore: more.length >= 10,
        );
      }
    } catch (_) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// تغيير ترتيب العناصر
  void setSort(ListingSort sort) {
    if (state.sort == sort) return;
    state = state.copyWith(sort: sort);
    _applySortAndFilter();
    if (state.initialItems.isEmpty) {
      refreshList();
    }
  }

  /// تطبيق فلاتر البحث والأسعار
  void setFilter(AppFilterResult? filter) {
    final count = filter != null ? AppFilterUtils.countActive(filter) : 0;
    state = state.copyWith(
      filterResult: () => filter,
      activeFilterCount: count,
    );
    _applySortAndFilter();
    if (state.initialItems.isEmpty) {
      refreshList();
    }
  }

  /// إعادة تعيين الفلاتر
  void clearFilters() {
    state = state.copyWith(
      filterResult: () => null,
      activeFilterCount: 0,
    );
    _applySortAndFilter();
    if (state.initialItems.isEmpty) {
      refreshList();
    }
  }

  void _applySortAndFilter() {
    final base = state.initialItems.isNotEmpty ? state.initialItems : state.items;
    final sorted = _service.applySort(list: base, sort: state.sort);
    final filtered = _service.applyFilters(
      list: sorted,
      filterResult: state.filterResult,
    );
    state = state.copyWith(items: filtered);
  }
}

/// موفر تفاصيل المنتج بالعائلة [productDetailsFamily]
final productDetailsFamily =
    NotifierProvider.family<ProductDetailsNotifier, ProductDetailsState, String>(
  (arg) => ProductDetailsNotifier(arg),
);

/// متحكم تفاصيل المنتج وخيارات المقاس والألوان والمراجعات
class ProductDetailsNotifier extends Notifier<ProductDetailsState> {
  ProductDetailsNotifier(this.arg);

  final String arg;

  IProductsRepository get _repo => ref.read(productsRepositoryProvider);
  ProductDetailsService get _service => ref.read(productDetailsServiceProvider);

  @override
  ProductDetailsState build() {
    // مراقبة حالة المفضلة لمزامنتها مباشرة مع المنتج الحالي
    final isFav = ref.watch(wishlistProvider).isInWishlist(arg);
    return ProductDetailsState.initial().copyWith(isFavorite: isFav);
  }

  /// تحميل المنتج من الكائن الأولي أو عبر المستودع
  Future<void> loadProduct({
    HomeProductItem? initialItem,
    dynamic args,
  }) async {
    final map = (args is Map) ? args : const {};

    final reviews = _service.resolveReviews(map['reviews']);
    final mostPopular = _service.resolveItems(map['mostPopular']);
    final recommended = _service.resolveItems(map['recommended']);

    if (initialItem != null) {
      _initFromProduct(
        item: initialItem,
        reviews: reviews,
        mostPopular: mostPopular,
        recommended: recommended,
        incomingColor: map['selectedColorId'] ?? map['selectedColor'],
        incomingSize: map['selectedSize'],
        rawGroups: map['attributeGroups'],
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: () => null);

    try {
      final product = await _repo.getProductById(arg);
      if (product == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => 'Product not found',
        );
        return;
      }

      final fetchedReviews = reviews.isNotEmpty
          ? reviews
          : await _repo.getProductReviews(arg);

      _initFromProduct(
        item: product,
        reviews: fetchedReviews,
        mostPopular: mostPopular,
        recommended: recommended,
        incomingColor: map['selectedColorId'] ?? map['selectedColor'],
        incomingSize: map['selectedSize'],
        rawGroups: map['attributeGroups'],
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to load product details',
      );
    }
  }

  void _initFromProduct({
    required HomeProductItem item,
    required List<ProductReview> reviews,
    required List<HomeProductItem> mostPopular,
    required List<HomeProductItem> recommended,
    dynamic incomingColor,
    dynamic incomingSize,
    dynamic rawGroups,
  }) {
    final availableColors = item.availableColors;
    final availableSizes = item.availableSizes;

    final resolvedColorId = _service.resolveSelectedColorId(
      incomingValue: incomingColor,
      availableValues: availableColors,
    );

    final resolvedSize = _service.resolveSelectedSize(
      incomingValue: incomingSize,
      availableValues: availableSizes,
    );

    final attrs = <String, String>{};
    final groups = <ProductAttributeGroup>[];

    if (rawGroups is List<ProductAttributeGroup> && rawGroups.isNotEmpty) {
      groups.addAll(rawGroups);
      for (final g in rawGroups) {
        if (g.options.isNotEmpty) {
          attrs[g.id] = g.options.first.id;
        }
      }
    } else {
      if (availableColors.isNotEmpty) {
        groups.add(
          ProductAttributeGroup(
            id: 'color',
            name: Tk.productDetailsColorLabel.tr,
            type: ProductAttributeType.color,
            options: availableColors.map((c) {
              return ProductAttributeOption(
                id: c.id,
                label: c.name.tr,
                imageUrl: c.imageUrl,
              );
            }).toList(),
          ),
        );
        attrs['color'] = resolvedColorId.isNotEmpty ? resolvedColorId : availableColors.first.id;
      }

      if (availableSizes.isNotEmpty) {
        groups.add(
          ProductAttributeGroup(
            id: 'size',
            name: Tk.productDetailsSizeLabel.tr,
            type: ProductAttributeType.text,
            options: availableSizes.map((s) {
              return ProductAttributeOption(
                id: s,
                label: s,
              );
            }).toList(),
          ),
        );
        attrs['size'] = resolvedSize.isNotEmpty ? resolvedSize : availableSizes.first;
      }
    }

    final isFav = ref.read(wishlistProvider).isInWishlist(item.id);

    state = state.copyWith(
      product: () => item,
      isLoading: false,
      selectedColorId: resolvedColorId,
      selectedSize: resolvedSize,
      selectedAttributes: attrs,
      attributeGroups: groups,
      reviews: reviews,
      mostPopular: mostPopular,
      recommended: recommended,
      isFavorite: isFav,
      quantity: 1,
    );
  }

  /// اختيار سمة أو متغير من خيارات المنتج
  void selectAttribute(String groupId, String optionId) {
    final nextAttrs = Map<String, String>.from(state.selectedAttributes);
    nextAttrs[groupId] = optionId;

    String nextColor = state.selectedColorId;
    String nextSize = state.selectedSize;
    int nextThumb = state.selectedThumb;

    if (groupId == 'color') {
      nextColor = optionId;
    } else if (groupId == 'size') {
      nextSize = optionId;
    } else if (groupId == 'style') {
      final index = int.tryParse(optionId.replaceAll('style_', ''));
      if (index != null && index >= 0 && index < state.variationImages.length) {
        nextThumb = index;
      }
    }

    state = state.copyWith(
      selectedAttributes: nextAttrs,
      selectedColorId: nextColor,
      selectedSize: nextSize,
      selectedThumb: nextThumb,
    );
  }

  void selectThumb(int index) {
    if (index >= 0 && index < state.variationImages.length) {
      state = state.copyWith(selectedThumb: index);
    }
  }

  void setSelectedColor(String colorId) => selectAttribute('color', colorId);
  void setSelectedSize(String size) => selectAttribute('size', size);

  void setDelivery(String id) {
    state = state.copyWith(deliverySelected: id);
  }

  void incrementQuantity() {
    state = state.copyWith(quantity: state.quantity + 1);
  }

  void decrementQuantity() {
    if (state.quantity > 1) {
      state = state.copyWith(quantity: state.quantity - 1);
    }
  }

  /// التبديل المباشر لحالة المفضلة عبر [wishlistProvider]
  void toggleFavorite([BuildContext? context]) {
    final current = state.product;
    if (current == null) return;

    final wasFavorite = state.isFavorite;
    ref.read(wishlistProvider.notifier).toggleWishlist(current);

    final nowFavorite = ref.read(wishlistProvider).isInWishlist(current.id);
    state = state.copyWith(isFavorite: nowFavorite);

    if (!wasFavorite && nowFavorite && context != null) {
      FavoriteAddedDialog.show(context);
    }
  }

  /// إضافة المنتج الحالي للسلة مع كامل خيارات المتغيرات والكمية
  /// يعيد true إذا نجحت الإضافة، أو false إذا تعذرت أو كان CartController غير مسجل
  bool addToCart([BuildContext? context]) {
    final current = state.product;
    if (current == null) {
      AppToast.error(Tk.commonError.tr);
      return false;
    }

    try {
      final variantText = AppProductUtils.joinInline(state.selectedOptionChips);
      final stableKey = state.stableVariantKey;

      ref.read(cartProvider.notifier).addToCart(
        current,
        quantity: state.quantity,
        variantText: variantText.trim().isEmpty ? null : variantText,
        stableVariantId: stableKey.trim().isEmpty ? null : stableKey,
        rating: state.hasReviews ? state.averageRating : null,
        reviewsCount: state.hasReviews ? state.reviewsCount : null,
      );

      final ctx = context ?? AppNav.currentContext;
      if (ctx != null) {
        CartAddedDialog.show(ctx);
      }
      return true;
    } catch (e) {
      AppToast.error(e.toString());
      return false;
    }
  }

  /// الشراء الفوري والانتقال للدفع
  void buyNow() {
    final current = state.product;
    if (current == null) return;

    final variantText = AppProductUtils.joinInline(state.selectedOptionChips);
    final stableKey = state.stableVariantKey;
    ref.read(cartProvider.notifier).addToCart(
      current,
      quantity: state.quantity,
      variantText: variantText.trim().isEmpty ? null : variantText,
      stableVariantId: stableKey.trim().isEmpty ? null : stableKey,
      rating: state.hasReviews ? state.averageRating : null,
      reviewsCount: state.hasReviews ? state.reviewsCount : null,
    );
    AppNav.toNamed(AppRoutes.payment);
  }

  /// إضافة مراجعة جديدة
  void addReview({
    required double rating,
    required String comment,
    String? name,
  }) {
    final newReview = ProductReview(
      name: (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : Tk.reviewsAuthorGuest.tr,
      rating: rating,
      text: comment.trim(),
      dateText: Tk.reviewsJustNow.tr,
    );
    state = state.copyWith(
      reviews: [newReview, ...state.reviews],
    );
    AppToast.success(Tk.reviewsSuccessMessage.tr);
  }

  /// مشاركة تفاصيل المنتج
  Future<void> shareProduct() async {
    final current = state.product;
    if (current == null) return;

    final shareText = [
      state.title,
      if (state.description.trim().isNotEmpty) state.description,
      '',
      Tk.productDetailsShareHint.tr,
      state.title,
    ].join('\n');

    try {
      await SharePlus.instance.share(ShareParams(text: shareText));
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: shareText));
      AppToast.copied(message: Tk.commonCopied.tr, title: Tk.commonDone.tr);
    }
  }
}

class FlashSaleState {
  final int hh;
  final int mm;
  final int ss;
  final int selectedDiscount;
  final List<int> discounts;
  final List<HomeProductItem> products;

  const FlashSaleState({
    this.hh = 0,
    this.mm = 36,
    this.ss = 58,
    this.selectedDiscount = 0,
    this.discounts = const [0, 10, 20, 30, 40, 50],
    this.products = const [],
  });

  FlashSaleState copyWith({
    int? hh,
    int? mm,
    int? ss,
    int? selectedDiscount,
    List<int>? discounts,
    List<HomeProductItem>? products,
  }) {
    return FlashSaleState(
      hh: hh ?? this.hh,
      mm: mm ?? this.mm,
      ss: ss ?? this.ss,
      selectedDiscount: selectedDiscount ?? this.selectedDiscount,
      discounts: discounts ?? this.discounts,
      products: products ?? this.products,
    );
  }
}

final flashSaleProvider =
    NotifierProvider<FlashSaleNotifier, FlashSaleState>(FlashSaleNotifier.new);

class FlashSaleNotifier extends Notifier<FlashSaleState> {
  Timer? _timer;
  final FlashSaleService _service = FlashSaleService();

  @override
  FlashSaleState build() {
    ref.onDispose(() {
      _timer?.cancel();
    });

    _startTimer();
    final initialProducts = _service.loadFlashSaleProducts(selectedDiscount: 0);
    return FlashSaleState(products: initialProducts);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      int total = (state.hh * 3600) + (state.mm * 60) + state.ss;
      if (total <= 0) {
        _timer?.cancel();
        return;
      }
      total -= 1;
      state = state.copyWith(
        hh: total ~/ 3600,
        mm: (total % 3600) ~/ 60,
        ss: total % 60,
      );
    });
  }

  void selectDiscount(int discount) {
    final prods = _service.loadFlashSaleProducts(selectedDiscount: discount);
    state = state.copyWith(
      selectedDiscount: discount,
      products: prods,
    );
  }

  void openProduct(HomeProductItem item) {
    AppNav.toNamed(
      AppRoutes.product,
      arguments: {
        'item': item,
        'selectedColorId': item.availableColors.isNotEmpty ? item.availableColors.first.id : null,
        'selectedSize': item.availableSizes.isNotEmpty ? item.availableSizes.first : null,
      },
    );
  }
}
