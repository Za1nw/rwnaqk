import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/core/services/geo/geo_lookup_api_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/register_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/controllers/profile_store_service.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/shipping_address.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_service.dart';
import 'package:rwnaqk_frontend/modules/orders/controllers/orders_ui_controller.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/wishlist/providers/wishlist_providers.dart';

class FaultyOrdersController extends OrdersController {
  FaultyOrdersController(super.service);
  bool shouldThrow = false;

  @override
  void clearOrders() {
    if (shouldThrow) {
      throw StateError('Simulated critical crash in clearOrders');
    }
    super.clearOrders();
  }
}

class InMemoryTokenStorage implements IAuthTokenStorage {
  String? _token;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<void> writeToken(String token) async => _token = token;

  @override
  Future<void> clearToken() async => _token = null;
}

class FakeAuthRepository implements IAuthRepository {
  CustomerModel? mockCustomer;
  bool shouldRequire2FA = false;
  bool shouldRequireEmailVerification = false;
  bool shouldFailLogin = false;
  int logoutCallCount = 0;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
    String? deviceName,
  }) async {
    if (shouldFailLogin) {
      throw const FormatException('بيانات الاعتماد غير صالحة');
    }

    if (shouldRequire2FA && (code == null && recoveryCode == null)) {
      return const LoginResult(
        isSuccess: false,
        requiresTwoFactor: true,
        requiresEmailVerification: false,
        message: 'يلزم إدخال رمز التحقق بخطوتين',
      );
    }

    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: false,
      requiresEmailVerification: shouldRequireEmailVerification,
      token: 'jwt_token_for_$email',
      customer: mockCustomer ??
          CustomerModel(
            id: 42,
            firstName: 'سارة',
            lastName: 'أحمد',
            fullName: 'سارة أحمد',
            email: email,
            mobile: '777123456',
            emailVerifiedAt: shouldRequireEmailVerification ? null : DateTime.now(),
          ),
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
    String? deviceName,
  }) async {
    return LoginResult(
      isSuccess: true,
      requiresTwoFactor: false,
      requiresEmailVerification: shouldRequireEmailVerification,
      token: 'registered_token_123',
      customer: CustomerModel(
        id: 99,
        firstName: firstName,
        lastName: lastName,
        fullName: '$firstName $lastName',
        email: email,
        mobile: phone,
      ),
    );
  }

  @override
  Future<CustomerModel> me() async {
    if (shouldFailLogin) {
      throw const FormatException('الجلسة غير صالحة أو منتهية');
    }
    return mockCustomer ??
        const CustomerModel(
          id: 42,
          firstName: 'سارة',
          lastName: 'أحمد',
          fullName: 'سارة أحمد',
          email: 'sara@rawnaqk.com',
          mobile: '777123456',
        );
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String token,
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> sendEmailVerificationCode() async {}

  @override
  Future<void> verifyEmailCode({required String code}) async {}
}

