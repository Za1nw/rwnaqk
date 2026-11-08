import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/product_details_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/providers/fake_products_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';

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
    Get.lazyPut<IProductsRepository>(
      () => FakeProductsRepository(
        detailsService: Get.find<ProductDetailsService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<ProductDetailsController>(
      () => ProductDetailsController(
        Get.find<ProductDetailsService>(),
        repository: Get.find<IProductsRepository>(),
      ),
      fenix: true,
    );
  }
}
