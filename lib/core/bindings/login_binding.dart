import 'package:get/get.dart';
import 'package:rwnaqk/controllers/login/login_controller.dart';
import 'package:rwnaqk/controllers/login/login_service.dart';
import 'package:rwnaqk/controllers/login/two_factor_challenge_controller.dart';
import 'package:rwnaqk/controllers/login/login_ui_controller.dart';
import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';

/// هذا الملف مسؤول عن حقن التبعيات الخاصة بشاشة تسجيل الدخول.
///
/// نستخدم Binding مستقل هنا لأن الشاشة تعمل عبر route مستقل.
class LoginBinding extends Bindings {
  @override
  /// هذه الدالة تقوم بتسجيل جميع التبعيات المطلوبة للشاشة.
  void dependencies() {
    Get.lazyPut<LoginUiController>(() => LoginUiController(), fenix: true);
    Get.lazyPut<LoginService>(
      () => LoginService(
        Get.find<CustomerAuthApiService>(),
        Get.find<AuthSessionService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<LoginController>(
      () => LoginController(Get.find<LoginService>()),
      fenix: true,
    );
    Get.lazyPut<TwoFactorChallengeController>(
      () => TwoFactorChallengeController(Get.find<LoginService>()),
      fenix: true,
    );
  }
}
