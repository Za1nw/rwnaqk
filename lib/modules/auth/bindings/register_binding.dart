import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/register_controller.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/register_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';

/// حقن التبعيات الخاصة بشاشة إنشاء الحساب.
class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GeoLookupApiService>(() => GeoLookupApiService(), fenix: true);
    Get.lazyPut<RegisterService>(
      () => RegisterService(
        Get.find<CustomerAuthApiService>(),
        Get.find<AuthSessionService>(),
        Get.find<GeoLookupApiService>(),
        authRepository: Get.isRegistered<IAuthRepository>()
            ? Get.find<IAuthRepository>()
            : null,
      ),
      fenix: true,
    );
    Get.lazyPut<RegisterController>(
      () => RegisterController(Get.find<RegisterService>()),
      fenix: true,
    );
  }
}