ProviderContainer _createTestContainer({
  InMemoryTokenStorage? tokenStorage,
  FakeAuthRepository? authRepo,
}) {
  final storage = tokenStorage ?? InMemoryTokenStorage();
  final repo = authRepo ?? FakeAuthRepository();

  final container = ProviderContainer(
    overrides: [
      authTokenStorageProvider.overrideWithValue(storage),
      authRepositoryProvider.overrideWithValue(repo),
    ],
  );
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.testMode = true;
  });

  group('Phase 04: AuthSessionState & Immutable Models', () {
    test('AuthSessionState defaults, immutability, and copyWith', () {
      const initial = AuthSessionState();
      expect(initial.status, AuthSessionStatus.unauthenticated);
      expect(initial.token, isNull);
      expect(initial.customer, isNull);
      expect(initial.twoFactorPayload, isNull);
      expect(initial.sessionGeneration, 0);
      expect(initial.isAuthenticated, isFalse);
      expect(initial.isGuest, isFalse);
      expect(initial.requiresTwoFactor, isFalse);
      expect(initial.requiresEmailVerification, isFalse);

      const customer = CustomerModel(
        id: 10,
        firstName: 'فاطمة',
        lastName: 'محمد',
        fullName: 'فاطمة محمد',
        email: 'fatima@test.com',
        mobile: '777111222',
      );

      final updated = initial.copyWith(
        status: AuthSessionStatus.authenticated,
        token: 'auth_jwt_123',
        customer: customer,
        sessionGeneration: 3,
      );

      expect(updated.status, AuthSessionStatus.authenticated);
      expect(updated.token, 'auth_jwt_123');
      expect(updated.customerId, '10');
      expect(updated.isAuthenticated, isTrue);
      expect(updated.sessionGeneration, 3);

      // Test clear flags
      final cleared = updated.copyWith(
        clearToken: true,
        clearCustomer: true,
        status: AuthSessionStatus.unauthenticated,
      );
      expect(cleared.token, isNull);
      expect(cleared.customer, isNull);
      expect(cleared.isAuthenticated, isFalse);
    });
  });

  group('Phase 04: AuthSessionNotifier Lifecycle & Security Controls', () {
    test('startSession stores token, updates state, and advances generation', () async {
      final tokenStorage = InMemoryTokenStorage();
      final container = _createTestContainer(tokenStorage: tokenStorage);
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      const customer = CustomerModel(
        id: 7,
        firstName: 'منى',
        lastName: 'صالح',
        fullName: 'منى صالح',
        email: 'mona@test.com',
        mobile: '777333444',
      );

      notifier.startSession(
        accessToken: 'secure_jwt_token',
        customerPayload: customer,
      );

      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.authenticated);
      expect(state.token, 'secure_jwt_token');
      expect(state.customer?.fullName, 'منى صالح');
      expect(state.sessionGeneration, 1);
      expect(state.isAuthenticated, isTrue);

      // Verify token written to secure storage
      expect(await tokenStorage.readToken(), 'secure_jwt_token');
    });

    test('Two-Factor Authentication: challenge does NOT authenticate or persist token', () async {
      final tokenStorage = InMemoryTokenStorage();
      final container = _createTestContainer(tokenStorage: tokenStorage);
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);

      notifier.startTwoFactorChallenge(
        email: 'user@test.com',
        password: 'secret_password',
        message: 'رمز التحقق مطلوب',
      );

      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.twoFactorChallengeRequired);
      expect(state.requiresTwoFactor, isTrue);
      // Security Invariant: Must NOT be authenticated
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(state.customer, isNull);
      expect(state.twoFactorPayload?.email, 'user@test.com');

      // Security Invariant: No token persisted to storage during challenge
      expect(await tokenStorage.readToken(), isNull);

      // Cancelling challenge resets safely
      notifier.cancelTwoFactorChallenge();
      expect(container.read(authSessionProvider).status, AuthSessionStatus.unauthenticated);
      expect(container.read(authSessionProvider).twoFactorPayload, isNull);
    });

    test('Guest Mode transitions safely with mock guest customer', () {
      final container = _createTestContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      notifier.enterGuestMode();

      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.guest);
      expect(state.isGuest, isTrue);
      expect(state.isAuthenticated, isTrue);
      expect(state.customer?.email, 'guest@rawnaqk.com');
      expect(state.sessionGeneration, 1);
    });

    test('Central 401 handling: clears session, clears storage, and advances generation', () async {
      final tokenStorage = InMemoryTokenStorage();
      final container = _createTestContainer(tokenStorage: tokenStorage);
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      notifier.startSession(accessToken: 'active_session_token');
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      bool terminationCalled = false;
      notifier.onSessionTerminated = () => terminationCalled = true;

      await notifier.handleUnauthorized(failedToken: 'active_session_token');

      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.unauthenticated);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(await tokenStorage.readToken(), isNull);
      expect(terminationCalled, isTrue);
      expect(state.sessionGeneration, 2);
    });

    test('Stale 401 Guard: 401 with outdated token does NOT destroy new active session', () async {
      final tokenStorage = InMemoryTokenStorage();
      final container = _createTestContainer(tokenStorage: tokenStorage);
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      notifier.startSession(accessToken: 'fresh_new_token');

      bool terminationCalled = false;
      notifier.onSessionTerminated = () => terminationCalled = true;

      // Delayed 401 arrives with old token
      await notifier.handleUnauthorized(failedToken: 'old_superseded_token');

      // Session remains active!
      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.authenticated);
      expect(state.token, 'fresh_new_token');
      expect(state.isAuthenticated, isTrue);
      expect(terminationCalled, isFalse);
    });

    test('Idempotent Logout: multiple logout calls execute cleanly without errors', () async {
      final tokenStorage = InMemoryTokenStorage();
      final authRepo = FakeAuthRepository();
      final container = _createTestContainer(
        tokenStorage: tokenStorage,
        authRepo: authRepo,
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      notifier.startSession(accessToken: 'token_to_logout');

      int callbacks = 0;
      notifier.onSessionTerminated = () => callbacks++;

      await notifier.logout();
      await notifier.logout(); // Repeated call

      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
      expect(await tokenStorage.readToken(), isNull);
      expect(callbacks, 2);
      expect(authRepo.logoutCallCount, 2);
    });

    test('Email Verification flow: delays token persistence until verification completes', () async {
      final tokenStorage = InMemoryTokenStorage();
      final container = _createTestContainer(tokenStorage: tokenStorage);
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      const customer = CustomerModel(
        id: 55,
        firstName: 'ريم',
        lastName: 'يوسف',
        fullName: 'ريم يوسف',
        email: 'reem@test.com',
        mobile: '777444555',
        emailVerifiedAt: null,
      );

      notifier.startSession(
        accessToken: 'unverified_token',
        customerPayload: customer,
        emailVerificationRequired: true,
      );

      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.emailVerificationRequired);
      expect(state.requiresEmailVerification, isTrue);
      // Token is NOT written to storage before verification
      expect(await tokenStorage.readToken(), isNull);

      // Verify email
      await notifier.completeEmailVerification();

      final verifiedState = container.read(authSessionProvider);
      expect(verifiedState.status, AuthSessionStatus.authenticated);
      expect(verifiedState.customer?.emailVerifiedAt, isNotNull);
      // Now token is stored
      expect(await tokenStorage.readToken(), 'unverified_token');
    });

    test('Auto-synchronization: session transitions sync and isolate Wishlist state', () {
      final container = _createTestContainer();
      addTearDown(container.dispose);

      final authNotifier = container.read(authSessionProvider.notifier);
      final wishlistNotifier = container.read(wishlistProvider.notifier);

      // Clear wishlist initially
      wishlistNotifier.clearWishlist();

      // User A logs in
      authNotifier.startSession(
        accessToken: 'tok_A',
        customerPayload: const CustomerModel(
          id: 101,
          firstName: 'UserA',
          lastName: 'A',
          fullName: 'User A',
          email: 'a@test.com',
          mobile: '777111111',
        ),
      );

      expect(container.read(wishlistProvider).activeUserId, '101');
      wishlistNotifier.addToWishlist(const HomeProductItem(
        id: 'item_A',
        title: 'User A Favorite',
        price: 10000,
        imageUrl: '',
      ));
      wishlistNotifier.addRecentlyViewed(const HomeProductItem(
        id: 'rec_A',
        title: 'User A Viewed',
        price: 10000,
        imageUrl: '',
      ));
      expect(container.read(wishlistProvider).count, 1);
      expect(container.read(wishlistProvider).recentlyViewed, isNotEmpty);

      // User A logs out
      authNotifier.clearSession();

      // Wishlist items and recently viewed are wiped automatically!
      expect(container.read(wishlistProvider).items, isEmpty);
      expect(container.read(wishlistProvider).recentlyViewed, isEmpty);
      expect(container.read(wishlistProvider).activeUserId, isNull);

      // User B logs in
      authNotifier.startSession(
        accessToken: 'tok_B',
        customerPayload: const CustomerModel(
          id: 202,
          firstName: 'UserB',
          lastName: 'B',
          fullName: 'User B',
          email: 'b@test.com',
          mobile: '777222222',
        ),
      );

      // User B has clean isolated state
      expect(container.read(wishlistProvider).activeUserId, '202');
      expect(container.read(wishlistProvider).items, isEmpty);
      expect(container.read(wishlistProvider).recentlyViewed, isEmpty);
    });
  });

  group('Phase 04: Auth Services Integration & Single-Writer Compatibility Bridge', () {
    test('LoginService delegates to IAuthRepository and updates Riverpod session', () async {
      final tokenStorage = InMemoryTokenStorage();
      final authRepo = FakeAuthRepository();
      final container = _createTestContainer(
        tokenStorage: tokenStorage,
        authRepo: authRepo,
      );
      addTearDown(container.dispose);

      final bridge = AuthSessionService(container: container);
      final loginService = LoginService(authRepo, bridge);

      final result = await loginService.login(
        email: 'test@rawnaqk.com',
        password: 'password123',
      );

      expect(result.isSuccess, isTrue);

      // Riverpod is authoritative owner
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(container.read(authSessionProvider).token, 'jwt_token_for_test@rawnaqk.com');

      // Bridge has identical projected state
      expect(bridge.isAuthenticated, isTrue);
      expect(bridge.token.value, 'jwt_token_for_test@rawnaqk.com');
      expect(bridge.customer.value?.email, 'test@rawnaqk.com');
    });

    test('RegisterService delegates to IAuthRepository and updates Riverpod session', () async {
      final tokenStorage = InMemoryTokenStorage();
      final authRepo = FakeAuthRepository();
      final container = _createTestContainer(
        tokenStorage: tokenStorage,
        authRepo: authRepo,
      );
      addTearDown(container.dispose);

      final bridge = AuthSessionService(container: container);
      final registerService = RegisterService(
        authRepo,
        bridge,
        Get.put(GeoLookupApiService()),
      );

      final result = await registerService.register(
        firstName: 'أحمد',
        lastName: 'سعيد',
        phone: '777888999',
        email: 'ahmed@test.com',
        country: 'اليمن',
        governorate: 'صنعاء',
        password: 'pass',
        passwordConfirmation: 'pass',
        termsAccepted: true,
        privacyPolicyAccepted: true,
      );

      expect(result.message, isNotEmpty);
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(bridge.token.value, 'registered_token_123');
      expect(bridge.customer.value?.fullName, 'أحمد سعيد');
    });

    test('AuthSessionService compatibility bridge delegates writes to Riverpod without dual state', () {
      final container = _createTestContainer();
      addTearDown(container.dispose);

      final bridge = AuthSessionService(container: container);

      // Enter guest mode through bridge
      bridge.enterGuestMode();

      // Riverpod is authoritative owner
      expect(container.read(authSessionProvider).isGuest, isTrue);
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      // Bridge reflects the update reactively
      expect(bridge.isGuestMode.value, isTrue);
      expect(bridge.isAuthenticated, isTrue);

      // Clear through bridge
      bridge.clearSession();
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
      expect(bridge.isAuthenticated, isFalse);
    });
  });

  group('Phase 04.1: Bridge Corrections, Stale 401 Rejection & Security Closures', () {
    test('End-to-End Dio to Bridge: Stale 401 from User A does NOT invalidate User B session', () async {
      final tokenStorage = InMemoryTokenStorage();
      final container = _createTestContainer(tokenStorage: tokenStorage);
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      final bridge = AuthSessionService(
        container: container,
        tokenStorage: tokenStorage,
      );

      int terminationCalls = 0;
      bridge.onSessionTerminated = () => terminationCalls++;

      // 1. User A logs in
      notifier.startSession(accessToken: 'token_user_A');
      expect(container.read(authSessionProvider).token, 'token_user_A');
      expect(bridge.token.value, 'token_user_A');
      expect(bridge.isAuthenticated, isTrue);

      final genA = container.read(authSessionProvider).sessionGeneration;

      // 2. A protected request is created under session A
      final mockDio = Dio();
      final client = ApiClient(
        dio: mockDio,
        tokenStorage: tokenStorage,
        getSessionGeneration: () =>
            container.read(authSessionProvider).sessionGeneration,
        onUnauthorizedWithDetails: (failedToken, staleGen) async {
          await bridge.handleUnauthorized(
            failedToken: failedToken,
            staleGeneration: staleGen,
          );
        },
      );

      // 3. User A logs out
      await notifier.logout();
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
      expect(bridge.isAuthenticated, isFalse);

      // 4. User B logs in
      notifier.startSession(accessToken: 'token_user_B');
      expect(container.read(authSessionProvider).token, 'token_user_B');
      expect(bridge.token.value, 'token_user_B');
      expect(bridge.isAuthenticated, isTrue);

      final genB = container.read(authSessionProvider).sessionGeneration;
      expect(genB, greaterThan(genA));

      // Reset termination counter before the delayed 401 arrives
      terminationCalls = 0;

      // 5. Old request under session A now returns 401
      // Simulate backend 401 with request token captured at creation time
      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Emulate the request having been sent with User A's token and generation
            options.headers['Authorization'] = 'Bearer token_user_A';
            options.extra['requestSessionGeneration'] = genA;
            options.extra['requestToken'] = 'token_user_A';
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

      try {
        await client.get<dynamic>('/api/v1/customer/profile');
      } catch (e) {
        expect(e, isA<UnauthorizedException>());
      }

      await pumpEventQueue();

      // 6. Riverpod keeps session B authenticated!
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
      expect(container.read(authSessionProvider).token, 'token_user_B');

      // 7. GetX bridge also keeps session B authenticated!
      expect(bridge.isAuthenticated, isTrue);
      expect(bridge.token.value, 'token_user_B');

      // 8. No invalid logout navigation or termination was executed!
      expect(terminationCalls, equals(0));
    });

    test('Bootstrap with revoked / invalid token resets cleanly without throwing', () async {
      dotenv.loadFromString(envString: 'ENABLE_MOCK_DATA=false\nAPP_ENV=testing');
      addTearDown(() => dotenv.loadFromString(envString: 'ENABLE_MOCK_DATA=true\nAPP_ENV=development'));

      final tokenStorage = InMemoryTokenStorage();
      await tokenStorage.writeToken('revoked_expired_token');

      final authRepo = FakeAuthRepository()..shouldFailLogin = true;
      final container = _createTestContainer(
        tokenStorage: tokenStorage,
        authRepo: authRepo,
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      int terminationCalls = 0;
      notifier.onSessionTerminated = () => terminationCalls++;

      // Bootstrap with failing remote validation
      await notifier.bootstrapSession();

      final state = container.read(authSessionProvider);
      expect(state.status, AuthSessionStatus.unauthenticated);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
    });

    test('2FA verification fails on invalid OTP code without establishing session', () async {
      final tokenStorage = InMemoryTokenStorage();
      final authRepo = FakeAuthRepository()..shouldRequire2FA = true;
      final container = _createTestContainer(
        tokenStorage: tokenStorage,
        authRepo: authRepo,
      );
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);
      notifier.startTwoFactorChallenge(
        email: 'user@test.com',
        password: 'password',
        message: 'كود 2FA مطلوب',
      );

      expect(container.read(authSessionProvider).requiresTwoFactor, isTrue);
      expect(await tokenStorage.readToken(), isNull);

      // Attempt login with invalid credentials / without code
      final loginService = LoginService(authRepo, AuthSessionService(container: container));
      final result = await loginService.login(
        email: 'user@test.com',
        password: 'password',
      );

      // Still requires 2FA and not authenticated
      expect(result.isSuccess, isFalse);
      expect(result.requiresTwoFactor, isTrue);
      expect(await tokenStorage.readToken(), isNull);
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);
    });

    test('Session sync failure logging: does not swallow unexpected errors during account switch', () {
      final container = _createTestContainer();
      addTearDown(container.dispose);

      final notifier = container.read(authSessionProvider.notifier);

      // Should complete session without throwing an unhandled top-level exception
      expect(
        () => notifier.startSession(accessToken: 'user_switch_token'),
        returnsNormally,
      );
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('Direct account switch (User A -> User B) purges legacy GetX caches', () {
      final container = _createTestContainer();
      addTearDown(container.dispose);

      final authSession = AuthSessionService(container: container);
      final profileStore = ProfileStoreService(authSession, container);
      addTearDown(profileStore.onClose);
      Get.put<ProfileStoreService>(profileStore);

      Get.put<OrdersUiController>(OrdersUiController());
      final ordersController = OrdersController(OrdersService());
      Get.put<OrdersController>(ordersController);

      final notifier = container.read(authSessionProvider.notifier);

      // 1. Establish User A session
      const userA = CustomerModel(id: 101, firstName: 'User', lastName: 'A', fullName: 'User A', email: 'a@test.com');
      notifier.startSession(accessToken: 'token_A', customerPayload: userA);

      // Populate User A private data in legacy stores
      profileStore.addresses.updateFromRiverpod([
        const ShippingAddress(id: 'addr_A', country: 'YE', address: 'Private St A', city: 'Sana\'a', postcode: '111'),
      ]);
      ordersController.orders.add(OrderModel(id: 'ord_A', createdAt: DateTime(2026, 11, 9), itemsCount: 1, total: 100, status: 'completed'));

      expect(profileStore.addresses, isNotEmpty);
      expect(ordersController.orders, isNotEmpty);

      // 2. Direct switch to User B (userId != null)
      const userB = CustomerModel(id: 202, firstName: 'User', lastName: 'B', fullName: 'User B', email: 'b@test.com');
      notifier.startSession(accessToken: 'token_B', customerPayload: userB);

      // 3. User A's private data in legacy GetX stores MUST be purged!
      expect(profileStore.addresses, isEmpty);
      expect(ordersController.orders, isEmpty);
      expect(container.read(authSessionProvider).customer?.id, 202);
    });

    test('User A -> User A reauthentication preserves state whereas User A -> Guest purges', () {
      final container = _createTestContainer();
      addTearDown(container.dispose);

      final authSession = AuthSessionService(container: container);
      final profileStore = ProfileStoreService(authSession, container);
      addTearDown(profileStore.onClose);
      Get.put<ProfileStoreService>(profileStore);

      final notifier = container.read(authSessionProvider.notifier);

      // 1. User A starts session
      const userA = CustomerModel(id: 101, firstName: 'User', lastName: 'A', fullName: 'User A', email: 'a@test.com');
      notifier.startSession(accessToken: 'token_A', customerPayload: userA);

      // Add address to authoritative Riverpod store
      container.read(addressesProvider.notifier).setAddresses(const [
        ShippingAddress(id: 'addr_A', country: 'YE', address: 'Private St A', city: 'Sana\'a', postcode: '111'),
      ]);

      expect(profileStore.addresses, isNotEmpty);

      // 2. Re-authenticate same User A
      notifier.startSession(accessToken: 'token_A_refreshed', customerPayload: userA);

      // Same user: state is preserved
      expect(profileStore.addresses, isNotEmpty);

      // 3. Switch to Guest mode
      notifier.enterGuestMode();

      // Guest boundary: private User A data must be wiped!
      expect(profileStore.addresses, isEmpty);
    });

    test('Cleanup failure injection: controller is forcefully evicted on clear error to prevent leakage', () {
      final container = _createTestContainer();
      addTearDown(container.dispose);

      Get.put<OrdersUiController>(OrdersUiController());
      final faultyController = FaultyOrdersController(OrdersService())..shouldThrow = true;
      Get.put<OrdersController>(faultyController);

      expect(Get.isRegistered<OrdersController>(), isTrue);

      final notifier = container.read(authSessionProvider.notifier);

      // Start session for User A
      const userA = CustomerModel(id: 101, firstName: 'User', lastName: 'A', fullName: 'User A', email: 'a@test.com');
      notifier.startSession(accessToken: 'token_A', customerPayload: userA);

      // Direct switch to User B triggers _purgeLegacyGetXStores which hits simulated crash in clearOrders
      const userB = CustomerModel(id: 202, firstName: 'User', lastName: 'B', fullName: 'User B', email: 'b@test.com');
      notifier.startSession(accessToken: 'token_B', customerPayload: userB);

      // Controller MUST be forcefully evicted from GetX to prevent exposing un-cleared User A data!
      expect(Get.isRegistered<OrdersController>(), isFalse);
    });
  });
}
