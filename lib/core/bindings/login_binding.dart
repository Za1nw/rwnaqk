import 'package:get/get.dart';
import 'package:rwnaqk/controllers/login/login_controller.dart';
import 'package:rwnaqk/controllers/login/login_service.dart';
import 'package:rwnaqk/controllers/login/login_ui_controller.dart';

/// هذا الملف مسؤول عن حقن التبعيات الخاصة بشاشة تسجيل الدخول.
///
/// نستخدم Binding مستقل هنا لأن الشاشة تعمل عبر route مستقل.
class LoginBinding extends Bindings {
  @override
  /// هذه الدالة تقوم بتسجيل جميع التبعيات المطلوبة للشاشة.
  void dependencies() {
    Get.lazyPut<LoginUiController>(() => LoginUiController());
    Get.lazyPut<LoginService>(() => LoginService());
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<LoginService>()),
    );
  }
}