import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/forgot_password_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/register_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository_impl.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/repositories/wishlist_repository.dart';
import 'package:rwnaqk_frontend/modules/wishlist/data/wishlist_local_cache.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Mocks and Stubs ---

class TrackingOrdersRepository implements IOrdersRepository {
  int createOrderCallCount = 0;
  final List<OrderModel> orders = [];

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    createOrderCallCount++;
    orders.add(order);
    return order;
  }

  @override
  Future<List<OrderModel>> getOrders() async => orders;

  @override
  Future<OrderModel?> getOrderById(String orderId) async =>
      orders.where((o) => o.id == orderId).firstOrNull;

  @override
  Future<OrderDetailsModel> getOrderDetails(OrderModel order) async =>
      throw UnimplementedError();

  @override
  Future<OrderModel> submitCheckout({
    required int addressId,
    required List<Map<String, dynamic>> items,
    required String paymentMethod,
    String? couponCode,
    String? shippingOptionId,
    double? expectedGrandTotal,
    Map<String, dynamic>? walletAccount,
    String? receiptImageUrl,
    String? notes,
    String? idempotencyKey,
  }) async =>
      throw UnimplementedError();

  @override
  Future<OrderModel> cancelOrder(String orderId) async =>
      throw UnimplementedError();

  @override
  Future<void> clearLocalCache() async => orders.clear();
}

class WishlistRepoFailingStub implements IWishlistRepository {
  bool shouldThrow = true;
  List<String> serverIds = [];

  @override
  Future<List<String>> getWishlistIds() async {
    if (shouldThrow) {
      throw const NetworkException(message: 'Connection timed out');
    }
    return serverIds;
  }

  @override
  Future<List<HomeProductItem>> getWishlist() async => [];
  @override
  Future<bool> toggleWishlist(String productId) async => true;
  @override
  Future<void> addToWishlist(String productId) async {}
  @override
  Future<void> removeFromWishlist(String productId) async {}
  @override
  Future<List<HomeProductItem>> syncWishlist(List<String> productIds) async => [];
}

