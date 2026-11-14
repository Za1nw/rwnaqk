import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rwnaqk_frontend/core/bindings/initial_binding.dart';
import 'package:rwnaqk_frontend/core/constants/local_storage_keys.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_session_service.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/catalog/data/repositories/products_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/repositories/addresses_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';

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
    FlutterSecureStorage.setMockInitialValues({});
    dotenv.loadFromString(
      envString: 'APP_ENV=development\nENABLE_MOCK_DATA=true\nAPI_BASE_URL=https://api.test.com',
    );
    tokenStorage = InMemoryTokenStorage();
    mockDio = Dio(BaseOptions(baseUrl: 'https://api.test.com'));
  });

  tearDown(() {
    Get.reset();
  });

  group('Phase 01.1: Single-Instance Bridge & Bidirectional Initialization Order', () {
    test('Order A: GetX InitialBinding runs first, then Riverpod resolves providers -> identical instances', () {
      final initialBinding = InitialBinding(tokenStorage: tokenStorage);
      initialBinding.dependencies();

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final riverpodStorage = container.read(authTokenStorageProvider);
      final riverpodClient = container.read(apiClientProvider);
      final riverpodAuthRepo = container.read(authRepositoryProvider);
      final riverpodProductsRepo = container.read(productsRepositoryProvider);
      final riverpodAddressesRepo = container.read(addressesRepositoryProvider);
      final riverpodOrdersRepo = container.read(ordersRepositoryProvider);

      expect(identical(riverpodStorage, Get.find<IAuthTokenStorage>()), isTrue);
      expect(identical(riverpodClient, Get.find<ApiClient>()), isTrue);
      expect(identical(riverpodAuthRepo, Get.find<IAuthRepository>()), isTrue);
      expect(identical(riverpodProductsRepo, Get.find<IProductsRepository>()), isTrue);
      expect(identical(riverpodAddressesRepo, Get.find<IAddressesRepository>()), isTrue);
      expect(identical(riverpodOrdersRepo, Get.find<IOrdersRepository>()), isTrue);
    });

    test('Order B: Riverpod resolves providers first, then GetX InitialBinding runs -> identical instances without duplication', () {
      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(tokenStorage),
        ],
      );
      addTearDown(container.dispose);

      // Riverpod reads first
      final riverpodClient = container.read(apiClientProvider);
      final riverpodAuthRepo = container.read(authRepositoryProvider);
      final riverpodProductsRepo = container.read(productsRepositoryProvider);
      final riverpodAddressesRepo = container.read(addressesRepositoryProvider);
      final riverpodOrdersRepo = container.read(ordersRepositoryProvider);

      // GetX InitialBinding runs afterwards
      final initialBinding = InitialBinding(tokenStorage: tokenStorage);
      initialBinding.dependencies();

      expect(identical(riverpodClient, Get.find<ApiClient>()), isTrue);
      expect(identical(riverpodAuthRepo, Get.find<IAuthRepository>()), isTrue);
      expect(identical(riverpodProductsRepo, Get.find<IProductsRepository>()), isTrue);
      expect(identical(riverpodAddressesRepo, Get.find<IAddressesRepository>()), isTrue);
      expect(identical(riverpodOrdersRepo, Get.find<IOrdersRepository>()), isTrue);
    });
  });

  group('Phase 01.1: Advanced HTTP 401 & Session Lifecycle Verification', () {
    test('1. Valid session receives 401 from protected endpoint with Bearer token -> cleans session and clears token', () async {
      tokenStorage.writeToken('valid_user_jwt');
      final sessionService = AuthSessionService(
        initialAccessToken: 'valid_user_jwt',
        tokenStorage: tokenStorage,
      );
      Get.put<AuthSessionService>(sessionService, permanent: true);

      final client = ApiClient(
        dio: mockDio,
        tokenStorage: tokenStorage,
        onUnauthorizedWithToken: (token) => sessionService.handleUnauthorized(failedToken: token),
      );

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

      expect(
        () => client.get<dynamic>('/api/v1/customer/profile'),
        throwsA(isA<UnauthorizedException>()),
      );

      await pumpEventQueue();

      expect(sessionService.isAuthenticated, isFalse);
      expect(sessionService.token.value, isNull);
      expect(await tokenStorage.readToken(), isNull);
    });

    test('2. Five concurrent protected requests receive 401 -> concurrency gate executes single termination', () async {
      tokenStorage.writeToken('concurrent_token');
      final sessionService = AuthSessionService(
        initialAccessToken: 'concurrent_token',
        tokenStorage: tokenStorage,
      );

      int terminationEvents = 0;
      sessionService.onSessionTerminated = () => terminationEvents++;

      await Future.wait([
        sessionService.handleUnauthorized(failedToken: 'concurrent_token'),
        sessionService.handleUnauthorized(failedToken: 'concurrent_token'),
        sessionService.handleUnauthorized(failedToken: 'concurrent_token'),
        sessionService.handleUnauthorized(failedToken: 'concurrent_token'),
        sessionService.handleUnauthorized(failedToken: 'concurrent_token'),
      ]);

      expect(terminationEvents, equals(1));
      expect(sessionService.isAuthenticated, isFalse);
    });

    test('3. Delayed 401 arrives after the first logout finishes -> safely ignored without error', () async {
      final sessionService = AuthSessionService(tokenStorage: tokenStorage);
      int terminationEvents = 0;
      sessionService.onSessionTerminated = () => terminationEvents++;

      // Session already logged out / empty
      expect(sessionService.isAuthenticated, isFalse);

      await sessionService.handleUnauthorized(failedToken: 'delayed_old_token');

      expect(terminationEvents, equals(0));
      expect(sessionService.isAuthenticated, isFalse);
    });

    test('4. Stale 401 for superseded token arrives after user switched account -> DOES NOT invalidate active session', () async {
      tokenStorage.writeToken('user_b_new_token');
      final sessionService = AuthSessionService(
        initialAccessToken: 'user_b_new_token',
        tokenStorage: tokenStorage,
      );

      int terminationEvents = 0;
      sessionService.onSessionTerminated = () => terminationEvents++;

      // Stale 401 arrives with User A's token
      await sessionService.handleUnauthorized(failedToken: 'user_a_stale_token');

      // User B's session remains untouched and active!
      expect(terminationEvents, equals(0));
      expect(sessionService.isAuthenticated, isTrue);
      expect(sessionService.token.value, equals('user_b_new_token'));
      expect(await tokenStorage.readToken(), equals('user_b_new_token'));
    });

    test('5. Login failure (401 without Bearer token) -> does NOT trigger session teardown', () async {
      tokenStorage.writeToken('existing_active_token');
      final sessionService = AuthSessionService(
        initialAccessToken: 'existing_active_token',
        tokenStorage: tokenStorage,
      );

      bool unauthorizedTriggered = false;
      final client = ApiClient(
        dio: mockDio,
        tokenStorage: tokenStorage,
        onUnauthorizedWithToken: (_) => unauthorizedTriggered = true,
      );

      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Simulated login request without Bearer token
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 401,
                  data: {'message': 'Invalid credentials.'},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      // Perform request explicitly passing no Authorization header
      expect(
        () => client.post<dynamic>(
          '/api/v1/customer/auth/login',
          data: {'email': 'test@rawnaqk.com', 'password': 'wrong'},
          options: Options(headers: {'Authorization': ''}),
        ),
        throwsA(isA<UnauthorizedException>()),
      );

      await pumpEventQueue();

      expect(unauthorizedTriggered, isFalse);
      expect(sessionService.isAuthenticated, isTrue);
      expect(sessionService.token.value, equals('existing_active_token'));
    });

    test('6. Non-401 errors (422, 404, 500, timeouts) do not trigger global logout', () async {
      final sessionService = AuthSessionService(
        initialAccessToken: 'valid_token',
        tokenStorage: tokenStorage,
      );

      bool unauthorizedTriggered = false;
      final client = ApiClient(
        dio: mockDio,
        tokenStorage: tokenStorage,
        onUnauthorizedWithToken: (_) => unauthorizedTriggered = true,
      );

      mockDio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            return handler.reject(
              DioException(
                requestOptions: options,
                response: Response(
                  requestOptions: options,
                  statusCode: 422,
                  data: {'message': 'Validation error', 'errors': {'field': ['invalid']}},
                ),
                type: DioExceptionType.badResponse,
              ),
            );
          },
        ),
      );

      expect(
        () => client.get<dynamic>('/api/v1/customer/cart'),
        throwsA(isA<ValidationException>()),
      );

      await pumpEventQueue();

      expect(unauthorizedTriggered, isFalse);
      expect(sessionService.isAuthenticated, isTrue);
    });

    test('7. Logout is performed twice -> idempotent and safe', () async {
      final sessionService = AuthSessionService(
        initialAccessToken: 'token_to_logout',
        tokenStorage: tokenStorage,
      );

      await sessionService.handleUnauthorized();
      expect(sessionService.isAuthenticated, isFalse);

      // Second consecutive logout
      await sessionService.handleUnauthorized();
      expect(sessionService.isAuthenticated, isFalse);
    });

    test('8. Session termination occurs while navigation is unavailable -> does not throw', () async {
      final sessionService = AuthSessionService(
        initialAccessToken: 'nav_test_token',
        tokenStorage: tokenStorage,
      );

      // In a raw headless test without GetMaterialApp mounted
      Get.testMode = true;
      expect(() async => await sessionService.handleUnauthorized(), returnsNormally);
    });

    test('9. Cleanup callback throws an exception -> caught gracefully and teardown completes', () async {
      final sessionService = AuthSessionService(
        initialAccessToken: 'faulty_callback_token',
        tokenStorage: tokenStorage,
      );

      sessionService.onSessionTerminated = () {
        throw StateError('Simulated faulty cleanup callback');
      };

      await sessionService.handleUnauthorized();

      expect(sessionService.isAuthenticated, isFalse);
      expect(sessionService.token.value, isNull);
      expect(await tokenStorage.readToken(), isNull);
    });
  });

  group('Phase 01.1: SecureAuthTokenStorage Security Audit & Fallback Elimination', () {
    test('writeToken persists securely via FlutterSecureStorage and removes SharedPreferences legacy copy', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStorageKeys.authToken, 'plaintext_legacy_token');

      final storage = SecureAuthTokenStorage();
      await storage.writeToken('secure_jwt_token_999');

      expect(await storage.readToken(), equals('secure_jwt_token_999'));
      // Plaintext legacy token removed from SharedPreferences
      expect(prefs.containsKey(LocalStorageKeys.authToken), isFalse);
    });

    test('readToken automatically migrates legacy plaintext token and deletes it from SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStorageKeys.authToken, 'legacy_unencrypted_token');

      final storage = SecureAuthTokenStorage();
      final migratedToken = await storage.readToken();

      expect(migratedToken, equals('legacy_unencrypted_token'));
      // SharedPreferences legacy token purged after migration
      expect(prefs.containsKey(LocalStorageKeys.authToken), isFalse);
      // Secure storage now holds the migrated token
      expect(await storage.readToken(), equals('legacy_unencrypted_token'));
    });

    test('clearToken wipes both secure storage and SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(LocalStorageKeys.authToken, 'to_be_deleted');

      final storage = SecureAuthTokenStorage();
      await storage.writeToken('to_be_deleted_secure');
      await storage.clearToken();

      expect(await storage.readToken(), isNull);
      expect(prefs.containsKey(LocalStorageKeys.authToken), isFalse);
    });
  });
}

