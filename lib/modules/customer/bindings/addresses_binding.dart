import 'package:get/get.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/addresses_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/providers/fake_addresses_remote_data_source.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository_impl.dart';

class AddressesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddressesUiController>()) {
      Get.lazyPut<AddressesUiController>(() => AddressesUiController());
    }

    if (!Get.isRegistered<IAddressesRepository>()) {
      Get.lazyPut<IAddressesRepository>(
        () => AddressesRepositoryImpl(
          apiClient: Get.find<ApiClient>(),
          fallbackRepository: FakeAddressesRepository(),
        ),
      );
    }

    if (!Get.isRegistered<AddressesService>()) {
      Get.lazyPut<AddressesService>(
        () => AddressesService(
          Get.find<ProfileStoreService>(),
          repository: Get.find<IAddressesRepository>(),
        ),
      );
    }

    if (!Get.isRegistered<AddressesController>()) {
      Get.lazyPut<AddressesController>(
        () => AddressesController(Get.find<AddressesService>()),
      );
    }
  }
}
