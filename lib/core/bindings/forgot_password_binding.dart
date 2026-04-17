import 'package:get/get.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_controller.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_service.dart';
import 'package:rwnaqk/controllers/forgot_password/forgot_password_ui_controller.dart';
import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';

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
      () => ForgotPasswordService(
        Get.find<CustomerAuthApiService>(),
        Get.find<AuthSessionService>(),
      ),
      fenix: true,
    );

    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(Get.find<ForgotPasswordService>()),
      fenix: true,
    );
  }
}
