import 'package:get/get.dart';
import 'package:rwnaqk/controllers/support/help_center_controller.dart';
import 'package:rwnaqk/controllers/support/help_center_service.dart';
import 'package:rwnaqk/controllers/support/support_chat_controller.dart';
import 'package:rwnaqk/controllers/support/support_chat_service.dart';
import 'package:rwnaqk/controllers/support/support_chat_ui_controller.dart';

class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HelpCenterService>(() => HelpCenterService(), fenix: true);
    Get.lazyPut<HelpCenterController>(
      () => HelpCenterController(Get.find<HelpCenterService>()),
      fenix: true,
    );

    Get.lazyPut<SupportChatUiController>(
      () => SupportChatUiController(),
      fenix: true,
    );
    Get.lazyPut<SupportChatService>(() => SupportChatService(), fenix: true);
    Get.lazyPut<SupportChatController>(
      () => SupportChatController(Get.find<SupportChatService>()),
      fenix: true,
    );
  }
}
