import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/cart_added_dialog.dart';
import 'package:rwnaqk_frontend/core/widgets/dialogs/favorite_added_dialog.dart';
import 'package:rwnaqk_frontend/core/widgets/feedback/app_toast.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';
import 'package:rwnaqk_frontend/core/translations/app_mock_locale_keys.dart';
import 'package:rwnaqk_frontend/core/utils/app_mock_content_utils.dart';
import 'package:rwnaqk_frontend/core/utils/app_product_utils.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_color_option.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_review.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_attribute_group.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/models/product_size_guide.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/providers/fake_products_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:share_plus/share_plus.dart';

import 'product_details_service.dart';
import 'product_details_ui_controller.dart';

class ProductDetailsController extends GetxController {
  ProductDetailsController(
    this._service, {
    IProductsRepository? repository,
  }) : _repository =
            repository ?? FakeProductsRepository(detailsService: _service);

  final ProductDetailsService _service;
  final IProductsRepository _repository;

  IProductsRepository get repository => _repository;

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
  // Dynamic Attributes & Variants
  // =========================================================
  final RxList<ProductAttributeGroup> attributeGroups =
      <ProductAttributeGroup>[].obs;
  final RxMap<String, String> selectedAttributes = <String, String>{}.obs;

  // =========================================================
  // UI bridges (حتى لا تتكسر الشاشة الحالية)
  // =========================================================
  RxInt get selectedThumb => ui.selectedThumb;
  RxBool get isFavorite => ui.isFavorite;
  RxString get deliverySelected => ui.deliverySelected;
  RxString get selectedColorId => ui.selectedColorId;
  RxString get selectedSize => ui.selectedSize;
  RxInt get quantity => ui.quantity;

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

  double get unitPrice => hasDiscount ? (price * (1 - discount / 100)) : price;

  double get totalPrice => unitPrice * quantity.value;

  String get totalPriceText => totalPrice.toStringAsFixed(2);

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
        .whereType<ProductColorOption>()
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
    if (attributeGroups.isNotEmpty) {
      final chips = <String>[];
      for (final group in attributeGroups) {
        final optId = selectedAttributes[group.id];
        if (optId != null) {
          for (final opt in group.options) {
            if (opt.id == optId) {
              chips.add(opt.label.tr);
              break;
            }
          }
        }
      }
      if (chips.isNotEmpty) return chips;
    }

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

  ProductSizeGuide get sizeGuide {
    if (product?.sizeGuide != null) {
      return product!.sizeGuide!;
    }
    return ProductSizeGuide.forProductTitle(title, availableSizes);
  }

  int get photosCount => images.length;

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
      ui.isFavorite.value = Get.find<WishlistController>().isInWishlist(
        current.id,
      );
    }

    final rawGroups = map['attributeGroups'];
    if (rawGroups is List<ProductAttributeGroup> && rawGroups.isNotEmpty) {
      attributeGroups.assignAll(rawGroups);
      for (final g in rawGroups) {
        if (g.options.isNotEmpty) {
          selectedAttributes[g.id] = g.options.first.id;
        }
      }
    } else {
      _initDefaultAttributeGroups(
        resolvedColorId: resolvedColorId,
        resolvedSize: resolvedSize,
      );
    }
  }

  void _initDefaultAttributeGroups({
    required String resolvedColorId,
    required String resolvedSize,
  }) {
    final groups = <ProductAttributeGroup>[];

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
      selectedAttributes['color'] = resolvedColorId.isNotEmpty
          ? resolvedColorId
          : availableColors.first.id;
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
      selectedAttributes['size'] = resolvedSize.isNotEmpty
          ? resolvedSize
          : availableSizes.first;
    }

    if (variationImages.isNotEmpty) {
      groups.add(
        ProductAttributeGroup(
          id: 'style',
          name: 'الموديل',
          type: ProductAttributeType.image,
          options: variationImages.asMap().entries.map((entry) {
            return ProductAttributeOption(
              id: 'style_${entry.key}',
              label: '${entry.key + 1}',
              imageUrl: entry.value,
            );
          }).toList(),
        ),
      );
      if (selectedAttributes['style'] == null &&
          groups.last.options.isNotEmpty) {
        selectedAttributes['style'] = groups.last.options.first.id;
      }
    }

    attributeGroups.assignAll(groups);
  }

  void selectAttribute(String groupId, String optionId) {
    selectedAttributes[groupId] = optionId;
    if (groupId == 'color') {
      setSelectedColor(optionId);
    } else if (groupId == 'size') {
      setSelectedSize(optionId);
    } else if (groupId == 'style') {
      final index = int.tryParse(optionId.replaceAll('style_', ''));
      if (index != null) {
        selectThumb(index);
      }
    }
  }

  String get selectedOptionsSummary {
    if (attributeGroups.isEmpty) {
      final chips = selectedOptionChips;
      return chips.isEmpty
          ? Tk.productDetailsSelectOptions.tr
          : chips.join(' • ');
    }
    final summaryList = <String>[];
    for (final group in attributeGroups) {
      final selectedOptId = selectedAttributes[group.id];
      if (selectedOptId != null) {
        for (final opt in group.options) {
          if (opt.id == selectedOptId) {
            summaryList.add('${group.name}: ${opt.label}');
            break;
          }
        }
      }
    }
    if (summaryList.isEmpty) {
      return Tk.productDetailsSelectOptions.tr;
    }
    return summaryList.join(' • ');
  }

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
    reviews.insert(0, newReview);
    AppToast.success(Tk.reviewsSuccessMessage.tr);
  }

  // =========================================================
  // Actions
  // =========================================================
  void selectThumb(int index) {
    ui.selectThumb(index: index, maxLength: variationImages.length);
  }

  void toggleFavorite() {
    final current = item.value;
    if (current == null) return;

    final wasFavorite = ui.isFavorite.value;

    if (Get.isRegistered<WishlistController>()) {
      final wishlist = Get.find<WishlistController>();
      wishlist.toggleWishlist(current);
      ui.isFavorite.value = wishlist.isInWishlist(current.id);
    } else {
      ui.toggleFavorite();
    }

    if (!wasFavorite && ui.isFavorite.value) {
      final context = Get.context;
      if (context != null) {
        FavoriteAddedDialog.show(context);
      }
    }
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

  void incrementQuantity() => ui.incrementQuantity();
  void decrementQuantity() => ui.decrementQuantity();

  void addToCart() {
    final current = item.value;
    if (current == null) return;

    if (Get.isRegistered<CartController>()) {
      final cart = Get.find<CartController>();
      final variant = AppProductUtils.joinInline(selectedOptionChips);
      cart.addToCart(
        current,
        quantity: quantity.value,
        variantText: variant.trim().isEmpty ? null : variant,
        rating: hasReviews ? averageRating : null,
        reviewsCount: hasReviews ? reviewsCount : null,
      );
    }

    final context = Get.context;
    if (context != null) {
      CartAddedDialog.show(context);
    }
  }

  void buyNow() {
    final current = item.value;
    if (current == null) return;

    if (!Get.isRegistered<CartController>()) {
      AppToast.info(
        Tk.productDetailsProceedToCheckout.tr,
        title: Tk.productDetailsBuyNow.tr,
      );
      return;
    }

    final cart = Get.find<CartController>();
    final variant = AppProductUtils.joinInline(selectedOptionChips);
    cart.addToCart(
      current,
      quantity: quantity.value,
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
      await SharePlus.instance.share(ShareParams(text: shareText));
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: shareText));
      AppToast.copied(message: Tk.commonCopied.tr, title: Tk.commonDone.tr);
    }
  }
}
