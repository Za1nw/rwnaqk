import 'package:get/get.dart';
import 'package:rwnaqk/controllers/wallet/wallet_controller.dart';
import 'package:rwnaqk/controllers/wallet/wallet_service.dart';
import 'package:rwnaqk/controllers/wallet/wallet_ui_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WalletUiController>()) {
      Get.lazyPut<WalletUiController>(() => WalletUiController());
    }

    if (!Get.isRegistered<WalletService>()) {
      Get.lazyPut<WalletService>(() => WalletService());
    }

    if (!Get.isRegistered<WalletController>()) {
      Get.lazyPut<WalletController>(
        () => WalletController(Get.find<WalletService>()),
      );
    }
  }
}
