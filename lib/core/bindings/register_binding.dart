import 'package:get/get.dart';
import 'package:rwnaqk/controllers/register/register_controller.dart';
import 'package:rwnaqk/controllers/register/register_service.dart';
import 'package:rwnaqk/controllers/register/register_ui_controller.dart';

/// هذا الملف مسؤول عن حقن التبعيات الخاصة بشاشة إنشاء الحساب.
///
/// نستخدم Binding مستقل هنا لأن الشاشة تعمل عبر route مستقل.
class RegisterBinding extends Bindings {
  @override
  /// هذه الدالة تقوم بتسجيل جميع التبعيات المطلوبة للشاشة.
  void dependencies() {
    Get.lazyPut<RegisterUiController>(() => RegisterUiController());
    Get.lazyPut<RegisterService>(() => RegisterService());
    Get.lazyPut<RegisterController>(
      () => RegisterController(Get.find<RegisterService>()),
    );
  }
}