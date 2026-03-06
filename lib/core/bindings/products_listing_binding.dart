import 'package:get/get.dart';
import 'package:rwnaqk/controllers/products_listing_controller.dart';

class ProductsListingBinding extends Bindings {

  @override
  void dependencies() {

    Get.lazyPut<ProductsListingController>(
      () => ProductsListingController(),
    );

  }

}