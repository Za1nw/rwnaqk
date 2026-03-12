import 'package:get/get.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_controller.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_service.dart';
import 'package:rwnaqk/controllers/products_listing/products_listing_ui_controller.dart';

/// هذا الملف مسؤول عن حقن التبعيات الخاصة بشاشة عرض المنتجات.
/// نستخدمه لأن هذه الشاشة تعمل عبر route مستقل داخل AppPages.
class ProductsListingBinding extends Bindings {
  @override
  /// هذه الدالة تقوم بتسجيل جميع الملفات التي تحتاجها الشاشة:
  /// - UI Controller
  /// - Service
  /// - Main Controller
  void dependencies() {
    Get.lazyPut<ProductsListingUiController>(
      () => ProductsListingUiController(),
    );

    Get.lazyPut<ProductsListingService>(
      () => ProductsListingService(),
    );

    Get.lazyPut<ProductsListingController>(
      () => ProductsListingController(Get.find<ProductsListingService>()),
    );
  }
}