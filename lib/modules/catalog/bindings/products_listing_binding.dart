import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_service.dart';
import 'package:rwnaqk_frontend/modules/catalog/controllers/products_listing_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/providers/fake_products_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';

/// هذا الملف مسؤول عن حقن التبعيات الخاصة بشاشة عرض المنتجات.
/// نستخدمه لأن هذه الشاشة تعمل عبر route مستقل داخل AppPages.
class ProductsListingBinding extends Bindings {
  @override
  /// هذه الدالة تقوم بتسجيل جميع الملفات التي تحتاجها الشاشة:
  /// - UI Controller
  /// - Service
  /// - Repository
  /// - Main Controller
  void dependencies() {
    Get.lazyPut<ProductsListingUiController>(
      () => ProductsListingUiController(),
      fenix: true,
    );

    Get.lazyPut<ProductsListingService>(
      () => ProductsListingService(),
      fenix: true,
    );

    Get.lazyPut<IProductsRepository>(
      () => FakeProductsRepository(
        listingService: Get.find<ProductsListingService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ProductsListingController>(
      () => ProductsListingController(
        Get.find<ProductsListingService>(),
        repository: Get.find<IProductsRepository>(),
      ),
      fenix: true,
    );
  }
}
