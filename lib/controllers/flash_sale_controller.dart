import 'dart:async';
import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';
import 'package:rwnaqk/models/home_product_item.dart';

class FlashSaleController extends GetxController {
  final selectedDiscount = 20.obs; // Default to 20%
  final discounts = [0, 10, 20, 30, 40, 50]; // 0 for All

  // Countdown timer state
  final hh = 0.obs;
  final mm = 36.obs;
  final ss = 58.obs;
  Timer? _timer;

  final flashSaleProducts = <HomeProductItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _startFlashTimer();
    _loadFlashSaleProducts();
  }

  void _startFlashTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      int total = (hh.value * 3600) + (mm.value * 60) + ss.value;
      if (total <= 0) {
        _timer?.cancel();
        return;
      }
      total -= 1;
      hh.value = total ~/ 3600;
      mm.value = (total % 3600) ~/ 60;
      ss.value = total % 60;
    });
  }

  void _loadFlashSaleProducts() {
    // Mock data for flash sale products
    flashSaleProducts.assignAll(_sampleProducts(10, seed: 1000, discount: selectedDiscount.value));
  }

  void selectDiscount(int discount) {
    selectedDiscount.value = discount;
    _loadFlashSaleProducts(); // Reload products based on new discount
  }

  void openProduct(HomeProductItem item) {
    final isSale = (item.discountPercent ?? 0) > 0;
    Get.toNamed(
      AppRoutes.product,
      arguments: {'item': item, 'forceSale': isSale},
    );
  }

  List<HomeProductItem> _sampleProducts(
    int n, {
    required int seed,
    int? discount,
    String tagKey = '',
  }) {
    return List.generate(n, (i) {
      final id = '${seed}_$i';
      return HomeProductItem(
        id: id,
        title: 'Item $id',
        imageUrl: 'https://picsum.photos/400/500?$id',
        price: 17 + (i * 5).toDouble(),
        discountPercent: discount,
        isNew: i % 3 == 0,
        tagKey: tagKey,
      );
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
