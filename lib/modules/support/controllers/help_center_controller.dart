import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/support/controllers/help_center_service.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:rwnaqk_frontend/core/translations/app_locale_keys.dart';

class HelpCenterController extends GetxController {
  HelpCenterController(this._service);

  final HelpCenterService _service;

  List<HelpCenterEntry> get supportEntries => _service.supportEntries();
  List<HelpCenterContactEntry> get contactEntries => _service.contactEntries();
  List<String> get faqQuestions => _service.faqQuestions();

  void openSupport(String titleKey) {
    Get.toNamed(
      AppRoutes.supportChat,
      arguments: _service.buildSupportArgs(titleKey),
    );
  }

  void openDefaultSupport() {
    openSupport(Tk.helpCenterContactSupport);
  }
}
