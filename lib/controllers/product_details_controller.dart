import 'package:get/get.dart';

class ProductDetailsController extends GetxController {
  // Data (عادة تجي من arguments أو API)
  final productName = 'Product'.obs;
  final price = 17.00.obs;
  final currency = '\$'.obs;
  final description = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam arcu mauris, scelerisque eu mauris id, pretium pulvinar sapien.'
      .obs;

  final imageUrl = 'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1200&q=80'
      .obs;

  // Variations (thumbnails)
  final variations = <String>[
    'https://images.unsplash.com/photo-1520975958225-5b92f0a5a606?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1520975597974-9f5761f7673b?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1520975867597-0a9b2f2b0f10?auto=format&fit=crop&w=400&q=80',
  ].obs;

  final selectedVariation = 0.obs;

  // Options (chips)
  final colors = <String>['Pink', 'Blue', 'Red'].obs;
  final sizes = <String>['S', 'M', 'L'].obs;

  final selectedColor = 'Pink'.obs;
  final selectedSize = 'M'.obs;

  void selectVariation(int i) => selectedVariation.value = i;
  void selectColor(String v) => selectedColor.value = v;
  void selectSize(String v) => selectedSize.value = v;

  void addToCart() {
    // TODO: اربطها بسلة مشروعك
    Get.snackbar('Cart', 'Added to cart');
  }

  void buyNow() {
    // TODO: checkout
    Get.snackbar('Buy', 'Proceed to checkout');
  }
}