import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_controller.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';

/// حقن التبعيات الخاصة بمنظومة استعادة كلمة المرور.
class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
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
