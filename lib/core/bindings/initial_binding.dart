import 'dart:async';

import 'package:get/get.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_controller.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_service.dart';
import 'package:rwnaqk/controllers/app_settings/app_settings_ui_controller.dart';
import 'package:rwnaqk/controllers/cart/cart_controller.dart';
import 'package:rwnaqk/controllers/cart/cart_service.dart';
import 'package:rwnaqk/controllers/cart/cart_ui_controller.dart';
import 'package:rwnaqk/controllers/home/home_controller.dart';
import 'package:rwnaqk/controllers/home/home_service.dart';
import 'package:rwnaqk/controllers/home/home_ui_controller.dart';
import 'package:rwnaqk/controllers/main/main_controller.dart';
import 'package:rwnaqk/controllers/main/main_service.dart';
import 'package:rwnaqk/controllers/main/main_ui_controller.dart';
import 'package:rwnaqk/controllers/orders/orders_controller.dart';
import 'package:rwnaqk/controllers/orders/orders_service.dart';
import 'package:rwnaqk/controllers/orders/orders_ui_controller.dart';
import 'package:rwnaqk/controllers/payment/payment_controller.dart';
import 'package:rwnaqk/controllers/payment/payment_ui_controller.dart';
import 'package:rwnaqk/controllers/profile/profile_store_service.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_controller.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_service.dart';
import 'package:rwnaqk/controllers/wishlist/wishlist_ui_controller.dart';
import 'package:rwnaqk/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk/core/services/auth/customer_auth_api_service.dart';

class InitialBinding extends Bindings {
  InitialBinding({this.initialAccessToken});

  final String? initialAccessToken;

  @override
  void dependencies() {
    _registerCoreServices();
    _bootstrapAuthSession();

    _registerMainTabDependencies();
    _registerAppWideFeatureDependencies();
  }

  void _registerCoreServices() {
    Get.put<CustomerAuthApiService>(CustomerAuthApiService(), permanent: true);
    Get.put<AuthSessionService>(
      AuthSessionService(initialAccessToken: initialAccessToken),
      permanent: true,
    );
  }

  void _bootstrapAuthSession() {
    unawaited(
      Get.find<AuthSessionService>().bootstrapSession(
        Get.find<CustomerAuthApiService>(),
      ),
    );
  }

  void _registerMainTabDependencies() {
    Get.lazyPut<MainUiController>(() => MainUiController(), fenix: true);
    Get.lazyPut<MainService>(() => MainService(), fenix: true);
    Get.lazyPut<MainController>(
      () => MainController(Get.find<MainService>()),
      fenix: true,
    );

    Get.lazyPut<HomeUiController>(() => HomeUiController(), fenix: true);
    Get.lazyPut<HomeService>(() => HomeService(), fenix: true);
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<HomeService>()),
      fenix: true,
    );

    Get.lazyPut<WishlistUiController>(
      () => WishlistUiController(),
      fenix: true,
    );
    Get.lazyPut<WishlistService>(() => WishlistService(), fenix: true);
    Get.lazyPut<WishlistController>(
      () => WishlistController(Get.find<WishlistService>()),
      fenix: true,
    );
  }

  void _registerAppWideFeatureDependencies() {
    Get.put<AppSettingsUiController>(
      AppSettingsUiController(),
      permanent: true,
    );
    Get.put<AppSettingsService>(AppSettingsService(), permanent: true);
    Get.put<AppSettingsController>(
      AppSettingsController(Get.find<AppSettingsService>()),
      permanent: true,
    );
    Get.put<ProfileStoreService>(
      ProfileStoreService(Get.find<AuthSessionService>()),
      permanent: true,
    );
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

    Get.lazyPut<OrdersUiController>(() => OrdersUiController(), fenix: true);
    Get.lazyPut<OrdersService>(() => OrdersService(), fenix: true);
    Get.lazyPut<OrdersController>(
      () => OrdersController(Get.find<OrdersService>()),
      fenix: true,
    );
  }
}
