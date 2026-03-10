import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppSettingsController>(() => AppSettingsController());
  }
}