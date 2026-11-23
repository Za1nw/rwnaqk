import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/errors/exceptions.dart';
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/network/api_client.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/cart/providers/cart_providers.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/customer/providers/customer_profile_providers.dart';
import 'package:rwnaqk_frontend/modules/home/data/models/home_product_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ControlledAsyncTokenStorage implements IAuthTokenStorage {
  String? token;
  Completer<void>? clearCompleter;
  Completer<void>? writeCompleter;
  bool shouldThrowOnClear = false;
  int clearCallCount = 0;
  int writeCallCount = 0;

  ControlledAsyncTokenStorage({this.token});

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String newToken) async {
    writeCallCount++;
    if (writeCompleter != null) {
      await writeCompleter!.future;
    }
    token = newToken.trim();
  }

  @override
  Future<void> clearToken() async {
    clearCallCount++;
    if (clearCompleter != null) {
      await clearCompleter!.future;
    }
    if (shouldThrowOnClear) {
      throw const CacheException(message: 'Disk I/O failure while clearing token');
    }
    token = null;
  }
}

class StubTokenStorage implements IAuthTokenStorage {
  String? token;
  int clearCallCount = 0;
  int writeCallCount = 0;

  StubTokenStorage({this.token});

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String newToken) async {
    writeCallCount++;
    token = newToken.trim();
  }

  @override
  Future<void> clearToken() async {
    clearCallCount++;
    token = null;
  }
}

class StubAuthRepository implements IAuthRepository {
  CustomerModel? meCustomer;
  bool shouldMeFail = false;

  @override
  Future<CustomerModel> me() async {
    if (shouldMeFail) throw const NetworkException(message: 'Network offline');
    return meCustomer ??
        const CustomerModel(
          id: 101,
          firstName: 'حقيقي',
          fullName: 'عميل حقيقي',
          email: 'real@example.com',
        );
  }

  @override
  Future<void> logout() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences testPrefs;
  late StubTokenStorage testStorage;
  late StubAuthRepository testRepo;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    testPrefs = await SharedPreferences.getInstance();
    testStorage = StubTokenStorage();
    testRepo = StubAuthRepository();