class FakeAuthRepositoryStub implements IAuthRepository {
  CustomerModel? meResult;
  bool meShouldThrow = false;
  Exception? meException;
  CustomerModel? loginCustomerPayload;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
    String? deviceName,
  }) async {
    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: false,
      requiresEmailVerification: false,
      token: 'jwt_valid_token_123',
      customer: loginCustomerPayload,
    );
  }

  @override
  Future<LoginResult> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String country,
    required String governorate,
    required String password,
    required String passwordConfirmation,
    required bool termsAccepted,
    required bool privacyPolicyAccepted,
    String? gender,
    String? deviceName,
  }) async {
    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: false,
      requiresEmailVerification: false,
      token: 'jwt_valid_token_123',
      customer: loginCustomerPayload,
    );
  }

  @override
  Future<CustomerModel> me() async {
    if (meShouldThrow) {
      throw meException ?? const NetworkException(message: 'Failed to fetch me');
    }
    return meResult ??
        const CustomerModel(
          id: 42,
          firstName: 'سارة',
          lastName: 'أحمد',
          fullName: 'سارة أحمد',
          email: 'sara@example.com',
          mobile: '777111222',
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  group('Problem 1: Orders Creation (addOrder does not trigger duplicate creation)', () {
    test('addOrder updates local state without calling _repo.createOrder', () async {
      final mockRepo = TrackingOrdersRepository();
      final container = ProviderContainer(
        overrides: [
          ordersRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(ordersProvider.notifier);

      final testOrder = OrderModel(
        id: 'ORD-999',
        createdAt: DateTime.now(),
        total: 15000.0,
        itemsCount: 2,
        status: 'pending',
      );

      // Invoke addOrder
      notifier.addOrder(testOrder);

      // 1. Local state must be updated
      final state = container.read(ordersProvider);
      expect(state.orders.length, equals(1));
      expect(state.orders.first.id, equals('ORD-999'));
      expect(state.status, equals(OrdersStatus.loaded));
      expect(state.filter, equals(OrdersFilter.all));

      // 2. CRITICAL: _repo.createOrder must NOT be called
      expect(mockRepo.createOrderCallCount, equals(0));
    });
  });

  group('Problem 2: Wishlist Cache Protection on Network Failure', () {
    test('Network failure in getWishlistIds does not clear cached favorite IDs', () async {
      SharedPreferences.setMockInitialValues({
        'cached_wishlist_ids': ['101', '102', '103'],
        'cached_wishlist_count': 3,
      });
      final prefs = await SharedPreferences.getInstance();

      final stubRepo = WishlistRepoFailingStub()..shouldThrow = true;
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          wishlistRepositoryProvider.overrideWithValue(stubRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);

      // Initial state contains 3 cached items
      expect(container.read(wishlistProvider).favoriteIds, containsAll(['101', '102', '103']));

      // Attempt to refresh favorite IDs from network (which throws NetworkException)
      await notifier.refreshFavoriteIds(force: true);

      // 1. In-memory state must NOT be wiped
      final stateAfterError = container.read(wishlistProvider);
      expect(stateAfterError.favoriteIds, containsAll(['101', '102', '103']));
      expect(stateAfterError.itemCount, equals(3));

      // 2. On-disk cache must NOT be wiped
      final cachedOnDisk = WishlistLocalCache.getCachedIdsSync(prefs);
      expect(cachedOnDisk, containsAll(['101', '102', '103']));
    });

    test('Successful empty response from server updates state and cache normally', () async {
      SharedPreferences.setMockInitialValues({
        'cached_wishlist_ids': ['101', '102'],
        'cached_wishlist_count': 2,
      });
      final prefs = await SharedPreferences.getInstance();

      final stubRepo = WishlistRepoFailingStub()
        ..shouldThrow = false
        ..serverIds = [];

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          wishlistRepositoryProvider.overrideWithValue(stubRepo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(wishlistProvider.notifier);

      // Refresh with confirmed empty server list
      await notifier.refreshFavoriteIds(force: true);
      // Wait for unawaited cache persistence
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // State and cache should legitimately reflect the empty server list
      final stateAfterSuccess = container.read(wishlistProvider);
      expect(stateAfterSuccess.favoriteIds, isEmpty);
      expect(stateAfterSuccess.itemCount, equals(0));

      final cachedOnDisk = WishlistLocalCache.getCachedIdsSync(prefs);
      expect(cachedOnDisk, isEmpty);
    });
  });

  group('Problem 3: Orders Mock Fallback Release Protection', () {
    test('OrdersRepositoryImpl.getOrderDetails rethrows error when mock data is disabled', () async {
      final dio = Dio();
      // Using an invalid base URL to force a DioException
      final apiClient = ApiClient(dio: dio, baseUrl: 'http://invalid.invalid');
      final repo = OrdersRepositoryImpl(apiClient: apiClient);

      final testOrder = OrderModel(
        id: 'REAL-ORDER-123',
        createdAt: DateTime.now(),
        total: 50000,
        itemsCount: 1,
        status: 'pending',
      );

      // When mock data is disabled, API failure must throw/rethrow rather than returning fake order details
      expect(
        () async => await repo.getOrderDetails(testOrder),
        throwsA(anything),
      );
    });
  });

  group('Problem 4: Authentication Session Zombie Session Protection', () {
    test('Login with customer payload in response starts complete session', () async {
      final authRepo = FakeAuthRepositoryStub()
        ..loginCustomerPayload = const CustomerModel(
          id: 10,
          firstName: 'نورة',
          lastName: 'العمري',
          fullName: 'نورة العمري',
          email: 'noura@test.com',
          mobile: '777333444',
        );

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(authRepo, sessionNotifier);

      final result = await loginService.login(email: 'noura@test.com', password: 'password123');

      expect(result.isSuccess, isTrue);
      final session = container.read(authSessionProvider);
      expect(session.isAuthenticated, isTrue);
      expect(session.customer?.fullName, equals('نورة العمري'));
      expect(session.customer?.id, equals(10));
    });

    test('Login without customer payload recovers customer via me()', () async {
      final authRepo = FakeAuthRepositoryStub()
        ..loginCustomerPayload = null
        ..meResult = CustomerModel(
          id: 55,
          firstName: 'فهد',
          lastName: 'صالح',
          fullName: 'فهد صالح',
          email: 'fahd@test.com',
          mobile: '777888999',
          emailVerifiedAt: DateTime(2025, 1, 1),
        );

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(authRepo, sessionNotifier);

      final result = await loginService.login(email: 'fahd@test.com', password: 'password123');

      expect(result.isSuccess, isTrue);
      final session = container.read(authSessionProvider);
      expect(session.isAuthenticated, isTrue);
      expect(session.customer?.id, equals(55));
      expect(session.customer?.fullName, equals('فهد صالح'));
    });

    test('Login without customer payload and me() failure fails closed and clears session', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final authRepo = FakeAuthRepositoryStub()
        ..loginCustomerPayload = null
        ..meShouldThrow = true
        ..meException = const NetworkException(message: 'Timeout on me()');

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);
      final loginService = LoginService(authRepo, sessionNotifier);

      // FIX-03 Hardening: Fail-Closed. Login without customer must not create phantom session on me() failure.
      final result = await loginService.login(email: 'user@test.com', password: 'password123');
      expect(result.isSuccess, isFalse);

      final session = container.read(authSessionProvider);
      expect(session.isAuthenticated, isFalse);
      expect(session.token, isNull);
    });

    test('Register and ForgotPassword with me() failure handles session gracefully', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final authRepo = FakeAuthRepositoryStub()
        ..loginCustomerPayload = null
        ..meShouldThrow = true
        ..meException = const NetworkException(message: 'Network error');

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);
      final geoService = GeoLookupApiService(
        dio: Dio(),
      );
      final registerService = RegisterService(authRepo, sessionNotifier, geoService);
      final forgotService = ForgotPasswordService(authRepo, sessionNotifier);

      // Register test
      final regResult = await registerService.register(
        firstName: 'أحمد',
        lastName: 'سعيد',
        phone: '777000111',
        email: 'ahmed@test.com',
        country: 'YE',
        governorate: 'Sanaa',
        password: 'Password@123',
        passwordConfirmation: 'Password@123',
        termsAccepted: true,
        privacyPolicyAccepted: true,
      );
      expect(regResult.isBanned, isFalse);

      // Forgot password OTP test
      final otpResult = await forgotService.verifyTwoFactorLogin(
        email: 'ahmed@test.com',
        password: 'Password@123',
        code: '123456',
      );
      expect(otpResult.success, isTrue);
    });
  });
}
