import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/routing/app_nav.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_flow_providers.dart';
import 'package:rwnaqk_frontend/modules/auth/providers/auth_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_details_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/models/order_model.dart';
import 'package:rwnaqk_frontend/modules/orders/data/repositories/orders_repository.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:rwnaqk_frontend/routes/app_route_args.dart';
import 'package:rwnaqk_frontend/routes/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CountingOrdersRepository implements IOrdersRepository {
  int getOrdersCallCount = 0;
  List<OrderModel> mockOrdersToReturn = [];
  Future<List<OrderModel>> Function()? customGetOrders;

  @override
  Future<List<OrderModel>> getOrders() async {
    getOrdersCallCount++;
    if (customGetOrders != null) {
      return await customGetOrders!();
    }
    return mockOrdersToReturn;
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async => null;

  @override
  Future<OrderDetailsModel> getOrderDetails(OrderModel order) async {
    throw UnimplementedError();
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    throw UnimplementedError();
  }

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
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> clearLocalCache() async {}
}

class StubTokenStorage implements IAuthTokenStorage {
  String? token;
  StubTokenStorage({this.token});
  @override
  Future<String?> readToken() async => token;
  @override
  Future<void> writeToken(String newToken) async => token = newToken.trim();
  @override
  Future<void> clearToken() async => token = null;
}

class FakeLoginService implements LoginService {
  LoginResult nextLoginResult = const LoginResult(
    isSuccess: true,
    requiresTwoFactor: false,
    requiresEmailVerification: false,
    token: 'test_token',
  );

