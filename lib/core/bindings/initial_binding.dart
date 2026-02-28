import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings_controller.dart';
import 'package:rwnaqk/controllers/cart_controller.dart';

import 'package:rwnaqk/controllers/main_controller.dart';
import 'package:rwnaqk/controllers/home_controller.dart';
import 'package:rwnaqk/controllers/wishlist_controller.dart';
// import باقي الكنترولرز لو عندك (Cart/Profile/Orders...)

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Controller الرئيسي للتنقل بين التبويبات
    Get.lazyPut<MainController>(() => MainController(), fenix: true);

    // ✅ مهم جداً لأن HomeScreen داخل IndexedStack
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

    // ✅ مهم جداً لأن WishlistScreen داخل IndexedStack
    Get.lazyPut<WishlistController>(() => WishlistController(), fenix: true);

    // لو عندك تبويبات أخرى:
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
    Get.put<AppSettingsController>(AppSettingsController(), permanent: true);

    // Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    // Get.lazyPut<OrdersController>(() => OrdersController(), fenix: true);
  }
}
