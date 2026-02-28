import 'package:get/get.dart';
import 'package:rwnaqk/core/routes/app_routes.dart';

class OnboardingController extends GetxController {
  void onGetStarted() {
    Get.toNamed(AppRoutes.main);
  }

  void onHaveAccount() {
    Get.toNamed(AppRoutes.login);
  }
}
