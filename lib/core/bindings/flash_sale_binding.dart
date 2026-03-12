import 'package:get/get.dart';
import 'package:rwnaqk/controllers/flash_sale/flash_sale_controller.dart';
import 'package:rwnaqk/controllers/flash_sale/flash_sale_service.dart';
import 'package:rwnaqk/controllers/flash_sale/flash_sale_ui_controller.dart';

/// هذا الملف مسؤول عن حقن التبعيات الخاصة بشاشة العروض السريعة.
///
/// نستخدم Binding مستقل هنا لأن الشاشة تعمل عبر route مستقل في AppPages.
class FlashSaleBinding extends Bindings {
  @override
  /// هذه الدالة تقوم بتسجيل جميع التبعيات المطلوبة للشاشة.
  void dependencies() {
    Get.lazyPut<FlashSaleUiController>(() => FlashSaleUiController());
    Get.lazyPut<FlashSaleService>(() => FlashSaleService());
    Get.lazyPut<FlashSaleController>(
      () => FlashSaleController(Get.find<FlashSaleService>()),
    );
  }
}