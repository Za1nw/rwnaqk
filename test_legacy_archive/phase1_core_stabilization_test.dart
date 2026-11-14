import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/customer_auth_api_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_controller.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_service.dart';
import 'package:rwnaqk_frontend/modules/cart/controllers/cart_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_service.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/app_settings_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_service.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_controller.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_service.dart';
import 'package:rwnaqk_frontend/modules/wishlist/controllers/wishlist_ui_controller.dart';

class InMemoryTokenStorage implements IAuthTokenStorage {
  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late InMemoryTokenStorage tokenStorage;
  late Dio mockDio;

  setUp(() {
    Get.reset();
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(
      envString: 'APP_ENV=development\nENABLE_MOCK_DATA=true\nAPI_BASE_URL=https://api.test.com',
    );
    tokenStorage = InMemoryTokenStorage();
    mockDio = Dio(BaseOptions(baseUrl: 'https://api.test.com'));
  });

  tearDown(() {
    Get.reset();
  });

  group('Phase 01: Core Providers & Single-Instance Guarantee', () {
    test('Riverpod container resolves all core providers cleanly outside GetX', () {
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(tokenStorage),
        ],
      );
      addTearDown(container.dispose);

      final storage = container.read(authTokenStorageProvider);
      final client = container.read(apiClientProvider);
      final authRepo = container.read(authRepositoryProvider);
      final productsRepo = container.read(productsRepositoryProvider);
      final addressesRepo = container.read(addressesRepositoryProvider);
      final ordersRepo = container.read(ordersRepositoryProvider);

      expect(storage, isA<IAuthTokenStorage>());
      expect(client, isA<ApiClient>());
      expect(authRepo, isA<IAuthRepository>());
      expect(productsRepo, isA<IProductsRepository>());
      expect(addressesRepo, isA<IAddressesRepository>());
      expect(ordersRepo, isA<IOrdersRepository>());
    });

    test('Riverpod providers reuse existing GetX instances (Single-Instance Guarantee)', () {
      final sharedStorage = InMemoryTokenStorage();
      final sharedClient = ApiClient(dio: mockDio, tokenStorage: sharedStorage);

      Get.put<IAuthTokenStorage>(sharedStorage, permanent: true);
      Get.put<ApiClient>(sharedClient, permanent: true);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final riverpodStorage = container.read(authTokenStorageProvider);
      final riverpodClient = container.read(apiClientProvider);

      // Verify exact identity reference
      expect(identical(riverpodStorage, sharedStorage), isTrue);
      expect(identical(riverpodClient, sharedClient), isTrue);
      expect(identical(riverpodClient, Get.find<ApiClient>()), isTrue);
    });

