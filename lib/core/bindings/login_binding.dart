import 'package:get/get.dart';
import '../../controllers/login_controller.dart';

// LoginBinding مسؤول عن حقن LoginController
// عند الدخول إلى صفحة تسجيل الدخول
class LoginBinding extends Bindings {

  @override
  void dependencies() {

    // lazyPut يعني:
    // لا يتم إنشاء LoginController فورًا
    // بل يتم إنشاؤه عند أول استخدام له
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
  }
}
