import 'dart:async';

import 'package:get/get.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_controller.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_service.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/home_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/main_controller.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/main_service.dart';
import 'package:rwnaqk_frontend/modules/home/controllers/main_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_service.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/providers/fake_orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_controller.dart';
import 'package:rwnaqk_frontend/modules/checkout/controllers/payment_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_service.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_ui_controller.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository_impl.dart';

class InitialBinding extends Bindings {
  InitialBinding({this.initialAccessToken, this.tokenStorage});

  final String? initialAccessToken;
  final IAuthTokenStorage? tokenStorage;

  @override
  void dependencies() {
    _registerCoreServices();
    _bootstrapAuthSession();

    _registerMainTabDependencies();
    _registerAppWideFeatureDependencies();
  }

  void _registerCoreServices() {
    Get.put<IAuthTokenStorage>(
      tokenStorage ?? SecureAuthTokenStorage(),
      permanent: true,
    );
    Get.put<ApiClient>(
      ApiClient(tokenStorage: Get.find<IAuthTokenStorage>()),
      permanent: true,
    );
    Get.put<IAuthRepository>(
      AuthRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        tokenStorage: Get.find<IAuthTokenStorage>(),
      ),
      permanent: true,
    );
    Get.put<CustomerAuthApiService>(CustomerAuthApiService(), permanent: true);
    Get.put<AuthSessionService>(
      AuthSessionService(
        initialAccessToken: initialAccessToken,
        tokenStorage: Get.find<IAuthTokenStorage>(),
      ),
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
    Get.put<OrdersService>(OrdersService(), permanent: true);
    Get.put<IOrdersRepository>(
      OrdersRepositoryImpl(
        apiClient: Get.find<ApiClient>(),
        fallbackRepository: FakeOrdersRepository(service: Get.find<OrdersService>()),
      ),
      permanent: true,
    );
    Get.lazyPut<OrdersController>(
      () => OrdersController(
        Get.find<OrdersService>(),
        repository: Get.find<IOrdersRepository>(),
      ),
      fenix: true,
    );
  }
}
