import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_controller.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/two_factor_challenge_controller.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';

/// حقن التبعيات الخاصة بشاشة تسجيل الدخول.
class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginService>(
      () => LoginService(
        Get.find<IAuthRepository>(),
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
