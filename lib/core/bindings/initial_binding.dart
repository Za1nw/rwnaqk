import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_controller.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_service.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_ui_controller.dart';
import 'package:rwnaqk/controllers/cart/cart_controller.dart';
import 'package:rwnaqk/controllers/cart/cart_service.dart';
import 'package:rwnaqk/controllers/cart/cart_ui_controller.dart';
import 'package:rwnaqk/controllers/payment/payment_controller.dart';
import 'package:rwnaqk/controllers/payment/payment_ui_controller.dart';
import 'package:rwnaqk/controllers/home/home_service.dart';
import 'package:rwnaqk/controllers/home/home_ui_controller.dart';

import 'package:rwnaqk/controllers/main/main_controller.dart';
import 'package:rwnaqk/controllers/home/home_controller.dart';
import 'package:rwnaqk/controllers/main/main_service.dart';
import 'package:rwnaqk/controllers/main/main_ui_controller.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/controllers/orders/orders_service.dart';
import 'package:rwnaqk/controllers/orders/orders_ui_controller.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_service.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_ui_controller.dart';
// import باقي الكنترولرز لو عندك (Cart/Profile/Orders...)

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Controller الرئيسي للتنقل بين التبويبات
    Get.lazyPut<MainUiController>(() => MainUiController(), fenix: true);
    Get.lazyPut<MainService>(() => MainService(), fenix: true);
    Get.lazyPut<MainController>(
      () => MainController(Get.find<MainService>()),
      fenix: true,
    );

    // ✅ مهم جداً لأن HomeScreen داخل IndexedStack
    Get.lazyPut<HomeUiController>(() => HomeUiController(), fenix: true);
    Get.lazyPut<HomeService>(() => HomeService(), fenix: true);
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<HomeService>()),
      fenix: true,
    );
    // ✅ مهم جداً لأن WishlistScreen داخل IndexedStack
    Get.lazyPut<WishlistUiController>(
      () => WishlistUiController(),
      fenix: true,
    );
    Get.lazyPut<WishlistService>(() => WishlistService(), fenix: true);
    Get.lazyPut<WishlistController>(
      () => WishlistController(Get.find<WishlistService>()),
      fenix: true,
    );

    // لو عندك تبويبات أخرى:
    Get.put<AppSettingsUiController>(
      AppSettingsUiController(),
      permanent: true,
    );
    Get.put<AppSettingsService>(AppSettingsService(), permanent: true);
    Get.put<AppSettingsController>(
      AppSettingsController(Get.find<AppSettingsService>()),
      permanent: true,
    );
    Get.put<ProfileStoreService>(ProfileStoreService(), permanent: true);
    Get.put<PaymentUiController>(PaymentUiController(), permanent: true);
    Get.put<PaymentController>(PaymentController(), permanent: true);
    Get.put<CartUiController>(CartUiController(), permanent: true);
    Get.put<CartService>(
      CartService(Get.find<ProfileStoreService>()),
      permanent: true,
    );
    Get.put<CartController>(
      CartController(Get.find<CartService>()),
      permanent: true,
    );
    // Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<OrdersUiController>(() => OrdersUiController(), fenix: true);
    Get.lazyPut<OrdersService>(() => OrdersService(), fenix: true);
    Get.lazyPut<OrdersController>(
      () => OrdersController(Get.find<OrdersService>()),
      fenix: true,
    );
  }
}
