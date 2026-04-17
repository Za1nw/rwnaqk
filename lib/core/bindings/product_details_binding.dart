import 'package:get/get.dart';
import 'package:rwnaqk/controllers/product_details/product_details_controller.dart';
import 'package:rwnaqk/controllers/product_details/product_details_service.dart';
import 'package:rwnaqk/controllers/product_details/product_details_ui_controller.dart';

class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductDetailsUiController>(
      () => ProductDetailsUiController(),
      fenix: true,
    );
    Get.lazyPut<ProductDetailsService>(
      () => ProductDetailsService(),
      fenix: true,
    );
    Get.lazyPut<ProductDetailsController>(
      () => ProductDetailsController(Get.find<ProductDetailsService>()),
      fenix: true,
    );
  }
}
