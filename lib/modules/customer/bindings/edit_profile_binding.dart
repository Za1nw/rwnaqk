import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/edit_profile_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/edit_profile_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/edit_profile_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';

class EditProfileBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EditProfileUiController>()) {
      Get.lazyPut<EditProfileUiController>(() => EditProfileUiController());
    }

    if (!Get.isRegistered<EditProfileService>()) {
      Get.lazyPut<EditProfileService>(
        () => EditProfileService(Get.find<ProfileStoreService>()),
      );
    }

    if (!Get.isRegistered<EditProfileController>()) {
      Get.lazyPut<EditProfileController>(
        () => EditProfileController(Get.find<EditProfileService>()),
      );
    }
  }
}
