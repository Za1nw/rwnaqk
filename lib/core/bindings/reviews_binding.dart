import 'package:get/get.dart';
import 'package:rwnaqk/controllers/reviews/reviews_controller.dart';
import 'package:rwnaqk/controllers/reviews/reviews_service.dart';
import 'package:rwnaqk/controllers/reviews/reviews_ui_controller.dart';

/// هذا الملف مسؤول عن حقن التبعيات الخاصة بشاشة المراجعات.
///
/// نستخدم Binding مستقل هنا لأن الشاشة تعمل عبر route مستقل في AppPages.
class ReviewsBinding extends Bindings {
  @override
  /// هذه الدالة تقوم بتسجيل جميع التبعيات المطلوبة للشاشة.
  void dependencies() {
    Get.lazyPut<ReviewsUiController>(() => ReviewsUiController(), fenix: true);
    Get.lazyPut<ReviewsService>(() => ReviewsService(), fenix: true);
    Get.lazyPut<ReviewsController>(
      () => ReviewsController(Get.find<ReviewsService>()),
      fenix: true,
    );
  }
}