    container = ProviderContainer(
      overrides: [
        sharedPreferencesInstanceProvider.overrideWithValue(testPrefs),
        authTokenStorageProvider.overrideWithValue(testStorage),
        authRepositoryProvider.overrideWithValue(testRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('FIX-GUEST-01 — Section A: Guest Session Identity & Token Isolation', () {
    test('enterGuestMode produces guest status with customer=null and token=null', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);

      await sessionNotifier.enterGuestMode();

      final state = container.read(authSessionProvider);
      expect(state.status, equals(AuthSessionStatus.guest));
      expect(state.customer, isNull, reason: 'Guest must not possess any CustomerModel');
      expect(state.token, isNull, reason: 'Guest must not possess any token');
      expect(state.customerId, isNull);
      expect(state.isBootstrapping, isFalse);
    });

    test('isGuestModeProvider returns true, isAuthenticatedProvider returns false, currentCustomerProvider returns null', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);

      await sessionNotifier.enterGuestMode();

      expect(container.read(isGuestModeProvider), isTrue);
      expect(container.read(isAuthenticatedProvider), isFalse,
          reason: 'Guest is NOT an authenticated session');
      expect(container.read(currentCustomerProvider), isNull,
          reason: 'currentCustomerProvider must be null for guest');
    });

    test('Guest session does NOT inject pseudo-token "guest_dev_mode" or pseudo-customer "مستخدم تجريبي"', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);

      await sessionNotifier.enterGuestMode();

      final state = container.read(authSessionProvider);
      expect(state.token, isNot(equals('guest_dev_mode')));
      expect(state.customer?.fullName, isNot(equals('مستخدم تجريبي')));
      expect(state.customer?.mobile, isNot(equals('777000000')));
    });

    test('customerProfileDataProvider projects fallback "زائر" when customer is null in Guest mode', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);

      await sessionNotifier.enterGuestMode();

      final profileData = container.read(customerProfileDataProvider);
      expect(profileData.name, equals('زائر'));
      expect(profileData.phone, isEmpty);
      expect(profileData.email, isEmpty);
    });
  });

  group('FIX-GUEST-01 — Section B: Authenticated → Guest Transition Safety', () {
    test('Switching from Authenticated to Guest clears customer, token, and secure storage', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);

      // 1. Establish an active authenticated session
      const sampleCustomer = CustomerModel(
        id: 777,
        firstName: 'سارة',
        fullName: 'سارة خالد',
        email: 'sara@rawnaqk.com',
        mobile: '771234567',
      );
      await sessionNotifier.startSession(
        accessToken: 'authenticated_real_token_xyz',
        customerPayload: sampleCustomer,
      );

      final authedState = container.read(authSessionProvider);
      expect(authedState.isAuthenticated, isTrue);
      expect(authedState.customerId, equals('777'));
      expect(authedState.token, equals('authenticated_real_token_xyz'));
      expect(container.read(currentCustomerProvider)?.fullName, equals('سارة خالد'));

      final genBefore = authedState.sessionGeneration;

      // 2. Transition to Guest Mode
      await sessionNotifier.enterGuestMode();

      // 3. Verify clean guest state
      final guestState = container.read(authSessionProvider);
      expect(guestState.status, equals(AuthSessionStatus.guest));
      expect(guestState.customer, isNull, reason: 'Old customer must be wiped');
      expect(guestState.token, isNull, reason: 'Old token must be wiped');
      expect(guestState.sessionGeneration, greaterThan(genBefore),
          reason: 'Generation must increment to reject stale async responses');
      expect(container.read(currentCustomerProvider), isNull);
      expect(container.read(isAuthenticatedProvider), isFalse);
      expect(container.read(isGuestModeProvider), isTrue);

      // 4. Verify storage cleanup
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(testStorage.token, isNull, reason: 'Secure storage token must be cleared on transition to guest');
    });

    test('Transition to Guest purges session-scoped stores (cart & checkout)', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);
      final cartNotifier = container.read(cartProvider.notifier);

      // Add item to cart while authenticated
      await sessionNotifier.startSession(
        accessToken: 'token_user_1',
        customerPayload: const CustomerModel(id: 1, fullName: 'مستخدم 1'),
      );
      cartNotifier.addToCart(const HomeProductItem(
        id: 'prod_99',
        title: 'عطر رونق الملكي',
        price: 15000,
        imageUrl: '',
      ));
      expect(container.read(cartProvider).itemCount, equals(1));

      // Transition to Guest
      await sessionNotifier.enterGuestMode();

      // Verify cart was purged across account boundary
      expect(container.read(cartProvider).itemCount, equals(0),
          reason: 'Cart must be purged when transitioning from user to guest');
    });

    test('Stale async operation cannot resurrect customer data after transition to Guest', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);

      await sessionNotifier.startSession(
        accessToken: 'token_user_alpha',
        customerPayload: const CustomerModel(id: 88, fullName: 'المستخدم ألف'),
      );

      final callingGen = container.read(authSessionProvider).sessionGeneration;

      // Transition to Guest
      await sessionNotifier.enterGuestMode();
      expect(container.read(authSessionProvider).sessionGeneration, greaterThan(callingGen));

      // Attempt stale write simulating delayed me() or recoverCustomerProfile
      final staleResult = await sessionNotifier.recoverCustomerProfile();
      expect(staleResult, isNull);
      expect(container.read(authSessionProvider).customer, isNull);
      expect(container.read(authSessionProvider).status, equals(AuthSessionStatus.guest));
    });
  });

  group('FIX-GUEST-01 — Section C: Guest → Authenticated Transition', () {
    test('Logging in from Guest mode establishes authenticated state with real credentials', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);

      // 1. Start in guest mode
      await sessionNotifier.enterGuestMode();
      expect(container.read(authSessionProvider).isGuest, isTrue);
      expect(container.read(currentCustomerProvider), isNull);

      // 2. Perform authentic login
      const realUser = CustomerModel(
        id: 555,
        firstName: 'فيصل',
        fullName: 'فيصل ناصر',
        email: 'faisal@rawnaqk.com',
      );
      await sessionNotifier.startSession(
        accessToken: 'real_signed_jwt_token_555',
        customerPayload: realUser,
      );

      // 3. Verify clean authenticated session
      final state = container.read(authSessionProvider);
      expect(state.status, equals(AuthSessionStatus.authenticated));
      expect(state.isGuest, isFalse);
      expect(state.isAuthenticated, isTrue);
      expect(state.token, equals('real_signed_jwt_token_555'));
      expect(state.customer?.fullName, equals('فيصل ناصر'));
      expect(container.read(currentCustomerProvider)?.id, equals(555));
      expect(testStorage.token, equals('real_signed_jwt_token_555'));
    });
  });

  group('FIX-GUEST-01 — Section D: Token Injection & Regression Verification', () {
    test('ApiClient interceptor does NOT inject authorization token for Guest session', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);
      await sessionNotifier.enterGuestMode();

      final dio = Dio();
      RequestOptions? interceptedOptions;

      final client = ApiClient(
        dio: dio,
        tokenStorage: testStorage,
        getSessionTokenContext: (options) {
          final session = container.read(authSessionProvider);
          if (session.status == AuthSessionStatus.authenticated && session.token != null) {
            return SessionTokenContext(
              policy: TokenInjectionPolicy.allowed,
              currentSessionToken: session.token!,
              sessionGeneration: session.sessionGeneration,
              sessionStatus: session.status,
            );
          }
          return SessionTokenContext.denied(
            generation: session.sessionGeneration,
            status: session.status,
          );
        },
      );

      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          interceptedOptions = options;
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        },
      ));

      await client.get<dynamic>('/api/v1/customer/wishlist');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers.containsKey('Authorization'), isFalse,
          reason: 'Guest request must not contain Authorization header');
    });

    test('setCustomer(null) correctly clears customer via clearCustomer flag', () {
      final sessionNotifier = container.read(authSessionProvider.notifier);

      sessionNotifier.setCustomer(const CustomerModel(id: 12, fullName: 'اختبار'));
      expect(container.read(authSessionProvider).customer, isNotNull);

      sessionNotifier.setCustomer(null);
      expect(container.read(authSessionProvider).customer, isNull);
    });

    test('Banned account continues to be locked out with isAuthenticated=false', () async {
      final sessionNotifier = container.read(authSessionProvider.notifier);

      await sessionNotifier.markAsBanned(
        customerPayload: const CustomerModel(id: 99, fullName: 'محظور', isBanned: true),
      );

      final state = container.read(authSessionProvider);
      expect(state.isBanned, isTrue);
      expect(state.isAuthenticated, isFalse);
      expect(container.read(isAuthenticatedProvider), isFalse);
    });
  });

  group('FIX-GUEST-01-HARDENING — Section E: Storage Race & Error Handling Remediation', () {
    test('enterGuestMode updates in-memory session synchronously before async storage completes', () {
      final controlledStorage = ControlledAsyncTokenStorage(token: 'existing_token_999');
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(testPrefs),
          authTokenStorageProvider.overrideWithValue(controlledStorage),
          authRepositoryProvider.overrideWithValue(testRepo),
        ],
      );
      addTearDown(c.dispose);

      controlledStorage.clearCompleter = Completer<void>();

      final notifier = c.read(authSessionProvider.notifier);
      final future = notifier.enterGuestMode();

      // Immediately after the synchronous call, state is guest and customer/token are null
      final state = c.read(authSessionProvider);
      expect(state.status, equals(AuthSessionStatus.guest));
      expect(state.customer, isNull);
      expect(state.token, isNull);
      expect(state.isGuest, isTrue);

      // Now finish the async clear operation
      controlledStorage.clearCompleter!.complete();
      expect(future, completes);
    });

    test('FIFO storage serialization prevents enterGuestMode cleanup from wiping subsequent startSession token', () async {
      final controlledStorage = ControlledAsyncTokenStorage(token: 'old_user_token');
      final c = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(testPrefs),
          authTokenStorageProvider.overrideWithValue(controlledStorage),
          authRepositoryProvider.overrideWithValue(testRepo),
        ],
      );
      addTearDown(c.dispose);

      // Simulate a slow clearToken in guest mode
      controlledStorage.clearCompleter = Completer<void>();

      final notifier = c.read(authSessionProvider.notifier);
      final guestFuture = notifier.enterGuestMode();

      // User immediately logs in while clearToken is still suspended
      final loginFuture = notifier.startSession(
        accessToken: 'brand_new_user_token_888',
        customerPayload: const CustomerModel(
          id: 888,
          fullName: 'عميل جديد بعد الزائر',
          email: 'newuser@example.com',
        ),
      );

      // Release the clearToken completer
      controlledStorage.clearCompleter!.complete();

      await guestFuture;
      await loginFuture;

      final state = c.read(authSessionProvider);
      expect(state.status, equals(AuthSessionStatus.authenticated));
      expect(state.token, equals('brand_new_user_token_888'));
      expect(state.customer?.id, equals(888));
      expect(state.customer?.fullName, equals('عميل جديد بعد الزائر'));
      // The disk token must be the new user token, NOT null!
      expect(controlledStorage.token, equals('brand_new_user_token_888'));
    });

    test('clearToken failure in enterGuestMode records session invalidation flag without throwing unhandled exception', () async {
      final controlledStorage = ControlledAsyncTokenStorage(token: 'token_to_fail');
      controlledStorage.shouldThrowOnClear = true;

      final c = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(testPrefs),
          authTokenStorageProvider.overrideWithValue(controlledStorage),
          authRepositoryProvider.overrideWithValue(testRepo),
        ],
      );
      addTearDown(c.dispose);

      final notifier = c.read(authSessionProvider.notifier);

      // Must complete without throwing unhandled exception
      await expectLater(notifier.enterGuestMode(), completes);

      // In-memory status is guest
      expect(c.read(authSessionProvider).status, equals(AuthSessionStatus.guest));

      // Invalidation flag is recorded in SharedPreferences to prevent phantom session restoration
      expect(testPrefs.getBool('auth_session_invalidated_flag'), isTrue);
    });

    test('bootstrapSession clears stale leftover token when auth_session_invalidated_flag is present', () async {
      // Simulate disk state where a previous token was left behind due to storage clear error
      final controlledStorage = ControlledAsyncTokenStorage(token: 'leftover_unwiped_token');
      await testPrefs.setBool('auth_session_invalidated_flag', true);

      final c = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(testPrefs),
          authTokenStorageProvider.overrideWithValue(controlledStorage),
          authRepositoryProvider.overrideWithValue(testRepo),
        ],
      );
      addTearDown(c.dispose);

      final notifier = c.read(authSessionProvider.notifier);
      await notifier.bootstrapSession();

      final state = c.read(authSessionProvider);
      expect(state.status, equals(AuthSessionStatus.unauthenticated));
      expect(state.token, isNull);
      expect(state.isAuthenticated, isFalse);
      // Retried clear wiped the token
      expect(controlledStorage.token, isNull);
    });
  });
}
