import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk/controllers/cart/cart_controller.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/core/translations/app_locale_keys.dart';
import 'package:rwnaqk/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk/core/utils/app_product_utils.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/product_color_option.dart';
import 'package:rwnaqk/models/product_review.dart';
import 'package:share_plus/share_plus.dart';

import 'product_details_service.dart';
import 'product_details_ui_controller.dart';

class ProductDetailsController extends GetxController {
  ProductDetailsController(this._service);

  final ProductDetailsService _service;

  late final ProductDetailsUiController ui;

  // =========================================================
  // Product
  // =========================================================
  final Rxn<HomeProductItem> item = Rxn<HomeProductItem>();

  // =========================================================
  // State
  // =========================================================
  final RxBool isLoading = false.obs;

  // =========================================================
  // Related content
  // =========================================================
  final RxList<ProductReview> reviews = <ProductReview>[].obs;
  final RxList<HomeProductItem> mostPopular = <HomeProductItem>[].obs;
  final RxList<HomeProductItem> recommended = <HomeProductItem>[].obs;

  // =========================================================
  // UI bridges (حتى لا تتكسر الشاشة الحالية)
  // =========================================================
  RxInt get selectedThumb => ui.selectedThumb;
  RxBool get isFavorite => ui.isFavorite;
  RxString get deliverySelected => ui.deliverySelected;
  RxString get selectedColorId => ui.selectedColorId;
  RxString get selectedSize => ui.selectedSize;

  // =========================================================
  // Base getters
  // =========================================================
  HomeProductItem? get product => item.value;

  String get title {
    final value = product?.title.trim() ?? '';
    return value.isEmpty ? Mk.productDefaultTitle.tr : value.tr;
  }

  String get description {
    final value = product?.description.trim() ?? '';
    return value.isEmpty ? Mk.productDefaultDescription.tr : value.tr;
  }

  String get imageUrl => product?.imageUrl ?? '';

  double get price => product?.price ?? 0;

  int get discount => product?.discountPercent ?? 0;

  bool get hasDiscount => discount > 0;

  String get salePriceText {
    if (!hasDiscount) return price.toStringAsFixed(2);
    final sale = price * (1 - discount / 100);
    return sale.toStringAsFixed(2);
  }

  String get oldPriceText => price.toStringAsFixed(2);

  String get brand {
    final value = product?.brand.trim() ?? '';
    return value.isEmpty ? Mk.productBrand.tr : value.tr;
  }

  String get sku {
    final value = product?.sku.trim() ?? '';
    return value.isEmpty ? 'SKU-${product?.id ?? '000'}' : value;
  }

  String get stockText {
    final value = product?.stockText.trim() ?? '';
    return value.isEmpty ? Mk.productInStock.tr : value.tr;
  }

  String get soldText {
    final value = product?.soldText.trim() ?? '';
    return value.isEmpty ? AppMockContentUtils.soldCountText(120) : value.tr;
  }

  // =========================================================
  // Safe list getters
  // =========================================================
  List<String> get images {
    final rawImages = product?.images;
    if (rawImages != null && rawImages.isNotEmpty) {
      return rawImages.where((e) => e.trim().isNotEmpty).toList();
    }

    final fallback = <String>[
      if (imageUrl.trim().isNotEmpty) imageUrl,
      'https://picsum.photos/500/650?pd_a',
      'https://picsum.photos/500/650?pd_b',
      'https://picsum.photos/500/650?pd_c',
    ];

    return fallback.where((e) => e.trim().isNotEmpty).toList();
  }

  List<String> get variationImages {
    final imgs = images;
    if (imgs.isEmpty) return <String>[];
    return imgs.take(4).toList();
  }

  List<ProductColorOption> get availableColors {
    final raw = product?.availableColors;
    if (raw == null || raw.isEmpty) return <ProductColorOption>[];

    return raw
        .where(
          (e) =>
              e.id.trim().isNotEmpty &&
              e.name.trim().isNotEmpty &&
              e.imageUrl.trim().isNotEmpty,
        )
        .toList();
  }

  List<String> get availableSizes {
    final raw = product?.availableSizes;
    if (raw == null || raw.isEmpty) return <String>[];
    return raw.where((e) => e.trim().isNotEmpty).toList();
  }

  ProductColorOption? get selectedColorOption {
    if (selectedColorId.value.trim().isEmpty) return null;

    for (final color in availableColors) {
      if (color.id == selectedColorId.value) return color;
    }
    return null;
  }

  List<String> get selectedOptionChips {
    final chips = <String>[];

    final colorName = selectedColorOption?.name.trim() ?? '';
    if (colorName.isNotEmpty) {
      chips.add(colorName.tr);
    }

    if (selectedSize.value.trim().isNotEmpty) {
      chips.add(selectedSize.value.trim());
    }

    return chips;
  }

  int get photosCount => images.length;

  // =========================================================
  // Product limits and size guide
  // =========================================================
  ProductPurchaseLimit? get purchaseLimit => product?.purchaseLimit;

  bool get hasPurchaseLimit {
    final limit = purchaseLimit;
    if (limit == null) return false;
    return limit.minQty != null || limit.maxQty != null;
  }

