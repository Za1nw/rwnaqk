import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_ui_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AppSettingsUiController>()) {
      Get.lazyPut<AppSettingsUiController>(
        () => AppSettingsUiController(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AppSettingsService>()) {
      Get.lazyPut<AppSettingsService>(() => AppSettingsService(), fenix: true);
    }

    if (!Get.isRegistered<AppSettingsController>()) {
      Get.lazyPut<AppSettingsController>(
        () => AppSettingsController(Get.find<AppSettingsService>()),
        fenix: true,
      );
    }
  }
}
