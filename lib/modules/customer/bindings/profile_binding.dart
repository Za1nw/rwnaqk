import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/two_factor_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/two_factor_settings_service.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfileService>()) {
      Get.lazyPut<ProfileService>(
        () => ProfileService(Get.find<ProfileStoreService>()),
      );
    }

    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(
        () => ProfileController(Get.find<ProfileService>()),
      );
    }

    if (!Get.isRegistered<TwoFactorSettingsService>()) {
      Get.lazyPut<TwoFactorSettingsService>(
        () => TwoFactorSettingsService(
          Get.find<CustomerAuthApiService>(),
          Get.find<AuthSessionService>(),
        ),
      );
    }

    if (!Get.isRegistered<TwoFactorSettingsController>()) {
      Get.lazyPut<TwoFactorSettingsController>(
        () => TwoFactorSettingsController(Get.find<TwoFactorSettingsService>()),
      );
    }
  }
}