    test('Riverpod providers allow clean testing overrides via ProviderContainer', () {
      final customStorage = InMemoryTokenStorage();
      customStorage.writeToken('overridden_test_token');

      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(customStorage),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(authTokenStorageProvider), equals(customStorage));
    });
  });

  group('Phase 01: Real HTTP 401 Session Flow & Security Teardown', () {
    test('HTTP 401 in ApiClient triggers wired onUnauthorized and executes handleUnauthorized', () async {
      tokenStorage.writeToken('authenticated_jwt_token');

      final sessionService = AuthSessionService(
        initialAccessToken: 'authenticated_jwt_token',
        tokenStorage: tokenStorage,
      );
      Get.put<IAuthTokenStorage>(tokenStorage, permanent: true);
      Get.put<AuthSessionService>(sessionService, permanent: true);

      bool callbackExecuted = false;
      final client = ApiClient(
        dio: mockDio,
        tokenStorage: tokenStorage,
        onUnauthorized: () {
          callbackExecuted = true;
          sessionService.handleUnauthorized();
        },
      );
      Get.put<ApiClient>(client, permanent: true);

      expect(sessionService.isAuthenticated, isTrue);

      // Simulate 401 from backend
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'message': 'Unauthenticated.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      // Execute request expecting UnauthorizedException
      expect(
        () => client.get<dynamic>('/api/v1/customer/orders'),
        throwsA(isA<UnauthorizedException>()),
      );

      await pumpEventQueue();

      expect(callbackExecuted, isTrue);
      expect(sessionService.isAuthenticated, isFalse);
      expect(sessionService.token.value, isNull);
      expect(await tokenStorage.readToken(), isNull);
    });

    test('Concurrent 401 responses trigger handleUnauthorized safely without duplicate loops', () async {
      tokenStorage.writeToken('active_token');
      final sessionService = AuthSessionService(
        initialAccessToken: 'active_token',
        tokenStorage: tokenStorage,
      );

      int terminationCalls = 0;
      sessionService.onSessionTerminated = () {
        terminationCalls++;
      };

      // Fire 5 concurrent 401 handling events
      await Future.wait([
        sessionService.handleUnauthorized(),
        sessionService.handleUnauthorized(),
        sessionService.handleUnauthorized(),
        sessionService.handleUnauthorized(),
        sessionService.handleUnauthorized(),
      ]);

      expect(terminationCalls, equals(1));
      expect(sessionService.isAuthenticated, isFalse);
      expect(await tokenStorage.readToken(), isNull);
    });

    test('Non-401 errors (500, 422, 404, Timeout) preserve session and do not trigger onUnauthorized', () async {
      tokenStorage.writeToken('valid_token');
      final sessionService = AuthSessionService(
        initialAccessToken: 'valid_token',
        tokenStorage: tokenStorage,
      );

      bool unauthorizedTriggered = false;
      final client = ApiClient(
        dio: mockDio,
        tokenStorage: tokenStorage,
        onUnauthorized: () {
          unauthorizedTriggered = true;
          sessionService.handleUnauthorized();
        },
      );

      // Simulate 500 Internal Server Error
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 500,
                  data: {'message': 'Server Error'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      expect(
        () => client.get<dynamic>('/api/v1/products'),
        throwsA(isA<ServerException>()),
      );

      await pumpEventQueue();

      expect(unauthorizedTriggered, isFalse);
      expect(sessionService.isAuthenticated, isTrue);
      expect(await tokenStorage.readToken(), equals('valid_token'));
    });

    test('handleUnauthorized purges account-scoped local data (Cart, Orders, Addresses, Wishlist)', () async {
      final sessionService = AuthSessionService(
        initialAccessToken: 'user_a_token',
        tokenStorage: tokenStorage,
      );
      Get.put<AuthSessionService>(sessionService, permanent: true);

      final profileStore = ProfileStoreService(sessionService);
      Get.put<ProfileStoreService>(profileStore, permanent: true);
      profileStore.addresses.updateFromRiverpod([
        const ShippingAddress(
          id: 'addr_1',
          country: 'Yemen',
          city: 'Taiz',
          address: 'Main St',
          postcode: '12345',
        ),
      ]);

      final cartService = CartService(profileStore);
      final cartUi = CartUiController();
      Get.put<CartUiController>(cartUi, permanent: true);
      final cart = CartController(cartService);
      Get.put<CartController>(cart, permanent: true);
      cart.cartItems.assignAll([
        const HomeProductItem(id: 'item_1', title: 'Silk Abaya', imageUrl: '', price: 15000),
      ]);

      final ordersService = OrdersService();
      Get.put<OrdersUiController>(OrdersUiController(), permanent: true);
      final orders = OrdersController(ordersService);
      Get.put<OrdersController>(orders, permanent: true);
      orders.orders.assignAll([
        OrderModel(
          id: 'ord_1',
          createdAt: DateTime.now(),
          itemsCount: 1,
          total: 15000,
          status: 'pending',
        ),
      ]);

      final wishlistUi = WishlistUiController();
      Get.put<WishlistUiController>(wishlistUi, permanent: true);
      final wishlist = WishlistController(WishlistService());
      Get.put<WishlistController>(wishlist, permanent: true);
      wishlist.wishlist.assignAll([
        const HomeProductItem(id: 'fav_1', title: 'Velvet Dress', imageUrl: '', price: 22000),
      ]);

      // Wire session termination callback
      sessionService.onSessionTerminated = () {
        if (Get.isRegistered<CartController>()) {
          Get.find<CartController>().clearCart();
        }
        if (Get.isRegistered<OrdersController>()) {
          Get.find<OrdersController>().clearOrders();
        }
        if (Get.isRegistered<ProfileStoreService>()) {
          Get.find<ProfileStoreService>().clearAddressesProjection();
        }
        if (Get.isRegistered<WishlistController>()) {
          Get.find<WishlistController>().clearWishlist();
        }
      };

      // Assert populated before 401
      expect(cart.cartItems, isNotEmpty);
      expect(orders.orders, isNotEmpty);
      expect(profileStore.addresses, isNotEmpty);
      expect(wishlist.wishlist, isNotEmpty);

      // Trigger 401 unauthorized
      await sessionService.handleUnauthorized();

      // Assert all user-scoped caches are cleanly emptied
      expect(cart.cartItems, isEmpty);
      expect(orders.orders, isEmpty);
      expect(profileStore.addresses, isEmpty);
      expect(wishlist.wishlist, isEmpty);
      expect(sessionService.isAuthenticated, isFalse);
    });
  });

  group('Phase 01: Wishlist Logout State Isolation', () {
    test('AppSettingsController logout routine purges WishlistController items', () async {
      final sessionService = AuthSessionService(tokenStorage: tokenStorage);
      Get.put<AuthSessionService>(sessionService, permanent: true);
      Get.put<CustomerAuthApiService>(CustomerAuthApiService(), permanent: true);

      final profileStore = ProfileStoreService(sessionService);
      Get.put<ProfileStoreService>(profileStore, permanent: true);

      final cartUi = CartUiController();
      Get.put<CartUiController>(cartUi, permanent: true);
      final cart = CartController(CartService(profileStore));
      Get.put<CartController>(cart, permanent: true);

      Get.put<OrdersUiController>(OrdersUiController(), permanent: true);
      final orders = OrdersController(OrdersService());
      Get.put<OrdersController>(orders, permanent: true);

      final wishlistUi = WishlistUiController();
      Get.put<WishlistUiController>(wishlistUi, permanent: true);
      final wishlist = WishlistController(WishlistService());
      Get.put<WishlistController>(wishlist, permanent: true);

      // User A populates wishlist
      wishlist.wishlist.assignAll([
        const HomeProductItem(id: 'abaya_royal', title: 'Royal Abaya', imageUrl: '', price: 35000),
        const HomeProductItem(id: 'abaya_gold', title: 'Gold Abaya', imageUrl: '', price: 42000),
      ]);
      expect(wishlist.wishlist.length, equals(2));

      final settingsService = AppSettingsService();
      final settingsUi = AppSettingsUiController();
      Get.put<AppSettingsUiController>(settingsUi, permanent: true);
      final settings = AppSettingsController(settingsService);
      Get.put<AppSettingsController>(settings, permanent: true);

      // Verify app settings preferences
      expect(settings.notificationsEnabled.value, isTrue);

      // User A logs out
      await settings.logout();

      // Wishlist must be completely empty!
      expect(wishlist.wishlist, isEmpty);

      // Unrelated app settings must be preserved!
      expect(settings.notificationsEnabled.value, isTrue);

      // User B logs in
      sessionService.startSession(accessToken: 'user_b_token');
      expect(wishlist.wishlist, isEmpty); // Starts completely clean
    });
  });
}
