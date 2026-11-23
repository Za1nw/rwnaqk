import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rwnaqk_frontend/core/di/core_providers.dart';
import 'package:rwnaqk_frontend/core/errors/exceptions.dart' show CacheException;
import 'package:rwnaqk_frontend/core/localization/app_localizations.dart';
import 'package:rwnaqk_frontend/core/network/api_exceptions.dart';
import 'package:rwnaqk_frontend/core/services/auth/auth_token_storage.dart';
import 'package:rwnaqk_frontend/core/services/auth/models/auth_session_state.dart';
import 'package:rwnaqk_frontend/modules/auth/controllers/login_service.dart';
import 'package:rwnaqk_frontend/modules/auth/data/repositories/auth_repository.dart';
import 'package:rwnaqk_frontend/modules/customer/data/models/customer_model.dart';
import 'package:rwnaqk_frontend/modules/orders/providers/orders_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Tracking Storage Stub ---

class CountingTokenStorage implements IAuthTokenStorage {
  int writeCount = 0;
  int clearCount = 0;
  String? token;
  bool shouldThrowOnWrite = false;
  bool shouldThrowOnClear = false;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<void> writeToken(String newToken) async {
    writeCount++;
    if (shouldThrowOnWrite) {
      throw const CacheException(message: 'Disk write failed');
    }
    token = newToken;
  }

  @override
  Future<void> clearToken() async {
    clearCount++;
    if (shouldThrowOnClear) {
      throw const CacheException(message: 'Disk clear failed');
    }
    token = null;
  }
}

class TrackingAuthRepo implements IAuthRepository {
  int logoutCallCount = 0;
  bool logoutShouldFail = false;
  CustomerModel? meResult;

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
      token: 'auth_jwt_123',
      customer: const CustomerModel(id: 11, fullName: 'عميل أولي', email: 'first@test.com'),
    );
  }

  @override
  Future<CustomerModel> me() async {
    return meResult ??
        const CustomerModel(id: 22, fullName: 'عميل مسترد', email: 'recovered@test.com');
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;
    if (logoutShouldFail) {
      throw const NetworkException(message: 'Server unreachable during logout');
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Package B: SEC-03 Session Purge & Sync Order Tests', () {
    test('Switching from Account A to Account B does NOT reset Orders and Addresses to null', () async {
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(CountingTokenStorage()),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);

      // 1. Client A logs in
      const clientA = CustomerModel(id: 100, fullName: 'العميل أ', email: 'a@test.com');
      await sessionNotifier.startSession(accessToken: 'token_A', customerPayload: clientA);

      final ordersStateA = container.read(ordersProvider);
      final addressesStateA = container.read(addressesProvider);
      expect(ordersStateA.activeUserId, equals('100'));
      expect(addressesStateA.activeUserId, equals('100'));

      // 2. Client B logs in (Account Boundary triggered)
      const clientB = CustomerModel(id: 200, fullName: 'العميل ب', email: 'b@test.com');
      await sessionNotifier.startSession(accessToken: 'token_B', customerPayload: clientB);

      // SEC-03 VERIFICATION:
      // Orders and Addresses must be associated with Client B ('200'), NOT wiped back to null!
      final ordersStateB = container.read(ordersProvider);
      final addressesStateB = container.read(addressesProvider);
      expect(ordersStateB.activeUserId, equals('200'));
      expect(addressesStateB.activeUserId, equals('200'));
    });

    test('Logout correctly resets Orders and Addresses to null', () async {
      final prefs = await SharedPreferences.getInstance();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(CountingTokenStorage()),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);

      const client = CustomerModel(id: 300, fullName: 'العميل ج', email: 'c@test.com');
      await sessionNotifier.startSession(accessToken: 'token_C', customerPayload: client);

      expect(container.read(ordersProvider).activeUserId, equals('300'));

      // Logout
      await sessionNotifier.clearSession();

      expect(container.read(ordersProvider).activeUserId, isNull);
      expect(container.read(addressesProvider).activeUserId, isNull);
    });
  });

  group('Package B: SEC-04 & SEC-07 Token Authoritative Write & Stale Guard Tests', () {
    test('startSession does not duplicate token write if token is already stored', () async {
      final storage = CountingTokenStorage()..token = 'existing_identical_token';

      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);

      // Start session with identical token
      await sessionNotifier.startSession(
        accessToken: 'existing_identical_token',
        customerPayload: const CustomerModel(id: 1, fullName: 'علي'),
      );

      // Write count should be 0 because token was already stored
      expect(storage.writeCount, equals(0));
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('startSession writes token if token is new or changed', () async {
      final storage = CountingTokenStorage()..token = 'old_token';

      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);

      await sessionNotifier.startSession(
        accessToken: 'new_different_token',
        customerPayload: const CustomerModel(id: 2, fullName: 'خالد'),
      );

      expect(storage.writeCount, equals(1));
      expect(storage.token, equals('new_different_token'));
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);
    });

    test('Stale recoverCustomerProfile does not overwrite session if generation changed', () async {
      final prefs = await SharedPreferences.getInstance();
      final authRepo = TrackingAuthRepo()
        ..meResult = const CustomerModel(id: 999, fullName: 'مستخدم قديم متأخر');

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesInstanceProvider.overrideWithValue(prefs),
          authTokenStorageProvider.overrideWithValue(CountingTokenStorage()),
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);

      // Start session (Gen 1)
      await sessionNotifier.startSession(accessToken: 'token_1', customerPayload: null);
      expect(container.read(authSessionProvider).sessionGeneration, equals(1));

      // User logs out (Gen 2)
      await sessionNotifier.clearSession();
      expect(container.read(authSessionProvider).sessionGeneration, equals(2));
      expect(container.read(authSessionProvider).status, equals(AuthSessionStatus.unauthenticated));

      // In-flight recoverCustomerProfile completes
      final res = await sessionNotifier.recoverCustomerProfile();

      // Must be ignored because generation changed and session is unauthenticated
      expect(res, isNull);
      expect(container.read(authSessionProvider).customer, isNull);
      expect(container.read(authSessionProvider).status, equals(AuthSessionStatus.unauthenticated));
    });

    test('Logout continues local cleanup and storage clear even if server logout throws', () async {
      final storage = CountingTokenStorage()..token = 'active_token_to_clear';
      final authRepo = TrackingAuthRepo()..logoutShouldFail = true;

      final container = ProviderContainer(
        overrides: [
          authTokenStorageProvider.overrideWithValue(storage),
          authRepositoryProvider.overrideWithValue(authRepo),
        ],
      );
      addTearDown(container.dispose);

      final sessionNotifier = container.read(authSessionProvider.notifier);
      await sessionNotifier.startSession(accessToken: 'active_token_to_clear');
      expect(container.read(authSessionProvider).isAuthenticated, isTrue);

      // Perform logout (server fails)
      await sessionNotifier.logout();

      // Local storage clear and session purge must still complete!
      expect(storage.token, isNull);
      expect(container.read(authSessionProvider).status, equals(AuthSessionStatus.unauthenticated));
      expect(container.read(ordersProvider).activeUserId, isNull);
    });
  });
}