  List<ProductSizeGuideRow> get sizeGuide {
    final raw = product?.sizeGuide ?? const <ProductSizeGuideRow>[];
    return raw
        .where(
          (row) =>
              row.size.trim().isNotEmpty &&
              row.chest.trim().isNotEmpty &&
              row.waist.trim().isNotEmpty &&
              row.hips.trim().isNotEmpty &&
              row.length.trim().isNotEmpty,
        )
        .toList();
  }

  bool get hasSizeGuide => sizeGuide.isNotEmpty;

  List<String> get sizeGuideLabels {
    final seen = <String>{};
    final labels = <String>[];

    for (final row in sizeGuide) {
      final label = row.size.trim().toUpperCase();
      if (label.isEmpty || seen.contains(label)) continue;
      seen.add(label);
      labels.add(label);
    }

    return labels;
  }

  ProductSizeGuideRow? get selectedSizeGuideRow {
    final rows = sizeGuide;
    if (rows.isEmpty) return null;

    final selected = selectedSize.value.trim().toUpperCase();
    if (selected.isEmpty) return rows.first;

    for (final row in rows) {
      if (row.size.trim().toUpperCase() == selected) return row;
    }

    return rows.first;
  }

  // =========================================================
  // Reviews helpers
  // =========================================================
  bool get hasReviews => reviews.isNotEmpty;

  int get reviewsCount => reviews.length;

  double get averageRating {
    if (reviews.isEmpty) return 0;
    final total = reviews.fold<double>(0, (sum, r) => sum + r.rating);
    return total / reviews.length;
  }

  // =========================================================
  // Lifecycle
  // =========================================================
  @override
  void onInit() {
    super.onInit();
    ui = Get.find<ProductDetailsUiController>();
    _loadFromArgs(Get.arguments);
  }

  // =========================================================
  // Load data
  // =========================================================
  void _loadFromArgs(dynamic args) {
    final map = (args is Map) ? args : const {};

    final argItem = map['item'];
    if (argItem is HomeProductItem) {
      item.value = argItem;
    }

    reviews.assignAll(_service.resolveReviews(map['reviews']));
    mostPopular.assignAll(_service.resolveItems(map['mostPopular']));
    recommended.assignAll(_service.resolveItems(map['recommended']));

    final resolvedColorId = _service.resolveSelectedColorId(
      incomingValue: map['selectedColorId'] ?? map['selectedColor'],
      availableValues: availableColors,
    );

    final resolvedSize = _service.resolveSelectedSize(
      incomingValue: map['selectedSize'],
      availableValues: availableSizes,
    );

    ui.setResolvedSelections(
      colorId: resolvedColorId,
      size: resolvedSize,
      thumbIndex: selectedThumb.value,
      variationImagesLength: variationImages.length,
    );

    final current = item.value;
    if (current != null && Get.isRegistered<WishlistController>()) {
      ui.isFavorite.value =
          Get.find<WishlistController>().isInWishlist(current.id);
    }
  }

  // =========================================================
  // Actions
  // =========================================================
  void selectThumb(int index) {
    ui.selectThumb(
      index: index,
      maxLength: variationImages.length,
    );
  }

  void toggleFavorite() {
    final current = item.value;
    if (current == null) return;

    if (Get.isRegistered<WishlistController>()) {
      final wishlist = Get.find<WishlistController>();
      wishlist.toggleWishlist(current);
      ui.isFavorite.value = wishlist.isInWishlist(current.id);
      return;
    }

    ui.toggleFavorite();
  }

  void setDelivery(String id) {
    ui.setDelivery(id);
  }

  void setSelectedColor(String colorId) {
    ui.setSelectedColor(colorId);
  }

  void setSelectedSize(String value) {
    ui.setSelectedSize(value);
  }

  void addToCart() {
    final current = item.value;
    if (current == null) return;

    if (Get.isRegistered<CartController>()) {
      final variant = AppProductUtils.joinInline(selectedOptionChips);
      Get.find<CartController>().addToCart(
        current,
        variantText: variant.trim().isEmpty ? null : variant,
        rating: hasReviews ? averageRating : null,
        reviewsCount: hasReviews ? reviewsCount : null,
      );
    }

    Get.snackbar(Tk.cartTitle.tr, Tk.productDetailsAddedToCart.tr);
  }

  void buyNow() {
    final current = item.value;
    if (current == null) return;

    if (!Get.isRegistered<CartController>()) {
      Get.snackbar(
        Tk.productDetailsBuyNow.tr,
        Tk.productDetailsProceedToCheckout.tr,
      );
      return;
    }

    final cart = Get.find<CartController>();
    final variant = AppProductUtils.joinInline(selectedOptionChips);
    cart.addToCart(
      current,
      variantText: variant.trim().isEmpty ? null : variant,
      rating: hasReviews ? averageRating : null,
      reviewsCount: hasReviews ? reviewsCount : null,
    );
    cart.openPayment();
    Get.toNamed(AppRoutes.payment);
  }

  Future<void> shareProduct() async {
    final current = item.value;
    if (current == null) return;

    final shareText = [
      title,
      if (description.trim().isNotEmpty) description,
      '',
      Tk.productDetailsShareHint.tr,
      title,
    ].join('\n');

    try {
      await SharePlus.instance.share(
        ShareParams(text: shareText),
      );
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: shareText));
      Get.snackbar(
        Tk.commonDone.tr,
        Tk.commonCopied.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