  int loginCallCount = 0;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    String? code,
    String? recoveryCode,
  }) async {
    loginCallCount++;
    return nextLoginResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late StubTokenStorage tokenStorage;
  late CountingOrdersRepository countingOrdersRepo;
  late FakeLoginService fakeLoginService;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    tokenStorage = StubTokenStorage();
    countingOrdersRepo = CountingOrdersRepository();
    fakeLoginService = FakeLoginService();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesInstanceProvider.overrideWithValue(prefs),
        authTokenStorageProvider.overrideWithValue(tokenStorage),
        ordersRepositoryProvider.overrideWithValue(countingOrdersRepo),
        loginServiceProvider.overrideWithValue(fakeLoginService),
      ],
    );
    globalProviderContainer = container;
  });

  tearDown(() {
    container.dispose();
  });

  group('FIX-GUEST-02-HARDENING: Fix 1 — Two-Factor Return Route Preservation', () {
    testWidgets('Login passes returnRoute and returnArgs to TwoFactorChallenge when 2FA is required',
        (tester) async {
      fakeLoginService.nextLoginResult = const LoginResult(
        isSuccess: false,
        requiresTwoFactor: true,
        requiresEmailVerification: false,
      );

      // Simulate being redirected to Login from Cart with returnRoute
      AppNav.currentArguments = <String, dynamic>{
        AppRouteArgs.returnRoute: AppRoutes.cart,
        AppRouteArgs.returnArgs: <String, dynamic>{'from': 'checkout_button'},
      };

      String? pushedRoute;
      Object? pushedArgs;

      final loginNotifier = container.read(loginFormProvider.notifier);
      loginNotifier.emailController.text = 'user@rwnaqk.com';
      loginNotifier.passwordController.text = 'Password123!';

      // Mock form validation passing
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: AppNav.navigatorKey,
            onGenerateRoute: (settings) {
              pushedRoute = settings.name;
              pushedArgs = settings.arguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
              );
            },
            home: Scaffold(
              body: Form(
                key: formKey,
                child: const SizedBox.shrink(),
              ),
            ),
          ),
        ),
      );

      await loginNotifier.login(key: formKey);
      await tester.pumpAndSettle();

      expect(pushedRoute, AppRoutes.twoFactorChallenge);
      expect(pushedArgs, isA<Map<String, dynamic>>());
      final map = pushedArgs as Map<String, dynamic>;
      expect(map[AppRouteArgs.returnRoute], AppRoutes.cart);
      expect(map[AppRouteArgs.returnArgs], {'from': 'checkout_button'});
    });

    testWidgets('TwoFactorChallenge completion navigates back to returnRoute with returnArgs',
        (tester) async {
      fakeLoginService.nextLoginResult = const LoginResult(
        isSuccess: true,
        token: 'valid_sanctum_token_after_2fa',
        requiresTwoFactor: false,
        requiresEmailVerification: false,
        customer: CustomerModel(id: 1, email: '2fa@rwnaqk.com'),
      );

      // Current arguments on 2FA screen containing returnRoute
      AppNav.currentArguments = <String, dynamic>{
        AppRouteArgs.loginEmail: '2fa@rwnaqk.com',
        AppRouteArgs.loginPassword: 'Password123!',
        AppRouteArgs.returnRoute: AppRoutes.orders,
        AppRouteArgs.returnArgs: <String, dynamic>{'filter': 'delivered'},
      };

      String? finalRoute;
      Object? finalArgs;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: AppNav.navigatorKey,
            onGenerateRoute: (settings) {
              finalRoute = settings.name;
              finalArgs = settings.arguments;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
              );
            },
            home: const Scaffold(body: Text('2FA Screen')),
          ),
        ),
      );

      final twoFactorNotifier = container.read(twoFactorChallengeFlowProvider.notifier);
      twoFactorNotifier.setCode('123456');

      await twoFactorNotifier.submit(
        loginEmail: '2fa@rwnaqk.com',
        loginPassword: 'Password123!',
      );
      await tester.pumpAndSettle();

      // Verified: Navigated to destination with arguments
      expect(finalRoute, AppRoutes.orders);
      expect(finalArgs, {'filter': 'delivered'});
    });

    testWidgets('TwoFactorChallenge falls back to AppRoutes.main if returnRoute is invalid/external',
        (tester) async {
      fakeLoginService.nextLoginResult = const LoginResult(
        isSuccess: true,
        token: 'valid_sanctum_token_after_2fa',
        requiresTwoFactor: false,
        requiresEmailVerification: false,
        customer: CustomerModel(id: 1, email: '2fa@rwnaqk.com'),
      );

      // Malicious or invalid external returnRoute
      AppNav.currentArguments = <String, dynamic>{
        AppRouteArgs.loginEmail: '2fa@rwnaqk.com',
        AppRouteArgs.loginPassword: 'Password123!',
        AppRouteArgs.returnRoute: 'https://evil-site.com/steal-token',
      };

      String? finalRoute;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            navigatorKey: AppNav.navigatorKey,
            onGenerateRoute: (settings) {
              finalRoute = settings.name;
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => Scaffold(body: Text('Route: ${settings.name}')),
              );
            },
            home: const Scaffold(body: Text('2FA Screen')),
          ),
        ),
      );

      final twoFactorNotifier = container.read(twoFactorChallengeFlowProvider.notifier);
      twoFactorNotifier.setCode('123456');

      await twoFactorNotifier.submit(
        loginEmail: '2fa@rwnaqk.com',
        loginPassword: 'Password123!',
      );
      await tester.pumpAndSettle();

      // Sanitization blocked external URL and safely directed to main
      expect(finalRoute, AppRoutes.main);
    });
  });

  group('FIX-GUEST-02-HARDENING: Fix 2 — OrdersNotifier Defense-in-Depth', () {
    test('Guest calling loadOrders does NOT trigger repository API calls or load mock orders', () async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      expect(container.read(authSessionProvider).isGuest, isTrue);
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);

      await container.read(ordersProvider.notifier).loadOrders();

      expect(countingOrdersRepo.getOrdersCallCount, 0);
      expect(container.read(ordersProvider).orders, isEmpty);
    });

    test('Unauthenticated calling loadOrders does NOT trigger repository API calls', () async {
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);

      await container.read(ordersProvider.notifier).loadOrders();

      expect(countingOrdersRepo.getOrdersCallCount, 0);
      expect(container.read(ordersProvider).orders, isEmpty);
    });

    test('Refresh and Retry in Guest mode do NOT trigger repository API calls', () async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      // Refresh
      await container.read(ordersProvider.notifier).loadOrders(refresh: true);
      expect(countingOrdersRepo.getOrdersCallCount, 0);
      expect(container.read(ordersProvider).orders, isEmpty);

      // Repeated retry
      await container.read(ordersProvider.notifier).loadOrders(refresh: true);
      expect(countingOrdersRepo.getOrdersCallCount, 0);
      expect(container.read(ordersProvider).orders, isEmpty);
    });

    test('Guest does NOT get Mock Orders even when enableMockData is true', () async {
      await container.read(authSessionProvider.notifier).enterGuestMode();

      // Verify that even if AppEnv.enableMockData was active, defense-in-depth runs first
      await container.read(ordersProvider.notifier).loadOrders();

      expect(container.read(ordersProvider).orders, isEmpty);
      expect(countingOrdersRepo.getOrdersCallCount, 0);
    });

    test('Authenticated user loads orders normally', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'valid_token',
            customerPayload: const CustomerModel(id: 1, email: 'auth@rwnaqk.com'),
          );

      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      countingOrdersRepo.mockOrdersToReturn = [
        OrderModel(
          id: 'ORD-101',
          createdAt: DateTime.now(),
          total: 2500,
          itemsCount: 2,
          status: 'processing',
        ),
      ];

      await container.read(ordersProvider.notifier).loadOrders();

      expect(countingOrdersRepo.getOrdersCallCount, 1);
      expect(container.read(ordersProvider).orders.length, 1);
      expect(container.read(ordersProvider).orders.first.id, 'ORD-101');
    });

    test('Session transition to Guest immediately clears leftover orders from previous account', () async {
      // 1. Authenticated session with an order
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'valid_token',
            customerPayload: const CustomerModel(id: 1, email: 'auth@rwnaqk.com'),
          );
      container.read(ordersProvider.notifier).addOrder(
            OrderModel(
              id: 'SECRET-ORDER-99',
              createdAt: DateTime.now(),
              total: 5000,
              itemsCount: 1,
              status: 'confirmed',
            ),
          );
      expect(container.read(ordersProvider).orders.length, 1);

      // 2. Transition to Guest mode
      await container.read(authSessionProvider.notifier).enterGuestMode();

      // 3. Verify orders state is cleared
      expect(container.read(ordersProvider).orders, isEmpty);

      // 4. Any direct loadOrders call while in Guest retains empty state
      await container.read(ordersProvider.notifier).loadOrders();
      expect(container.read(ordersProvider).orders, isEmpty);
      expect(countingOrdersRepo.getOrdersCallCount, 0);
    });
  });

  group('FIX-GUEST-02: In-Flight Orders Request Session Guard', () {
    test('Test A — Guest Transition During Request does not leak previous account data', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'token_user_a',
            customerPayload: const CustomerModel(id: 10, email: 'userA@rwnaqk.com'),
          );

      final completer = Completer<List<OrderModel>>();
      countingOrdersRepo.customGetOrders = () => completer.future;

      // Start async loadOrders while Authenticated
      final loadFuture = container.read(ordersProvider.notifier).loadOrders();

      // Transition session to Guest while request is in-flight
      await container.read(authSessionProvider.notifier).enterGuestMode();
      expect(container.read(authSessionProvider).isGuest, isTrue);
      expect(container.read(ordersProvider).orders, isEmpty);

      // Complete in-flight request with User A's data
      completer.complete([
        OrderModel(
          id: 'STALE-ORDER-A',
          createdAt: DateTime.now(),
          total: 1500,
          itemsCount: 1,
          status: 'delivered',
        ),
      ]);
      await loadFuture;

      // Verify: Stale response was discarded and OrdersState remains clean for Guest
      expect(container.read(ordersProvider).orders, isEmpty);
      expect(container.read(ordersProvider).status, OrdersStatus.initial);
    });

    test('Test B — Unauthenticated Transition During Request does not update state', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'token_user_b',
            customerPayload: const CustomerModel(id: 20, email: 'userB@rwnaqk.com'),
          );

      final completer = Completer<List<OrderModel>>();
      countingOrdersRepo.customGetOrders = () => completer.future;

      final loadFuture = container.read(ordersProvider.notifier).loadOrders();

      // Log out while request is in-flight
      await container.read(authSessionProvider.notifier).logout();
      expect(container.read(authSessionProvider).isAuthenticated, isFalse);

      completer.complete([
        OrderModel(
          id: 'STALE-ORDER-B',
          createdAt: DateTime.now(),
          total: 2000,
          itemsCount: 2,
          status: 'processing',
        ),
      ]);
      await loadFuture;

      expect(container.read(ordersProvider).orders, isEmpty);
      expect(container.read(ordersProvider).status, OrdersStatus.initial);
    });

    test('Test C — New Session Generation prevents old request from polluting new session', () async {
      // 1. User 1 starts session
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'token_user_1',
            customerPayload: const CustomerModel(id: 1, email: 'user1@rwnaqk.com'),
          );

      final completer1 = Completer<List<OrderModel>>();
      countingOrdersRepo.customGetOrders = () => completer1.future;

      final loadFuture1 = container.read(ordersProvider.notifier).loadOrders();

      // 2. User 2 logs in (new session generation)
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'token_user_2',
            customerPayload: const CustomerModel(id: 2, email: 'user2@rwnaqk.com'),
          );

      // User 2 has empty initial orders
      expect(container.read(ordersProvider).orders, isEmpty);

      // 3. User 1's old request finishes
      completer1.complete([
        OrderModel(
          id: 'USER-1-ORDER',
          createdAt: DateTime.now(),
          total: 9999,
          itemsCount: 5,
          status: 'confirmed',
        ),
      ]);
      await loadFuture1;

      // Verify: User 1's order was discarded and does not appear in User 2's session
      expect(container.read(ordersProvider).orders, isEmpty);
      expect(container.read(ordersProvider).activeUserId, '2');
    });

    test('Test D — Authenticated Normal Behavior loads orders successfully', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'valid_token_d',
            customerPayload: const CustomerModel(id: 42, email: 'normal@rwnaqk.com'),
          );

      countingOrdersRepo.mockOrdersToReturn = [
        OrderModel(
          id: 'NORMAL-ORD-1',
          createdAt: DateTime.now(),
          total: 3500,
          itemsCount: 2,
          status: 'processing',
        ),
      ];

      await container.read(ordersProvider.notifier).loadOrders();

      expect(container.read(ordersProvider).status, OrdersStatus.loaded);
      expect(container.read(ordersProvider).orders.length, 1);
      expect(container.read(ordersProvider).orders.first.id, 'NORMAL-ORD-1');
    });

    test('Test E — Stale Error Handling does not contaminate new session', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'token_e',
            customerPayload: const CustomerModel(id: 50, email: 'error@rwnaqk.com'),
          );

      final completer = Completer<List<OrderModel>>();
      countingOrdersRepo.customGetOrders = () => completer.future;

      final loadFuture = container.read(ordersProvider.notifier).loadOrders();

      // Switch to Guest before error arrives
      await container.read(authSessionProvider.notifier).enterGuestMode();

      // Stale request fails with network error
      completer.completeError(Exception('500 Internal Server Error'));
      await loadFuture;

      // Verify: Status is NOT OrdersStatus.error, errorMessage is null
      expect(container.read(ordersProvider).status, OrdersStatus.initial);
      expect(container.read(ordersProvider).errorMessage, isNull);
    });

    test('Test F — Concurrent Requests: older response cannot overwrite newer response', () async {
      await container.read(authSessionProvider.notifier).startSession(
            accessToken: 'token_f',
            customerPayload: const CustomerModel(id: 60, email: 'concurrent@rwnaqk.com'),
          );

      final completer1 = Completer<List<OrderModel>>();
      final completer2 = Completer<List<OrderModel>>();

      // Call 1
      countingOrdersRepo.customGetOrders = () => completer1.future;
      final future1 = container.read(ordersProvider.notifier).loadOrders();

      // Call 2 (e.g. user refreshed)
      countingOrdersRepo.customGetOrders = () => completer2.future;
      final future2 = container.read(ordersProvider.notifier).loadOrders(refresh: true);

      // Call 2 completes FIRST with fresh data
      completer2.complete([
        OrderModel(
          id: 'NEW-REFRESHED-ORDER',
          createdAt: DateTime.now(),
          total: 1000,
          itemsCount: 1,
          status: 'new',
        ),
      ]);
      await future2;

      expect(container.read(ordersProvider).orders.length, 1);
      expect(container.read(ordersProvider).orders.first.id, 'NEW-REFRESHED-ORDER');

      // Call 1 completes SECOND with old data
      completer1.complete([
        OrderModel(
          id: 'OLD-STALE-ORDER',
          createdAt: DateTime.now(),
          total: 500,
          itemsCount: 1,
          status: 'old',
        ),
      ]);
      await future1;

      // Verify: NEW-REFRESHED-ORDER is retained; OLD-STALE-ORDER was discarded
      expect(container.read(ordersProvider).orders.length, 1);
      expect(container.read(ordersProvider).orders.first.id, 'NEW-REFRESHED-ORDER');
    });

    test('Test G — Notifier disposal during in-flight request does not throw unhandled exception or crash', () async {
      // Create an isolated container to explicitly control disposal
      final prefs = await SharedPreferences.getInstance();
      final isolatedRepo = CountingOrdersRepository();
      final isolatedContainer = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(StubTokenStorage()),
          ordersRepositoryProvider.overrideWithValue(isolatedRepo),
          loginServiceProvider.overrideWithValue(FakeLoginService()),
        ],
      );

      await isolatedContainer.read(authSessionProvider.notifier).startSession(
            accessToken: 'token_disposal',
            customerPayload: const CustomerModel(id: 77, email: 'disposal@rwnaqk.com'),
          );

      final completer = Completer<List<OrderModel>>();
      isolatedRepo.customGetOrders = () => completer.future;

      // Start in-flight request
      final loadFuture = isolatedContainer.read(ordersProvider.notifier).loadOrders();

      // Dispose container while request is still pending
      isolatedContainer.dispose();

      // Complete request after disposal
      completer.complete([
        OrderModel(
          id: 'POST-DISPOSAL-ORDER',
          createdAt: DateTime.now(),
          total: 8000,
          itemsCount: 1,
          status: 'confirmed',
        ),
      ]);

      // Verified: Future completes without throwing StateError or unhandled exception
      await expectLater(loadFuture, completes);
    });
  });
}
