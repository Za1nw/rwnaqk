import 'package:get/get.dart';
import 'package:rwnaqk/models/home_product_item.dart';
import 'package:rwnaqk/models/product_review.dart';

class ProductDetailsController extends GetxController {
  // ====== Data ======
  final item = Rxn<HomeProductItem>();

  final images = <String>[].obs;          // صور الهيدر
  final variationImages = <String>[].obs; // صور الفاريشن (ثامبنيل)

  final reviews = <ProductReview>[].obs;
  final mostPopular = <HomeProductItem>[].obs;
  final recommended = <HomeProductItem>[].obs;

  // ====== UI State ======
  final selectedThumb = 0.obs;
  final isFavorite = false.obs;
  final deliverySelected = 'standard'.obs; // standard / express

  // (اختياري) لو تبغى حالات تحميل لاحقًا مع API
  final isLoading = false.obs;

  // ====== Computed helpers ======
  double get price => item.value?.price ?? 17;
  int get discount => item.value?.discountPercent ?? 0;
  bool get hasDiscount => discount > 0;

  String get salePriceText {
    final p = price;
    if (!hasDiscount) return p.toStringAsFixed(2);
    final sp = (p * (1 - discount / 100));
    return sp.toStringAsFixed(2);
  }

  String get oldPriceText => price.toStringAsFixed(2);

  @override
  void onInit() {
    super.onInit();
    _loadFromArgs(Get.arguments);
  }

  void _loadFromArgs(dynamic args) {
    // يدعم args بالشكل:
    // { item: HomeProductItem, reviews: [...], mostPopular: [...], recommended: [...] }
    final map = (args is Map) ? args : const {};

    final argItem = map['item'];
    if (argItem is HomeProductItem) {
      item.value = argItem;
    }

    // images
    final baseImages = <String>[
      if ((item.value?.imageUrl ?? '').isNotEmpty) item.value!.imageUrl,
      'https://picsum.photos/500/650?pd_a',
      'https://picsum.photos/500/650?pd_b',
      'https://picsum.photos/500/650?pd_c',
    ];
    images.assignAll(baseImages);

    // variation thumbs
    variationImages.assignAll(images.take(3).toList());
    if (variationImages.isEmpty) {
      variationImages.assignAll(images);
    }

    // reviews
    reviews.assignAll(_resolveReviews(map['reviews']));

    // lists
    mostPopular.assignAll(_resolveItems(map['mostPopular']));
    recommended.assignAll(_resolveItems(map['recommended']));
  }

  List<HomeProductItem> _resolveItems(dynamic raw) {
    if (raw is List<HomeProductItem>) return raw;
    if (raw is List) return raw.whereType<HomeProductItem>().toList();
    return const [];
  }

  List<ProductReview> _resolveReviews(dynamic raw) {
    // supports:
    // - List<ProductReview>
    // - List<Map>
    if (raw is List<ProductReview>) return raw;

    if (raw is List) {
      final out = <ProductReview>[];
      for (final e in raw) {
        if (e is ProductReview) out.add(e);
        else if (e is Map<String, dynamic>) out.add(ProductReview.fromMap(e));
        else if (e is Map) out.add(ProductReview.fromMap(Map<String, dynamic>.from(e)));
      }
      if (out.isNotEmpty) return out;
    }

    // fallback demo
    return const [
      ProductReview(
        name: 'Veronika',
        rating: 4.0,
        text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed diam...',
        dateText: '2 days ago',
      ),
    ];
  }

  // ====== Actions ======
  void selectThumb(int i) => selectedThumb.value = i;

  void toggleFavorite() => isFavorite.value = !isFavorite.value;

  void setDelivery(String id) => deliverySelected.value = id;

  void addToCart() {
    // TODO: اربطها بسلة مشروعك لاحقًا
    Get.snackbar('Cart', 'Added to cart');
  }

  void buyNow() {
    // TODO: checkout
    Get.snackbar('Buy', 'Proceed to checkout');
  }
}