import 'package:get/get.dart';
import '../models/home_product_item.dart';

class CartController extends GetxController {

  final cartItems = <HomeProductItem>[].obs;
  final wishlistItems = <HomeProductItem>[].obs;

  double get total =>
      cartItems.fold(0, (sum, e) => sum + e.price);

  bool get isEmpty => cartItems.isEmpty;

  void removeFromCart(String id) {
    cartItems.removeWhere((e) => e.id == id);
  }

  void addToCart(HomeProductItem item) {
    cartItems.add(item);
  }

  void goCheckout() {
    // Get.toNamed(AppRoutes.payment);
  }

  @override
  void onInit() {
    super.onInit();
    _mock();
  }

  void _mock() {
    cartItems.addAll([
      HomeProductItem(
        id: '1',
        title: 'Pink Dress',
        imageUrl: 'https://picsum.photos/200',
        price: 17,
      ),
      HomeProductItem(
        id: '2',
        title: 'Summer Shirt',
        imageUrl: 'https://picsum.photos/201',
        price: 17,
      ),
    ]);

    wishlistItems.addAll([
      HomeProductItem(
        id: '3',
        title: 'Wishlist Item',
        imageUrl: 'https://picsum.photos/202',
        price: 17,
      ),
    ]);
  }
}