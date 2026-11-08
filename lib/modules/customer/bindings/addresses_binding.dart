import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';

class AddressesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddressesUiController>()) {
      Get.lazyPut<AddressesUiController>(() => AddressesUiController());
    }

    if (!Get.isRegistered<AddressesService>()) {
      Get.lazyPut<AddressesService>(
        () => AddressesService(Get.find<ProfileStoreService>()),
      );
    }

    if (!Get.isRegistered<AddressesController>()) {
      Get.lazyPut<AddressesController>(
        () => AddressesController(Get.find<AddressesService>()),
      );
    }
  }
}
