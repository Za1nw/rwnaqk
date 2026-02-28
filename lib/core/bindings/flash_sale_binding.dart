import 'package:get/get.dart';
import 'package:rwnaqk/controllers/flash_sale_controller.dart';

class FlashSaleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FlashSaleController>(() => FlashSaleController());
  }
}
