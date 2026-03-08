import 'package:get/get.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/product_color_option.dart';
import 'package:rwnaqk/models/product_review.dart';

class ProductDetailsController extends GetxController {
  // =========================================================
  // Product
  // =========================================================
  final Rxn<HomeProductItem> item = Rxn<HomeProductItem>();

  // =========================================================
  // UI State
  // =========================================================
  final RxInt selectedThumb = 0.obs;
  final RxBool isFavorite = false.obs;
  final RxString deliverySelected = 'standard'.obs;
  final RxBool isLoading = false.obs;

  final RxString selectedColorId = ''.obs;
  final RxString selectedSize = ''.obs;

  // =========================================================
  // Related content
  // =========================================================
  final RxList<ProductReview> reviews = <ProductReview>[].obs;
  final RxList<HomeProductItem> mostPopular = <HomeProductItem>[].obs;
  final RxList<HomeProductItem> recommended = <HomeProductItem>[].obs;

  // =========================================================
  // Base getters
  // =========================================================
  HomeProductItem? get product => item.value;

  String get title {
    final value = product?.title.trim() ?? '';
    return value.isEmpty ? 'Product' : value;
  }

  String get description {
    final value = product?.description.trim() ?? '';
    return value.isEmpty
        ? 'A stylish and modern product designed for everyday comfort and clean presentation.'
        : value;
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
    return value.isEmpty ? 'Rwnaq' : value;
  }

  String get sku {
    final value = product?.sku.trim() ?? '';
    return value.isEmpty ? 'SKU-${product?.id ?? '000'}' : value;
  }

  String get stockText {
    final value = product?.stockText.trim() ?? '';
    return value.isEmpty ? 'In Stock' : value;
  }

  String get soldText {
    final value = product?.soldText.trim() ?? '';
    return value.isEmpty ? '120 sold' : value;
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
      chips.add(colorName);
    }

    if (selectedSize.value.trim().isNotEmpty) {
      chips.add(selectedSize.value.trim());
    }

    return chips;
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

    reviews.assignAll(_resolveReviews(map['reviews']));
    mostPopular.assignAll(_resolveItems(map['mostPopular']));
    recommended.assignAll(_resolveItems(map['recommended']));

    selectedColorId.value = _resolveSelectedColorId(
      incomingValue: map['selectedColorId'] ?? map['selectedColor'],
      availableValues: availableColors,
    );

    selectedSize.value = _resolveSelectedSize(
      incomingValue: map['selectedSize'],
      availableValues: availableSizes,
    );

    if (variationImages.isEmpty) {
      selectedThumb.value = 0;
    } else {
      selectedThumb.value = selectedThumb.value.clamp(
        0,
        variationImages.length - 1,
      );
    }
  }

  // =========================================================
  // Resolvers
  // =========================================================
  List<HomeProductItem> _resolveItems(dynamic raw) {
    if (raw is List<HomeProductItem>) return raw;
    if (raw is List) return raw.whereType<HomeProductItem>().toList();
    return <HomeProductItem>[];
  }

  List<ProductReview> _resolveReviews(dynamic raw) {
    if (raw is List<ProductReview>) return raw;

    if (raw is List) {
      final out = <ProductReview>[];

      for (final e in raw) {
        if (e is ProductReview) {
          out.add(e);
        } else if (e is Map<String, dynamic>) {
          out.add(ProductReview.fromMap(e));
        } else if (e is Map) {
          out.add(ProductReview.fromMap(Map<String, dynamic>.from(e)));
        }
      }

      if (out.isNotEmpty) return out;
    }

    return const <ProductReview>[
      ProductReview(
        name: 'Veronika',
        rating: 4.0,
        text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam.',
        dateText: '2 days ago',
      ),
    ];
  }

  String _resolveSelectedColorId({
    required dynamic incomingValue,
    required List<ProductColorOption> availableValues,
  }) {
    final incoming = (incomingValue ?? '').toString().trim();

    if (incoming.isNotEmpty) {
      for (final item in availableValues) {
        if (item.id == incoming) return item.id;
      }
    }

    if (availableValues.isNotEmpty) return availableValues.first.id;
    return '';
  }

  String _resolveSelectedSize({
    required dynamic incomingValue,
    required List<String> availableValues,
  }) {
    final incoming = (incomingValue ?? '').toString().trim();

    if (incoming.isNotEmpty) return incoming;
    if (availableValues.isNotEmpty) return availableValues.first;
    return '';
  }

  // =========================================================
  // Actions
  // =========================================================
  void selectThumb(int index) {
    if (variationImages.isEmpty) {
      selectedThumb.value = 0;
      return;
    }

    selectedThumb.value = index.clamp(0, variationImages.length - 1);
  }

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
  }

  void setDelivery(String id) {
    deliverySelected.value = id;
  }

  void setSelectedColor(String colorId) {
    selectedColorId.value = colorId.trim();
  }

  void setSelectedSize(String value) {
    selectedSize.value = value.trim();
  }

  void addToCart() {
    Get.snackbar('Cart', 'Added to cart');
  }

  void buyNow() {
    Get.snackbar('Buy', 'Proceed to checkout');
  }
}