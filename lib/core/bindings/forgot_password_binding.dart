import 'package:get/get.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_controller.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_service.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_ui_controller.dart';

/// هذا الملف مسؤول عن حقن التبعيات الخاصة بمنظومة استعادة كلمة المرور.
///
/// نستخدم Binding مستقل هنا لأن هذه الشاشات تعمل عبر routes مستقلة.
class ForgotPasswordBinding extends Bindings {
  @override
  /// هذه الدالة تقوم بتسجيل جميع التبعيات المطلوبة للشاشات.
  void dependencies() {
    Get.lazyPut<ForgotPasswordUiController>(
      () => ForgotPasswordUiController(),
      fenix: true,
    );

    Get.lazyPut<ForgotPasswordService>(
      () => ForgotPasswordService(),
      fenix: true,
    );

    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(Get.find<ForgotPasswordService>()),
      fenix: true,
    );
  }
}